-- G-410 — events beyond birthdays. An event gets a kind (birthday keeps
-- every current behaviour) and, for 'other', a free title. Uniqueness is
-- per (honoree, kind, date), so a birthday and a new baby may share a day.
-- Pushes and inbox rows name the occasion through event_label().

create type public.event_kind as enum (
  'birthday', 'new_baby', 'wedding', 'new_job', 'graduation',
  'new_home', 'retirement', 'other'
);

alter table public.gift_events
  add column kind public.event_kind not null default 'birthday',
  add column title text,
  add constraint gift_events_title_len
    check (title is null or char_length(title) between 1 and 60),
  add constraint gift_events_other_needs_title
    check (kind <> 'other' or title is not null);

drop index public.gift_events_one_per_birthday;
create unique index gift_events_one_per_occasion
  on public.gift_events (honoree_id, kind, event_date)
  where status <> 'cancelled';

-- Turkish push/inbox label for an event; the app renders its own copy.
-- Suffix-free on purpose ("Kuzey · Yeni bebek"): Turkish possessives bend
-- with the name, and the server does not know the name's last vowel.
create or replace function public.event_label(
  p_kind public.event_kind, p_title text, p_honoree text
)
returns text
language sql
immutable
as $$
  select case p_kind
    when 'birthday'   then p_honoree || ' doğum günü'
    when 'new_baby'   then p_honoree || ' · Yeni bebek'
    when 'wedding'    then p_honoree || ' · Düğün'
    when 'new_job'    then p_honoree || ' · Yeni iş'
    when 'graduation' then p_honoree || ' · Mezuniyet'
    when 'new_home'   then p_honoree || ' · Yeni ev'
    when 'retirement' then p_honoree || ' · Emeklilik'
    else coalesce(p_title, p_honoree)
  end;
$$;

