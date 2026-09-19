-- ============================================================================
-- Kept — Reactions on moments (G-206). Five kinds (product decision
-- 2026-09-19: not just a heart), ONE reaction per user per post, changeable
-- and removable. Visibility defers to `posts` RLS, so reactions vanish with
-- the post (expiry) and are purged with it (cascade).
-- ============================================================================

create type public.reaction_kind as enum ('heart', 'congrats', 'like', 'ok', 'wow');

create table public.post_reactions (
  post_id     uuid not null references public.posts (id) on delete cascade,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  kind        public.reaction_kind not null,
  created_at  timestamptz not null default now(),
  primary key (post_id, user_id)
);

grant select, insert, update, delete on public.post_reactions to authenticated;
grant select, delete on public.post_reactions to service_role;

alter table public.post_reactions enable row level security;

-- Readable iff the post is (subquery runs as the caller → posts RLS).
create policy post_reactions_select on public.post_reactions
  for select to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id));

create policy post_reactions_insert on public.post_reactions
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (select 1 from public.posts p where p.id = post_id)
  );

create policy post_reactions_update on public.post_reactions
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy post_reactions_delete on public.post_reactions
  for delete to authenticated
  using (user_id = auth.uid());
