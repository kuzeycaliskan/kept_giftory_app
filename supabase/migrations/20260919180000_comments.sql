-- ============================================================================
-- Kept — Comments on gifts and moments (G-210 slice 3, product decision
-- 2026-09-19: anyone who can see the item can read and write comments).
-- Same shape as reactions: visibility defers to the parent's RLS, so a
-- pending surprise's comments stay hidden from the recipient, expired
-- moments take their comments with them (cascade on purge).
-- Delete: the comment's author, or the item's owner(s) (moderating their
-- own space: gift parties / moment author).
-- ============================================================================

create table public.gift_comments (
  id          uuid primary key default gen_random_uuid(),
  gift_id     uuid not null references public.gifts (id) on delete cascade,
  author_id   uuid not null references public.profiles (id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 500),
  created_at  timestamptz not null default now()
);
create index gift_comments_gift_idx on public.gift_comments (gift_id, created_at);

create table public.post_comments (
  id          uuid primary key default gen_random_uuid(),
  post_id     uuid not null references public.posts (id) on delete cascade,
  author_id   uuid not null references public.profiles (id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 500),
  created_at  timestamptz not null default now()
);
create index post_comments_post_idx on public.post_comments (post_id, created_at);

grant select, insert, delete on public.gift_comments, public.post_comments
  to authenticated;
grant select, delete on public.gift_comments, public.post_comments
  to service_role;

alter table public.gift_comments enable row level security;
alter table public.post_comments enable row level security;

-- ── gift_comments ───────────────────────────────────────────────────────────
create policy gift_comments_select on public.gift_comments
  for select to authenticated
  using (exists (select 1 from public.gifts g where g.id = gift_id));

create policy gift_comments_insert on public.gift_comments
  for insert to authenticated
  with check (
    author_id = auth.uid()
    and exists (select 1 from public.gifts g where g.id = gift_id)
  );

create policy gift_comments_delete on public.gift_comments
  for delete to authenticated
  using (
    author_id = auth.uid()
    or exists (
      select 1 from public.gifts g
      where g.id = gift_id
        and (g.giver_id = auth.uid() or g.recipient_id = auth.uid())
    )
  );

-- ── post_comments ───────────────────────────────────────────────────────────
create policy post_comments_select on public.post_comments
  for select to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id));

create policy post_comments_insert on public.post_comments
  for insert to authenticated
  with check (
    author_id = auth.uid()
    and exists (select 1 from public.posts p where p.id = post_id)
  );

create policy post_comments_delete on public.post_comments
  for delete to authenticated
  using (
    author_id = auth.uid()
    or exists (
      select 1 from public.posts p
      where p.id = post_id and p.author_id = auth.uid()
    )
  );
