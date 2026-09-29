-- Review fixes (29 Sep 2026) for the reservation→gift and event links.
--
-- 1. An owner deleting a wishlist item cascades its claim. That is not a
--    release: the friend's gift record must survive, and a revealed gift
--    must not make the item undeletable. The claim triggers now tell a
--    cascade (item already gone) from an explicit release.
-- 2. guard_gift_event_link re-checked membership on every gift UPDATE, so
--    a member who left the event could no longer edit their gift — and the
--    reveal itself (which updates every linked gift) would fail on it.
--    Membership is checked when the link is made, not forever after.
-- 3. attach_claim_gift hooked a gift onto the honoree's earliest event of
--    any status (a revealed one from last year), and turned a deliberately
--    non-surprise gift into a surprise. It now hooks surprises onto the
--    honoree's OPEN event only.

create or replace function public.guard_claim_release()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  g public.gifts%rowtype;
begin
  if old.gift_id is null then
    return old;
  end if;
  -- Item gone → cascade, not a release: leave the gift alone.
  if not exists (select 1 from public.wishlist_items w where w.id = old.item_id) then
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

create or replace function public.drop_released_claim_gift()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.gift_id is not null
     and exists (select 1 from public.wishlist_items w where w.id = old.item_id) then
    delete from public.gifts where id = old.gift_id;
  end if;
  return old;
end;
$$;

create or replace function public.guard_gift_event_link()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_honoree uuid;
  v_reveal  timestamptz;
  v_status  public.event_status;
  linking   boolean;
begin
  if new.event_id is null then
    return new;
  end if;
  if tg_op = 'UPDATE' and new.event_id is distinct from old.event_id
     and old.event_id is not null then
    raise exception 'an event gift cannot move to another event'
      using errcode = 'check_violation';
  end if;
  linking := tg_op = 'INSERT' or new.event_id is distinct from old.event_id;
  select e.honoree_id, e.reveal_at, e.status into v_honoree, v_reveal, v_status
    from public.gift_events e where e.id = new.event_id;
  if v_honoree is null or v_honoree <> new.recipient_id then
    raise exception 'event gifts are for the honoree' using errcode = 'check_violation';
  end if;
  if linking and not exists (
    select 1 from public.gift_event_members m
    where m.event_id = new.event_id
      and m.user_id = new.giver_id and m.status = 'joined'
  ) then
    raise exception 'event gifts are logged by joined members for the honoree'
      using errcode = 'check_violation';
  end if;
  if not new.is_surprise then
    raise exception 'event gifts are surprises' using errcode = 'check_violation';
  end if;
  if v_status = 'open' and (new.reveal_at is null or new.reveal_at < v_reveal) then
    new.reveal_at := v_reveal;
  end if;
  return new;
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
  end if;

  -- A surprise logged from the wishlist joins the honoree's OPEN event when
  -- the claimer is in it; revealed events are history and never adopt.
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
