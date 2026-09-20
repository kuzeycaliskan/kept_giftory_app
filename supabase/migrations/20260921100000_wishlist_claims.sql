-- V3.0-b — G-303 reservation ("I'll get this") + G-304 group gift (pledges).
--
-- A claim marks one wishlist item as taken care of by a friend of its owner:
-- `solo` (one buyer) or `shared` (a pool friends pledge amounts into — a
-- commitment ledger only, money moves outside the app until V4).
--
-- Honoree-blind by construction: the item's owner never reads claims or
-- pledges (RLS), so the surprise survives. One claim per item (unique) is
-- the double-buy guard; the second buyer gets 23505 and the app tells them.

create type public.claim_kind as enum ('solo', 'shared');

create table public.wishlist_claims (
  id            uuid primary key default gen_random_uuid(),
  item_id       uuid not null unique references public.wishlist_items (id) on delete cascade,
  -- Denormalised from the item by trigger: policies stay cheap and the
  -- client cannot lie about whose list this is.
  owner_id      uuid not null references public.profiles (id) on delete cascade,
  claimer_id    uuid not null references public.profiles (id) on delete cascade,
  kind          public.claim_kind not null default 'solo',
  target_amount numeric(12, 2),
  created_at    timestamptz not null default now(),
  constraint claims_target_positive check (target_amount is null or target_amount > 0),
  constraint claims_target_only_shared check (kind = 'shared' or target_amount is null)
);

create index wishlist_claims_owner_idx on public.wishlist_claims (owner_id);

create table public.claim_pledges (
  id         uuid primary key default gen_random_uuid(),
  claim_id   uuid not null references public.wishlist_claims (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  amount     numeric(12, 2) not null check (amount > 0),
  created_at timestamptz not null default now(),
  unique (claim_id, user_id)
);

alter table public.wishlist_claims enable row level security;
alter table public.claim_pledges enable row level security;

grant select, insert, update, delete on public.wishlist_claims to authenticated;
grant select, insert, update, delete on public.claim_pledges to authenticated;
grant select, delete on public.wishlist_claims to service_role;
grant select, delete on public.claim_pledges to service_role;

-- ── Triggers ─────────────────────────────────────────────────────────────────

-- Stamp the owner from the item (definer: the claimer may not be able to read
-- the item row at that instant, and the client must not choose the owner).
create or replace function public.set_claim_owner()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  select w.owner_id into new.owner_id
  from public.wishlist_items w
  where w.id = new.item_id;
  if new.owner_id is null then
    raise exception 'wishlist item not found' using errcode = 'foreign_key_violation';
  end if;
  return new;
end;
$$;

create trigger wishlist_claims_set_owner
  before insert on public.wishlist_claims
  for each row execute function public.set_claim_owner();

-- Identity columns are immutable; a pool never silently collapses back to a
-- single buyer while people have pledged into it.
create or replace function public.guard_claim_update()
returns trigger
language plpgsql
as $$
begin
  if new.item_id <> old.item_id
     or new.owner_id <> old.owner_id
     or new.claimer_id <> old.claimer_id then
    raise exception 'claim identity is immutable' using errcode = 'check_violation';
  end if;
  if old.kind = 'shared' and new.kind = 'solo' then
    raise exception 'a group gift cannot become a solo claim' using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

create trigger wishlist_claims_guard_update
  before update on public.wishlist_claims
  for each row execute function public.guard_claim_update();

-- Pledges only make sense on a pool.
create or replace function public.guard_pledge_kind()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.wishlist_claims c
    where c.id = new.claim_id and c.kind = 'shared'
  ) then
    raise exception 'pledges require a group gift' using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

create trigger claim_pledges_guard_kind
  before insert or update on public.claim_pledges
  for each row execute function public.guard_pledge_kind();

-- ── RLS ──────────────────────────────────────────────────────────────────────
-- Readers/writers: friends of the owner who may see the list — never the
-- owner. Identity of claimers/pledgers resolves through profile_cards()
-- (block-aware) on the client, so no block filter is needed here.

create policy wishlist_claims_select on public.wishlist_claims
  for select to authenticated
  using (
    owner_id <> auth.uid()
    and public.are_friends(owner_id, auth.uid())
    and public.can_view_wishlist(owner_id)
  );

create policy wishlist_claims_insert on public.wishlist_claims
  for insert to authenticated
  with check (
    claimer_id = auth.uid()
    and owner_id <> auth.uid()
    and public.are_friends(owner_id, auth.uid())
    and public.can_view_wishlist(owner_id)
  );

create policy wishlist_claims_update on public.wishlist_claims
  for update to authenticated
  using (claimer_id = auth.uid())
  with check (claimer_id = auth.uid());

create policy wishlist_claims_delete on public.wishlist_claims
  for delete to authenticated
  using (claimer_id = auth.uid());

-- Pledges defer to the parent claim's visibility (the subquery runs as the
-- caller, so the owner and strangers see nothing).
create policy claim_pledges_select on public.claim_pledges
  for select to authenticated
  using (
    exists (select 1 from public.wishlist_claims c where c.id = claim_id)
  );

create policy claim_pledges_insert on public.claim_pledges
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (select 1 from public.wishlist_claims c where c.id = claim_id)
  );

create policy claim_pledges_update on public.claim_pledges
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Own pledge, or the pool's organiser managing participants.
create policy claim_pledges_delete on public.claim_pledges
  for delete to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.wishlist_claims c
      where c.id = claim_id and c.claimer_id = auth.uid()
    )
  );
