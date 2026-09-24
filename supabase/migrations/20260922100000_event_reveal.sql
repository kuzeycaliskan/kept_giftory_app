-- V3.0-c — G-306 reveal state machine + G-307 reveal moment and thanks.
--
-- An event is honoree-blind while `open`. It becomes `revealed` when its
-- reveal_at passes (hourly cron → event_reveal_targets) or when the
-- organizer says so early (reveal_gift_event). Revealed, the honoree sees
-- the event, its members and the gifts logged against it — never the notes
-- board or the reservations (the friends' backstage) — and may leave one
-- thank-you note, which is pushed to the members.

alter table public.gift_events
  add column revealed_at        timestamptz,
  add column reveal_notified_at timestamptz,
  add column thanks_note        text,
  add column thanks_at          timestamptz,
  add constraint gift_events_thanks_len
    check (thanks_note is null or char_length(thanks_note) between 1 and 500);

-- Gifts logged from an event (by a joined member, for the honoree).
alter table public.gifts
  add column event_id uuid references public.gift_events (id) on delete set null;
create index gifts_event_idx on public.gifts (event_id) where event_id is not null;

-- ── RLS ──────────────────────────────────────────────────────────────────────

drop policy gift_events_select on public.gift_events;
create policy gift_events_select on public.gift_events
  for select to authenticated
  using (
    (honoree_id <> auth.uid() and public.is_event_member(id, auth.uid()))
    or (honoree_id = auth.uid() and status = 'revealed')
  );

-- The honoree's only write: the thank-you (columns enforced by the guard).
create policy gift_events_update_thanks on public.gift_events
  for update to authenticated
  using (honoree_id = auth.uid() and status = 'revealed')
  with check (honoree_id = auth.uid() and status = 'revealed');

-- Members defer to the event's own visibility (so the honoree sees who was
-- in once revealed); blocked pairs stay invisible to each other.
drop policy gift_event_members_select on public.gift_event_members;
create policy gift_event_members_select on public.gift_event_members
  for select to authenticated
  using (
    exists (select 1 from public.gift_events e where e.id = event_id)
    and not public.is_blocked_pair(auth.uid(), user_id)
  );

-- The board is the friends' backstage: the honoree never reads it, even
-- after the reveal.
drop policy event_comments_select on public.event_comments;
create policy event_comments_select on public.event_comments
  for select to authenticated
  using (
    exists (
      select 1 from public.gift_events e
      where e.id = event_id and e.honoree_id <> auth.uid()
    )
    and not public.is_blocked_pair(auth.uid(), author_id)
  );

-- ── Guards ───────────────────────────────────────────────────────────────────

-- Identity/date columns frozen; status→revealed only through the state
-- machine (definer RPCs flag the session); the honoree may set the
-- thank-you once and nothing else; organizers never touch the thank-you.
create or replace function public.guard_gift_event_update()
returns trigger
language plpgsql
as $$
declare
  by_machine boolean := coalesce(current_setting('kept.reveal', true), '') = 'on';
begin
  new.honoree_id := old.honoree_id;
  new.creator_id := old.creator_id;
  new.event_date := old.event_date;
  new.reveal_at  := old.reveal_at;
  new.created_at := old.created_at;
  if not by_machine then
    new.revealed_at        := old.revealed_at;
    new.reveal_notified_at := old.reveal_notified_at;
    if new.status = 'revealed' and old.status <> 'revealed' then
      new.status := old.status;
    end if;
  end if;
  if auth.uid() = old.honoree_id then
    new.status            := old.status;
    new.external_chat_url := old.external_chat_url;
    if old.thanks_note is not null then
      new.thanks_note := old.thanks_note;
      new.thanks_at   := old.thanks_at;
    elsif new.thanks_note is not null then
      new.thanks_at := now();
    end if;
  else
    new.thanks_note := old.thanks_note;
    new.thanks_at   := old.thanks_at;
  end if;
  return new;
end;
$$;

-- An event gift is logged by a joined member, for the honoree; the link
-- can be dropped later but never moved to another event.
create or replace function public.guard_gift_event_link()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_honoree uuid;
begin
  if new.event_id is null then
    return new;
  end if;
  if tg_op = 'UPDATE' and new.event_id is distinct from old.event_id
     and old.event_id is not null then
    raise exception 'an event gift cannot move to another event'
      using errcode = 'check_violation';
  end if;
  select e.honoree_id into v_honoree
    from public.gift_events e where e.id = new.event_id;
  if v_honoree is null or v_honoree <> new.recipient_id or not exists (
    select 1 from public.gift_event_members m
    where m.event_id = new.event_id
      and m.user_id = new.giver_id and m.status = 'joined'
  ) then
    raise exception 'event gifts are logged by joined members for the honoree'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

create trigger gifts_guard_event_link
  before insert or update on public.gifts
  for each row execute function public.guard_gift_event_link();

-- ── State machine ────────────────────────────────────────────────────────────

-- Linked surprises open with the event so the honoree sees the gifts.
create or replace function public.open_event_gifts(p_event uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update public.gifts
     set reveal_at = now()
   where event_id = p_event and is_surprise and reveal_at > now();
$$;
revoke execute on function public.open_event_gifts(uuid) from public, anon, authenticated;

-- Best-effort nudge so a manual reveal is pushed within seconds, not at
-- the next hourly tick.
create or replace function public.ping_event_reveal()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
begin
  begin
    select decrypted_secret into secret
      from vault.decrypted_secrets where name = 'birthday_cron_secret';
    if secret is null then
      return;
    end if;
    perform net.http_post(
      url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/event-reveal',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-cron-secret', secret
      ),
      body := '{}'::jsonb
    );
  exception when others then
    raise warning 'ping_event_reveal: %', sqlerrm;
  end;
