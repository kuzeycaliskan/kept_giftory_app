-- ============================================================================
-- G-72 block + G-73 report.
--
-- Block semantics (Instagram-style, mutual): a block severs visibility in
-- BOTH directions — profile, sections, search, card — deletes any existing
-- friendship/request, and prevents new requests. The blocked user is never
-- told; things simply look like a deleted/unknown account.
--
-- Single choke point: can_view_section() gains the block check, which every
-- visibility path (profiles_select, wishlist, gift history) already funnels
-- through. Discovery functions and the friendship insert policy get their
-- own checks since they don't pass through can_view_section.
-- ============================================================================

-- ── blocks ──────────────────────────────────────────────────────────────────
create table public.blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint blocks_no_self check (blocker_id <> blocked_id)
);

alter table public.blocks enable row level security;
grant select, insert, delete on public.blocks to authenticated;

-- Only the blocker ever sees or manages their blocks.
create policy blocks_select on public.blocks
  for select to authenticated
  using (blocker_id = auth.uid());

create policy blocks_insert on public.blocks
  for insert to authenticated
  with check (blocker_id = auth.uid());

create policy blocks_delete on public.blocks
  for delete to authenticated
  using (blocker_id = auth.uid());

-- ── helper: does a block exist in either direction? ─────────────────────────
create or replace function public.is_blocked_pair(a uuid, b uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.blocks
    where (blocker_id = a and blocked_id = b)
       or (blocker_id = b and blocked_id = a)
  );
$$;

grant execute on function public.is_blocked_pair(uuid, uuid) to authenticated;

-- ── visibility choke point ──────────────────────────────────────────────────
-- Owner still sees their own rows (no self-block possible); everyone else is
-- additionally gated on not being in a blocked pair with the owner.
create or replace function public.can_view_section(owner_id uuid, vis public.visibility)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select
    owner_id = auth.uid()
    or (
      not public.is_blocked_pair(auth.uid(), owner_id)
      and (
        vis = 'public'
        or (vis = 'friends' and public.are_friends(auth.uid(), owner_id))
      )
    );
$$;

-- ── discovery: blocked pairs vanish from search and cards ───────────────────
create or replace function public.search_profiles(q text)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text
)
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  esc text;
begin
  if auth.uid() is null then
    return;
  end if;
  q := trim(q);
  if length(q) < 2 then
    return;
  end if;
  esc := replace(replace(replace(q, '\', '\\'), '%', '\%'), '_', '\_');
  return query
    select p.id, p.username, p.display_name, p.avatar_url
    from public.profiles p
    where p.id <> auth.uid()
      and not public.is_blocked_pair(auth.uid(), p.id)
      and (p.username ilike '%' || esc || '%' escape '\'
           or p.display_name ilike '%' || esc || '%' escape '\')
    order by p.username
    limit 20;
end;
$$;

create or replace function public.profile_card(target uuid)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text
)
language sql
security definer
set search_path = public
stable
as $$
  select p.id, p.username, p.display_name, p.avatar_url
  from public.profiles p
  where p.id = target
    and auth.uid() is not null
    and not public.is_blocked_pair(auth.uid(), target);
$$;

-- ── no new requests between blocked pairs ───────────────────────────────────
drop policy friendships_insert on public.friendships;

create policy friendships_insert on public.friendships
  for insert to authenticated
  with check (
    requester_id = auth.uid()
    and not public.is_blocked_pair(requester_id, addressee_id)
  );

-- ── block / unblock actions ─────────────────────────────────────────────────
-- Atomic: record the block AND sever any friendship/pending request. Runs as
-- definer so the friendship row is removed regardless of who requested it.
create or replace function public.block_user(target uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;
  if target = auth.uid() then
    raise exception 'block_self';
  end if;
  insert into public.blocks (blocker_id, blocked_id)
  values (auth.uid(), target)
  on conflict do nothing;
  delete from public.friendships
  where (requester_id = auth.uid() and addressee_id = target)
     or (requester_id = target and addressee_id = auth.uid());
end;
$$;

create or replace function public.unblock_user(target uuid)
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.blocks
  where blocker_id = auth.uid() and blocked_id = target;
$$;

-- The blocker's own list, with cards (profile_card itself hides blocked
-- pairs, so the list needs its own definer path to render names).
create or replace function public.blocked_users()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text
)
language sql
security definer
set search_path = public
stable
as $$
  select p.id, p.username, p.display_name, p.avatar_url
  from public.blocks b
  join public.profiles p on p.id = b.blocked_id
  where b.blocker_id = auth.uid()
  order by b.created_at desc;
$$;

revoke execute on function
  public.block_user(uuid), public.unblock_user(uuid), public.blocked_users()
from public, anon;
grant execute on function
  public.block_user(uuid), public.unblock_user(uuid), public.blocked_users()
to authenticated;

-- ── reports (G-73) ──────────────────────────────────────────────────────────
create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  reported_id uuid not null references public.profiles (id) on delete cascade,
  reason      text not null
    check (reason in ('spam', 'harassment', 'inappropriate', 'other')),
  details     text check (char_length(details) <= 500),
  created_at  timestamptz not null default now(),
  constraint reports_no_self check (reporter_id <> reported_id),
  -- One open report per pair: dedup + implicit rate limit.
  constraint reports_unique_pair unique (reporter_id, reported_id)
);

alter table public.reports enable row level security;
grant insert on public.reports to authenticated;

-- Insert-only for users; the moderation queue is read via service role.
create policy reports_insert on public.reports
  for insert to authenticated
  with check (reporter_id = auth.uid());
