-- Pool notices (Kuzey, 5 Oct 2026): the pool's people hear when the
-- organizer closes the pool without a gift and when the gift is logged —
-- besides expiry and the item being removed. One helper, one function.

create or replace function public.notify_pool_people(
  p_kind text, p_people uuid[], p_title text, p_actor text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
begin
  if coalesce(array_length(p_people, 1), 0) = 0 then
    return;
  end if;
  begin
    select decrypted_secret into secret
      from vault.decrypted_secrets where name = 'birthday_cron_secret';
    if secret is null then
      return;
    end if;
    perform net.http_post(
      url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-pool-removed',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-cron-secret', secret
      ),
      body := jsonb_build_object(
        'kind', p_kind,
        'user_ids', to_jsonb(p_people),
        'item_title', p_title,
        'actor', p_actor
      )
    );
  exception when others then
    raise warning 'notify_pool_people(%): %', p_kind, sqlerrm;
  end;
end;
$$;
revoke execute on function public.notify_pool_people(text, uuid[], text, text)
  from public, anon, authenticated;

create or replace function public.pool_people(p_claim uuid, p_except uuid)
returns uuid[]
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(array_agg(distinct p.user_id), '{}')
    from public.claim_pledges p
   where p.claim_id = p_claim and p.user_id <> p_except;
$$;
revoke execute on function public.pool_people(uuid, uuid) from public, anon, authenticated;

create or replace function public.guard_claim_release()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  g public.gifts%rowtype;
  v_title text;
  v_actor text;
begin
  select coalesce(lp.title, w.title) into v_title
    from public.wishlist_items w
    left join public.link_previews lp on lp.id = w.link_preview_id
   where w.id = old.item_id;

  -- Cascade from a vanished item: tell the people, keep any gift.
  if not exists (select 1 from public.wishlist_items w where w.id = old.item_id) then
    if old.kind = 'shared' and old.gift_id is null
       and exists (select 1 from public.profiles p where p.id = old.claimer_id) then
      perform public.notify_pool_people(
        'removed',
        array(select distinct u from unnest(
          array_append(public.pool_people(old.id, '00000000-0000-0000-0000-000000000000'::uuid),
                       old.claimer_id)) u),
        v_title, null);
    end if;
    return old;
  end if;
  -- The claimer's account is going: a cascade, not a release.
  if not exists (select 1 from public.profiles p where p.id = old.claimer_id) then
    return old;
  end if;
  -- An explicit release by the organizer of a pool with people in it.
  if old.kind = 'shared' and old.gift_id is null then
    select coalesce(display_name, username) into v_actor
      from public.profiles where id = old.claimer_id;
    perform public.notify_pool_people(
      'released', public.pool_people(old.id, old.claimer_id), v_title, v_actor);
  end if;
  if old.gift_id is null then
    return old;
  end if;
  select * into g from public.gifts where id = old.gift_id;
  if g.id is not null and (not g.is_surprise or g.reveal_at <= now()) then
    raise exception 'the gift has already been given'
      using errcode = 'check_violation';
  end if;
  return old;
end;
$$;

create or replace function public.attach_claim_gift(p_claim uuid, p_gift uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  c  public.wishlist_claims%rowtype;
  g  public.gifts%rowtype;
  v_event uuid;
  v_actor text;
begin
  select * into c from public.wishlist_claims where id = p_claim;
  if c.id is null or c.claimer_id <> me then
    raise exception 'not your claim' using errcode = '42501';
  end if;
  select * into g from public.gifts where id = p_gift;
  if g.id is null or g.giver_id <> me or g.recipient_id <> c.owner_id then
    raise exception 'gift does not match the claim' using errcode = '42501';
  end if;

  update public.wishlist_claims
     set gift_id = p_gift
   where id = p_claim and gift_id is null;
  if not found then
    raise exception 'claim already has a gift' using errcode = 'check_violation';
  end if;

  if c.kind = 'shared' then
    insert into public.gift_contributors (gift_id, user_id, amount)
    select p_gift, p.user_id, p.amount
      from public.claim_pledges p
     where p.claim_id = p_claim and p.user_id <> me
    on conflict do nothing;
    select coalesce(display_name, username) into v_actor
      from public.profiles where id = me;
    perform public.notify_pool_people(
      'logged', public.pool_people(p_claim, me), g.item, v_actor);
  end if;

  if g.event_id is null and g.is_surprise then
    select e.id into v_event
      from public.gift_events e
      join public.gift_event_members m on m.event_id = e.id
     where e.honoree_id = c.owner_id
       and e.status = 'open'
       and m.user_id = me and m.status = 'joined'
     order by e.event_date
     limit 1;
    if v_event is not null then
      update public.gifts set event_id = v_event where id = p_gift;
    end if;
  end if;
end;
$$;