-- One signature with defaults: the old one-argument call keeps working.
drop function public.create_gift_event(uuid);
create function public.create_gift_event(
  p_honoree uuid,
  p_kind public.event_kind default 'birthday',
  p_date date default null,
  p_title text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  today date := (now() at time zone 'Europe/Istanbul')::date;
  bday date;
  target date;
  v_title text;
  v_event uuid;
  v_status public.event_status;
begin
  if me is null or me = p_honoree then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  if not public.are_friends(me, p_honoree) or public.is_blocked_pair(me, p_honoree) then
    raise exception 'not allowed' using errcode = '42501';
  end if;

  if p_kind = 'birthday' then
    if p_date is not null then
      raise exception 'birthday takes its date from the profile'
        using errcode = 'check_violation';
    end if;
    select birthday into bday from public.profiles where id = p_honoree;
    if bday is null then
      raise exception 'honoree has no birthday' using errcode = 'check_violation';
    end if;
    target := public.next_birthday(bday, today);
  else
    if p_date is null then
      raise exception 'date required' using errcode = 'check_violation';
    end if;
    -- Soon enough to mean something, far enough to organise: 3 months.
    if p_date < today or p_date > today + interval '3 months' then
      raise exception 'date out of range' using errcode = 'check_violation';
    end if;
    target := p_date;
  end if;

  if p_kind = 'other' then
    v_title := nullif(btrim(coalesce(p_title, '')), '');
    if v_title is null then
      raise exception 'title required' using errcode = 'check_violation';
    end if;
  end if;

  select id, status into v_event, v_status from public.gift_events
   where honoree_id = p_honoree and kind = p_kind and event_date = target
     and status <> 'cancelled';

  if v_event is null then
    insert into public.gift_events (honoree_id, creator_id, kind, title, event_date, reveal_at)
    values (
      p_honoree, me, p_kind, v_title, target,
      ((target + 1)::timestamp at time zone 'Europe/Istanbul')
    )
    returning id into v_event;
    insert into public.gift_event_members (event_id, user_id, role, status, invited_by, responded_at)
    values (v_event, me, 'organizer', 'joined', me, now());
  elsif v_status = 'revealed' then
    -- An archive: members keep their way in, nobody new joins.
    if not exists (
      select 1 from public.gift_event_members m
      where m.event_id = v_event and m.user_id = me and m.status = 'joined'
    ) then
      raise exception 'event already revealed' using errcode = 'check_violation';
    end if;
  else
    -- Someone was first: join theirs (friends of the honoree may always join).
    insert into public.gift_event_members (event_id, user_id, role, status, invited_by, responded_at)
    values (v_event, me, 'member', 'joined', me, now())
    on conflict (event_id, user_id) do update
      set status = 'joined', responded_at = now()
      where public.gift_event_members.status <> 'joined';
  end if;
  return v_event;
end;
$$;
grant execute on function public.create_gift_event(uuid, public.event_kind, date, text) to authenticated;

-- Pushes name the occasion.
create or replace function public.event_comment_push_targets(p_comment_id uuid)
returns table (
  token text,
  platform text,
  notified_user uuid,
  commenter_label text,
  item_label text,
  snippet text,
  route text,
  enabled boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select dt.token, dt.platform, p.id,
         coalesce(a.display_name, a.username),
         public.event_label(e.kind, e.title, coalesce(h.display_name, h.username)),
         left(c.body, 120),
         '/events/' || e.id::text,
         p.social_notifications_enabled
    from public.event_comments c
    join public.gift_events e on e.id = c.event_id
    join public.profiles a on a.id = c.author_id
    join public.profiles h on h.id = e.honoree_id
    join public.gift_event_members m
      on m.event_id = e.id and m.status = 'joined' and m.user_id <> c.author_id
    join public.profiles p on p.id = m.user_id
    left join public.device_tokens dt on dt.user_id = p.id
   where c.id = p_comment_id
     and not public.is_blocked_pair(c.author_id, p.id);
$$;
revoke execute on function public.event_comment_push_targets(uuid) from public, anon, authenticated;
grant execute on function public.event_comment_push_targets(uuid) to service_role;

create or replace function public.event_delete_cleanup()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  secret text;
  v_members uuid[];
  v_removed text[];
  v_honoree text;
begin
  select array_agg(m.user_id) into v_members
    from public.gift_event_members m
   where m.event_id = old.id and m.status = 'joined'
     and (me is null or m.user_id <> me);
  select coalesce(p.display_name, p.username) into v_honoree
    from public.profiles p where p.id = old.honoree_id;

  -- Group gifts logged below their price, still unrevealed: gone.
  with doomed as (
    select g.id, g.item
      from public.gifts g
      join public.wishlist_claims c on c.gift_id = g.id
     where g.event_id = old.id
       and c.kind = 'shared'
       and c.target_amount is not null
       and g.is_surprise and g.reveal_at > now()
       and (select coalesce(sum(p.amount), 0) from public.claim_pledges p
             where p.claim_id = c.id) < c.target_amount
  ), gone as (
    delete from public.gifts g using doomed d where g.id = d.id
    returning d.item
  )
  select array_agg(item) into v_removed from gone;

  if coalesce(array_length(v_members, 1), 0) > 0 then
    begin
      select decrypted_secret into secret
        from vault.decrypted_secrets where name = 'birthday_cron_secret';
      if secret is not null then
        perform net.http_post(
          url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-event-deleted',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'x-cron-secret', secret
          ),
          body := jsonb_build_object(
            'event_id', old.id,
            'honoree', v_honoree,
            'event_label', public.event_label(old.kind, old.title, v_honoree),
            'member_ids', to_jsonb(v_members),
            'removed_items', to_jsonb(coalesce(v_removed, '{}'::text[]))
          )
        );
      end if;
    exception when others then
      raise warning 'event_delete_cleanup: % (event %)', sqlerrm, old.id;
    end;
  end if;
  return old;
end;
$$;
