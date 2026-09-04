-- ============================================================================
-- Kept — Row Level Security (G-03)
-- Default-deny on every table; access granted only by the policies below.
-- Section visibility (public / friends / private) is centralized in helper
-- functions so the rules stay consistent and auditable.
--
-- Security notes:
--  * Helpers are SECURITY DEFINER + fixed search_path so they can read the
--    friendship graph / visibility columns regardless of the caller's RLS,
--    without being hijackable.
--  * RLS is the PRIMARY authorization boundary but not the only one — the app
--    layer defends in depth (CLAUDE.md §6).
-- ============================================================================

-- ── Helper: are two users friends? ──────────────────────────────────────────
create or replace function public.are_friends(user_a uuid, user_b uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.friendships f
    where f.status = 'accepted'
      and (
        (f.requester_id = user_a and f.addressee_id = user_b) or
        (f.requester_id = user_b and f.addressee_id = user_a)
      )
  );
$$;

-- ── Helper: can the current user view a section with the given visibility? ──
-- owner is always allowed; 'public' → anyone; 'friends' → accepted friends;
-- 'private' → owner only.
create or replace function public.can_view_section(owner_id uuid, vis public.visibility)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select
    owner_id = auth.uid()
    or vis = 'public'
    or (vis = 'friends' and public.are_friends(auth.uid(), owner_id));
$$;

-- Section-specific helpers (read the owner's visibility column).
create or replace function public.can_view_wishlist(owner_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select public.can_view_section(
    owner_id,
    (select p.wishlist_visibility from public.profiles p where p.id = owner_id)
  );
$$;

create or replace function public.can_view_gift_history(owner_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select public.can_view_section(
    owner_id,
    (select p.gift_history_visibility from public.profiles p where p.id = owner_id)
  );
$$;

grant execute on function
  public.are_friends(uuid, uuid),
  public.can_view_section(uuid, public.visibility),
  public.can_view_wishlist(uuid),
  public.can_view_gift_history(uuid)
to authenticated;

-- ── Table grants (RLS still gates rows) ─────────────────────────────────────
grant select, insert, update, delete
  on public.profiles, public.friendships, public.wishlist_items, public.gifts
  to authenticated;

-- ── Enable RLS ──────────────────────────────────────────────────────────────
alter table public.profiles       enable row level security;
alter table public.friendships    enable row level security;
alter table public.wishlist_items enable row level security;
alter table public.gifts          enable row level security;

-- ── profiles ────────────────────────────────────────────────────────────────
create policy profiles_select on public.profiles
  for select to authenticated
  using (public.can_view_section(id, profile_visibility));

create policy profiles_insert on public.profiles
  for insert to authenticated
  with check (id = auth.uid());

create policy profiles_update on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());
-- No delete policy: account deletion runs in a service-role Edge Function (G-71).

-- ── friendships ─────────────────────────────────────────────────────────────
-- You only see friendship rows you're part of. (Visibility checks for other
-- users go through are_friends(), which is SECURITY DEFINER.)
create policy friendships_select on public.friendships
  for select to authenticated
  using (requester_id = auth.uid() or addressee_id = auth.uid());

-- Send a request only as yourself.
create policy friendships_insert on public.friendships
  for insert to authenticated
  with check (requester_id = auth.uid());

-- Only the addressee can accept/decline.
create policy friendships_update on public.friendships
  for update to authenticated
  using (addressee_id = auth.uid())
  with check (addressee_id = auth.uid());

-- Either party can remove the relationship / cancel the request.
create policy friendships_delete on public.friendships
  for delete to authenticated
  using (requester_id = auth.uid() or addressee_id = auth.uid());

-- ── wishlist_items ──────────────────────────────────────────────────────────
create policy wishlist_select on public.wishlist_items
  for select to authenticated
  using (public.can_view_wishlist(owner_id));

create policy wishlist_insert on public.wishlist_items
  for insert to authenticated
  with check (owner_id = auth.uid());

create policy wishlist_update on public.wishlist_items
  for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy wishlist_delete on public.wishlist_items
  for delete to authenticated
  using (owner_id = auth.uid());

-- ── gifts ───────────────────────────────────────────────────────────────────
-- Read rules (the surprise-isolation core, G-51):
--  * giver always sees gifts they logged;
--  * recipient sees their gifts EXCEPT surprises that haven't revealed yet
--    (whole-row excluded → existence/count also hidden from the recipient);
--  * anyone else sees a recipient's history per its visibility (friends/public)
--    — a pending surprise is only hidden from the recipient, not from the giver
--    or coordinating friends.
create policy gifts_select on public.gifts
  for select to authenticated
  using (
    giver_id = auth.uid()
    or (
      recipient_id = auth.uid()
      and not (is_surprise and now() < reveal_at)
    )
    or (
      recipient_id <> auth.uid()
      and public.can_view_gift_history(recipient_id)
    )
  );

-- Only the giver logs / edits / removes a gift.
create policy gifts_insert on public.gifts
  for insert to authenticated
  with check (giver_id = auth.uid());

create policy gifts_update on public.gifts
  for update to authenticated
  using (giver_id = auth.uid())
  with check (giver_id = auth.uid());

create policy gifts_delete on public.gifts
  for delete to authenticated
  using (giver_id = auth.uid());
