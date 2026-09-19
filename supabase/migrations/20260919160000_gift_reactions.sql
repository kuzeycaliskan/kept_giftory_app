-- ============================================================================
-- Kept — Reactions on gifts (G-210 slice 2 / G-206 extension). Same shape
-- as post_reactions: five kinds, ONE per user per gift, visibility defers
-- to `gifts` RLS (a pending surprise's reactions stay hidden from the
-- recipient; friend-history visibility carries over). Anyone who can see a
-- gift may react, parties included.
--
-- `profile_cards(uuid[])` batches the discovery card (G-32: the card is
-- always visible, block-aware) so reactor identities resolve in one call
-- regardless of profile visibility — the product rule for reactions.
-- ============================================================================

create table public.gift_reactions (
  gift_id     uuid not null references public.gifts (id) on delete cascade,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  kind        public.reaction_kind not null,
  created_at  timestamptz not null default now(),
  primary key (gift_id, user_id)
);

grant select, insert, update, delete on public.gift_reactions to authenticated;
grant select, delete on public.gift_reactions to service_role;

alter table public.gift_reactions enable row level security;

create policy gift_reactions_select on public.gift_reactions
  for select to authenticated
  using (exists (select 1 from public.gifts g where g.id = gift_id));

create policy gift_reactions_insert on public.gift_reactions
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (select 1 from public.gifts g where g.id = gift_id)
  );

create policy gift_reactions_update on public.gift_reactions
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy gift_reactions_delete on public.gift_reactions
  for delete to authenticated
  using (user_id = auth.uid());

-- ── batch discovery cards ───────────────────────────────────────────────────
create or replace function public.profile_cards(p_ids uuid[])
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
  where p.id = any(p_ids)
    and auth.uid() is not null
    and not public.is_blocked_pair(auth.uid(), p.id);
$$;

grant execute on function public.profile_cards(uuid[]) to authenticated;
