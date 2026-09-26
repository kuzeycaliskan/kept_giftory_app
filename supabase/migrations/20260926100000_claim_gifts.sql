-- G-309 — from reservation to gift (Kuzey, 26 Sep 2026).
--
-- A solo claim or a group-gift pool becomes a real gift record: the claimer
-- (pool: the organizer) logs the gift, `attach_claim_gift` links it to the
-- claim, snapshots the pool's pledgers as contributors and hooks the gift to
-- the honoree's event when the claimer is in one. Releasing a claim deletes
-- its gift while the gift is still unrevealed; a gift the recipient can
-- already see is history and blocks the release. Event gifts are always
-- surprises and never open before the event does.

alter table public.wishlist_claims
  add column gift_id uuid unique references public.gifts (id) on delete set null;

create table public.gift_contributors (
  gift_id uuid not null references public.gifts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  amount  numeric(12, 2) check (amount is null or amount > 0),
  primary key (gift_id, user_id)
);
create index gift_contributors_user_idx on public.gift_contributors (user_id);

alter table public.gift_contributors enable row level security;
grant select on public.gift_contributors to authenticated;
grant select, delete on public.gift_contributors to service_role;

-- Definer so the gifts policy can ask without re-entering this table's RLS.
create or replace function public.is_gift_contributor(p_gift uuid, p_user uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.gift_contributors c
    where c.gift_id = p_gift and c.user_id = p_user
  );
$$;

-- Contributors see the gift like its giver (their "given" list).
drop policy gifts_select on public.gifts;
create policy gifts_select on public.gifts
  for select to authenticated
  using (
    giver_id = auth.uid()
    or public.is_gift_contributor(id, auth.uid())
    or (
      recipient_id = auth.uid()
      and not (is_surprise and now() < reveal_at)
    )
    or (
      recipient_id <> auth.uid()
      and public.can_view_gift_history(recipient_id)
    )
  );

create policy gift_contributors_select on public.gift_contributors
  for select to authenticated
  using (exists (select 1 from public.gifts g where g.id = gift_id));
-- Written only by attach_claim_gift (definer).

-- ── Event gift rules: surprise, never before the event opens ────────────────
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
begin
  if new.event_id is null then
    return new;
  end if;
  if tg_op = 'UPDATE' and new.event_id is distinct from old.event_id
     and old.event_id is not null then
    raise exception 'an event gift cannot move to another event'
      using errcode = 'check_violation';
  end if;
  select e.honoree_id, e.reveal_at, e.status into v_honoree, v_reveal, v_status
    from public.gift_events e where e.id = new.event_id;
  if v_honoree is null or v_honoree <> new.recipient_id or not exists (
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
  -- While the event is still closed it decides when the honoree sees the
  -- gift: a date that would open earlier is lifted to the event's reveal.
  -- Once the event is revealed (by the clock or the organizer) gifts open
  -- with it — the state machine sets reveal_at = now() through this path.
  if v_status = 'open' and (new.reveal_at is null or new.reveal_at < v_reveal) then
    new.reveal_at := v_reveal;
  end if;
  return new;
end;
$$;

-- ── Attach: claim ↔ gift, contributors, event hook ──────────────────────────
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
  if c.gift_id is not null then
    raise exception 'claim already has a gift' using errcode = 'check_violation';
  end if;
  select * into g from public.gifts where id = p_gift;
  if g.id is null or g.giver_id <> me or g.recipient_id <> c.owner_id then
    raise exception 'gift does not match the claim' using errcode = '42501';
  end if;

  update public.wishlist_claims set gift_id = p_gift where id = p_claim;

  if c.kind = 'shared' then
    insert into public.gift_contributors (gift_id, user_id, amount)
    select p_gift, p.user_id, p.amount
      from public.claim_pledges p
     where p.claim_id = p_claim and p.user_id <> me
    on conflict do nothing;
  end if;

  -- In the honoree's event (as a joined member)? Then this is an event
  -- gift: it shows on their page once revealed, and opens with the event.
  if g.event_id is null then
    select e.id into v_event
      from public.gift_events e
      join public.gift_event_members m on m.event_id = e.id
     where e.honoree_id = c.owner_id
       and e.status <> 'cancelled'
       and m.user_id = me and m.status = 'joined'
     order by e.event_date
     limit 1;
    if v_event is not null then
      update public.gifts
         set event_id = v_event, is_surprise = true,
             reveal_at = coalesce(reveal_at, now())
       where id = p_gift;
    end if;
  end if;
end;
$$;
grant execute on function public.attach_claim_gift(uuid, uuid) to authenticated;

-- ── A pool with a gift is closed; a release takes its unrevealed gift ───────
create or replace function public.guard_pledge_kind()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_target numeric(12, 2);
  v_kind public.claim_kind;
  v_gift uuid;
  v_total numeric(12, 2);
  v_claim uuid := coalesce(new.claim_id, old.claim_id);
begin
  select c.kind, c.target_amount, c.gift_id into v_kind, v_target, v_gift
  from public.wishlist_claims c
  where c.id = v_claim;
  if tg_op = 'DELETE' and v_kind is null then
    -- The claim itself is being released; its pledges cascade away.
    return old;
  end if;
  if v_kind is distinct from 'shared' then
    raise exception 'pledges require a group gift' using errcode = 'check_violation';
  end if;
  if v_gift is not null then
    raise exception 'the group gift is already logged' using errcode = 'check_violation';
  end if;
  if tg_op = 'INSERT' and v_target is not null then
    select coalesce(sum(p.amount), 0) into v_total
    from public.claim_pledges p
    where p.claim_id = new.claim_id;
    if v_total >= v_target then
      raise exception 'the group gift is fully funded' using errcode = 'check_violation';
    end if;
  end if;
  return coalesce(new, old);
end;
$$;

drop trigger if exists claim_pledges_guard_kind on public.claim_pledges;
create trigger claim_pledges_guard_kind
  before insert or update or delete on public.claim_pledges
  for each row execute function public.guard_pledge_kind();

-- Before: refuse when the gift is already history. After: the claim row is
-- gone, so deleting the gift no longer touches it (its FK set-null would
-- otherwise collide with the delete in flight).
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
  if old.gift_id is not null then
    delete from public.gifts where id = old.gift_id;
  end if;
  return old;
end;
$$;

create trigger wishlist_claims_guard_release
  before delete on public.wishlist_claims
  for each row execute function public.guard_claim_release();

create trigger wishlist_claims_drop_gift
  after delete on public.wishlist_claims
  for each row execute function public.drop_released_claim_gift();