end;
$$;
revoke execute on function public.ping_event_reveal() from public, anon, authenticated;

-- Organizer: reveal early (the gift was handed over).
create or replace function public.reveal_gift_event(p_event uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
begin
  if me is null or not public.is_event_organizer(p_event, me) then
    raise exception 'only the organizer can reveal' using errcode = '42501';
  end if;
  perform set_config('kept.reveal', 'on', true);
  update public.gift_events
     set status = 'revealed', revealed_at = now()
   where id = p_event and status = 'open';
  if not found then
    raise exception 'event is not open' using errcode = 'check_violation';
  end if;
  perform public.open_event_gifts(p_event);
  perform public.ping_event_reveal();
end;
$$;
grant execute on function public.reveal_gift_event(uuid) to authenticated;

-- Service: flip due events, open their gifts, hand back who to tell.
create or replace function public.event_reveal_targets()
returns table (
  event_id uuid,
  honoree_id uuid,
  token text,
  platform text,
  member_count integer,
  enabled boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  due uuid;
begin
  perform set_config('kept.reveal', 'on', true);
  for due in
    update public.gift_events
       set status = 'revealed', revealed_at = now()
     where status = 'open' and reveal_at <= now()
    returning id
  loop
    perform public.open_event_gifts(due);
  end loop;
  return query
    select e.id, e.honoree_id, dt.token, dt.platform,
           (select count(*)::integer from public.gift_event_members m
             where m.event_id = e.id and m.status = 'joined'),
           h.social_notifications_enabled
      from public.gift_events e
      join public.profiles h on h.id = e.honoree_id
      left join public.device_tokens dt on dt.user_id = e.honoree_id
     where e.status = 'revealed' and e.reveal_notified_at is null;
end;
$$;
revoke execute on function public.event_reveal_targets() from public, anon, authenticated;
grant execute on function public.event_reveal_targets() to service_role;

create or replace function public.mark_event_reveal_notified(p_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform set_config('kept.reveal', 'on', true);
  update public.gift_events
     set reveal_notified_at = now()
   where id = any(p_ids) and reveal_notified_at is null;
end;
$$;
revoke execute on function public.mark_event_reveal_notified(uuid[]) from public, anon, authenticated;
grant execute on function public.mark_event_reveal_notified(uuid[]) to service_role;

-- Linked surprises are announced by the event's own push, not one per gift.
create or replace function public.surprise_reveal_targets()
returns table (
  gift_id uuid,
  token text,
  platform text,
  recipient_id uuid,
  giver_label text,
  item_label text,
  enabled boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select g.id, dt.token, dt.platform, g.recipient_id,
         coalesce(giver.display_name, giver.username),
         g.item, r.social_notifications_enabled
    from public.gifts g
    join public.profiles r on r.id = g.recipient_id
    left join public.profiles giver on giver.id = g.giver_id
    left join public.device_tokens dt on dt.user_id = g.recipient_id
   where g.is_surprise
     and g.reveal_at <= now()
     and g.reveal_notified_at is null
     and g.event_id is null;
$$;

-- ── Thanks push ──────────────────────────────────────────────────────────────

create or replace function public.event_thanks_targets(p_event uuid)
returns table (
  token text,
  platform text,
  member_id uuid,
  honoree_label text,
  note text,
  enabled boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select dt.token, dt.platform, m.user_id,
         coalesce(h.display_name, h.username), e.thanks_note,
         p.social_notifications_enabled
    from public.gift_events e
    join public.profiles h on h.id = e.honoree_id
    join public.gift_event_members m on m.event_id = e.id and m.status = 'joined'
    join public.profiles p on p.id = m.user_id
    join public.device_tokens dt on dt.user_id = m.user_id
   where e.id = p_event and e.thanks_note is not null
     and not public.is_blocked_pair(e.honoree_id, m.user_id);
$$;
revoke execute on function public.event_thanks_targets(uuid) from public, anon, authenticated;
grant execute on function public.event_thanks_targets(uuid) to service_role;

create or replace function public.notify_event_thanks()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
begin
  if new.thanks_note is null or old.thanks_note is not null then
    return new;
  end if;
  begin
    select decrypted_secret into secret
      from vault.decrypted_secrets where name = 'birthday_cron_secret';
    if secret is null then
      return new;
    end if;
    perform net.http_post(
      url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-event-thanks',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-cron-secret', secret
      ),
      body := jsonb_build_object('event_id', new.id)
    );
  exception when others then
    raise warning 'notify_event_thanks: % (event %)', sqlerrm, new.id;
  end;
  return new;
end;
$$;

create trigger gift_events_thanks_notify
  after update on public.gift_events
  for each row execute function public.notify_event_thanks();

-- ── Cron: hourly reveal tick ─────────────────────────────────────────────────
do $$
declare
  has_secret boolean;
begin
  select exists (
    select 1 from vault.decrypted_secrets where name = 'birthday_cron_secret'
  ) into has_secret;
  if not has_secret then
    raise notice 'event-reveal: no cron secret in Vault, schedule skipped';
    return;
  end if;
  if exists (select 1 from cron.job where jobname = 'event-reveal-hourly') then
    perform cron.unschedule('event-reveal-hourly');
  end if;
  perform cron.schedule(
    'event-reveal-hourly',
    '5 * * * *',
    $job$
      select net.http_post(
        url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/event-reveal',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'x-cron-secret',
          (select decrypted_secret from vault.decrypted_secrets
            where name = 'birthday_cron_secret')
        ),
        body := '{}'::jsonb
      );
    $job$
  );
end $$;
