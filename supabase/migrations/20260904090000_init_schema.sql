-- ============================================================================
-- Kept — V1 schema (G-01)
-- Tables for the V1.0-a validation slice: profiles, friendships,
-- wishlist_items, gifts. RLS policies live in the next migration (G-03).
--
-- Conventions:
--  * uuid PKs via gen_random_uuid()
--  * timestamptz everywhere, default now()
--  * section-visibility columns on profiles (per-section privacy — full toggle
--    UI is G-22; columns exist now with 'friends' defaults)
--  * FKs chosen for account-deletion semantics (G-71): a deleted giver is
--    anonymized (set null) so the recipient keeps their history.
-- ============================================================================

-- ── Enums ──────────────────────────────────────────────────────────────────
create type public.visibility as enum ('public', 'friends', 'private');
create type public.friendship_status as enum ('pending', 'accepted', 'declined');

-- ── profiles ───────────────────────────────────────────────────────────────
-- One row per auth user; created during onboarding once a username is chosen
-- (G-13). NOT auto-created on signup because username is user-selected (G-12).
create table public.profiles (
  id                      uuid primary key references auth.users (id) on delete cascade,
  username                text not null,
  display_name            text,
  avatar_url              text,
  birthday                date,
  gender                  text,
  occupation              text,
  bio                     text,
  -- per-section visibility (G-22)
  profile_visibility      public.visibility not null default 'friends',
  wishlist_visibility     public.visibility not null default 'friends',
  gift_history_visibility public.visibility not null default 'friends',
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now(),
  constraint profiles_username_format
    check (username ~ '^[A-Za-z0-9_]{3,20}$')
);

-- Case-insensitive unique username (G-12).
create unique index profiles_username_lower_idx
  on public.profiles (lower(username));

-- Reminder queries scan by month/day of birthday (G-62).
create index profiles_birthday_idx on public.profiles (birthday);

comment on column public.profiles.birthday is
  'Full date; only month/day matter for reminders. Year-privacy is a later concern (G-13).';

-- ── friendships ────────────────────────────────────────────────────────────
-- One row per pair (symmetric). Direction encodes who requested. A pair is
-- "friends" when a row exists with status = 'accepted'.
create table public.friendships (
  id            uuid primary key default gen_random_uuid(),
  requester_id  uuid not null references public.profiles (id) on delete cascade,
  addressee_id  uuid not null references public.profiles (id) on delete cascade,
  status        public.friendship_status not null default 'pending',
  created_at    timestamptz not null default now(),
  responded_at  timestamptz,
  constraint friendships_no_self check (requester_id <> addressee_id)
);

-- At most one relationship per unordered pair, regardless of who requested.
create unique index friendships_unique_pair
  on public.friendships (least(requester_id, addressee_id), greatest(requester_id, addressee_id));

create index friendships_requester_idx on public.friendships (requester_id);
create index friendships_addressee_idx on public.friendships (addressee_id);

-- ── wishlist_items ─────────────────────────────────────────────────────────
create table public.wishlist_items (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references public.profiles (id) on delete cascade,
  title       text not null,
  note        text,
  url         text,
  image_url   text,
  priority    smallint not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint wishlist_title_len check (char_length(title) between 1 and 200)
);

create index wishlist_owner_idx on public.wishlist_items (owner_id);

-- ── gifts ──────────────────────────────────────────────────────────────────
-- Logged by the giver ("I bought X for Y"). Feeds the recipient's history and
-- the giver's "given" list. Surprise gifts are hidden from the RECIPIENT until
-- reveal_at (enforced in RLS, next migration).
--
-- giver_id ON DELETE SET NULL: if the giver deletes their account, the
-- recipient's history is preserved with an anonymized giver (G-71).
create table public.gifts (
  id            uuid primary key default gen_random_uuid(),
  giver_id      uuid references public.profiles (id) on delete set null,
  recipient_id  uuid not null references public.profiles (id) on delete cascade,
  item          text not null,
  note          text,
  image_url     text,
  gift_date     date not null default current_date,
  is_surprise   boolean not null default false,
  -- When a surprise becomes visible to the recipient. The app computes the
  -- default (giver-set, else recipient's next birthday + 1 day, per G-51) and
  -- the constraint below guarantees it is always set for surprises.
  reveal_at     timestamptz,
  created_at    timestamptz not null default now(),
  constraint gifts_item_len check (char_length(item) between 1 and 200),
  constraint gifts_surprise_needs_reveal
    check (not is_surprise or reveal_at is not null)
);

create index gifts_recipient_idx on public.gifts (recipient_id);
create index gifts_giver_idx on public.gifts (giver_id);

-- ── updated_at trigger ─────────────────────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger wishlist_set_updated_at
  before update on public.wishlist_items
  for each row execute function public.set_updated_at();
