-- ============================================================================
-- Kept — Ephemeral posts (G-201 capture, G-202 feed, G-203 purge)
--
-- A post is one instant photo + optional caption that friends see for 24h.
-- Rules (product decision 2026-09-16):
--  * who sees a post follows the author's PROFILE visibility (public profile
--    → any signed-in user, friends profile → accepted friends), block-aware
--    through the shared can_view_section choke point;
--  * the server owns the lifetime: created_at/expires_at are forced by a
--    trigger, rows are immutable (no update policy), only the author deletes;
--  * `expires_at > now()` in RLS is the single truth for "gone" — the purge
--    job (Edge Function `purge-expired-posts`, hourly pg_cron) only reclaims
--    storage and rows afterwards;
--  * media lives in the PRIVATE `posts` bucket at '<author uid>/<name>.jpg';
--    the object is readable exactly when its post row is (policy joins the
--    row), so an expired or hidden post's photo can't be fetched by path.
-- ============================================================================

-- ── Helper: can the current user view a profile at all? ────────────────────
-- Same rule profiles_select inlines; extracted because posts (and later the
-- inventory, G-204) key their visibility off the profile setting.
create or replace function public.can_view_profile(owner_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select public.can_view_section(
    owner_id,
    (select p.profile_visibility from public.profiles p where p.id = owner_id)
  );
$$;

grant execute on function public.can_view_profile(uuid) to authenticated;

-- ── posts ───────────────────────────────────────────────────────────────────
create table public.posts (
  id          uuid primary key default gen_random_uuid(),
  author_id   uuid not null references public.profiles (id) on delete cascade,
  -- Storage object name inside the `posts` bucket (path only, never a URL).
  media_path  text not null,
  caption     text,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '24 hours',
  constraint posts_caption_len
    check (caption is null or char_length(caption) between 1 and 140),
  -- A post may only point at the author's own folder: otherwise the storage
  -- read policy (which trusts this row) could expose someone else's file.
  constraint posts_media_in_own_folder
    check (split_part(media_path, '/', 1) = author_id::text)
);

-- Feed reads: visible rows by author, newest first. Purge: expired rows.
create index posts_author_created_idx
  on public.posts (author_id, created_at desc);
create index posts_expires_idx on public.posts (expires_at);

comment on table public.posts is
  'Ephemeral photo posts (G-202). Lifetime is server-owned (set_post_lifetime); expired rows are hidden by RLS and reclaimed by purge-expired-posts.';

-- The client never chooses timestamps: whatever it sends is overwritten.
-- Retention lives in exactly one place (this function).
create or replace function public.set_post_lifetime()
returns trigger
language plpgsql
as $$
begin
  new.created_at := now();
  new.expires_at := now() + interval '24 hours';
  return new;
end;
$$;

create trigger posts_set_lifetime
  before insert on public.posts
  for each row execute function public.set_post_lifetime();

-- ── grants + RLS ────────────────────────────────────────────────────────────
grant select, insert, delete on public.posts to authenticated;
-- The purge function reads expired rows and deletes them (RLS bypass does not
-- imply privileges — the recurring 42501 lesson).
grant select, delete on public.posts to service_role;

alter table public.posts enable row level security;

create policy posts_select on public.posts
  for select to authenticated
  using (expires_at > now() and public.can_view_profile(author_id));

create policy posts_insert on public.posts
  for insert to authenticated
  with check (author_id = auth.uid());

-- No update policy: a post is immutable. Author-only delete.
create policy posts_delete on public.posts
  for delete to authenticated
  using (author_id = auth.uid());

-- ── storage: private `posts` bucket ─────────────────────────────────────────
-- Not public (unlike avatars): the photo is friends-only surface. Server-side
-- caps mirror the client pipeline (1080px/80q jpeg ≈ 150-300 KB).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('posts', 'posts', false, 1048576, array['image/jpeg'])
on conflict (id) do nothing;

create policy posts_media_insert_own on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'posts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Readable iff a live, visible post row references this exact object. The
-- row's CHECK guarantees the referenced path sits in the author's folder.
create policy posts_media_select_via_post on storage.objects
  for select to authenticated
  using (
    bucket_id = 'posts'
    and exists (
      select 1
      from public.posts p
      where p.media_path = storage.objects.name
        and p.expires_at > now()
        and public.can_view_profile(p.author_id)
    )
  );

create policy posts_media_delete_own on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'posts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
