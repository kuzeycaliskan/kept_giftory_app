-- ============================================================================
-- G-211: link previews (OG metadata) for wishlist items and gifts.
--
-- One cached row per normalized URL (url_hash) — the edge function upserts;
-- repeat pastes of the same product link never refetch. Doubles as a
-- popularity signal for the V4 catalog (G-401).
--
-- RLS: rows are readable only through content you can already see — a
-- preview is visible iff SOME visible wishlist item or gift references it.
-- Writes happen exclusively in the `link-preview` edge function (service
-- role); clients never insert/update previews directly.
-- ============================================================================

create table public.link_previews (
  id          uuid primary key default gen_random_uuid(),
  url_hash    text not null unique,        -- sha256(normalized url), hex
  url         text not null,
  title       text,
  image_path  text,                        -- storage path in `link-previews`
  price       text,                        -- verbatim (e.g. "1.299,00 TL")
  site        text,                        -- og:site_name or host
  fetched_at  timestamptz not null default now()
);

alter table public.wishlist_items
  add column link_preview_id uuid references public.link_previews (id);

alter table public.gifts
  add column link_preview_id uuid references public.link_previews (id);

alter table public.link_previews enable row level security;
grant select on public.link_previews to authenticated;

create policy link_previews_select on public.link_previews
  for select to authenticated
  using (
    exists (
      select 1 from public.wishlist_items w
      where w.link_preview_id = link_previews.id
        and public.can_view_wishlist(w.owner_id)
    )
    or exists (
      select 1 from public.gifts g
      where g.link_preview_id = link_previews.id
        and (g.giver_id = auth.uid() or g.recipient_id = auth.uid())
    )
  );

-- Fetch throttle (G-211 rate limit): one row per preview REQUEST, pruned by
-- the function itself. Service-role only.
create table public.link_preview_requests (
  user_id      uuid not null references public.profiles (id) on delete cascade,
  requested_at timestamptz not null default now()
);
create index link_preview_requests_user_time_idx
  on public.link_preview_requests (user_id, requested_at);

alter table public.link_preview_requests enable row level security;
-- no policies: clients never touch this table (default deny).

-- Public-read storage bucket for preview thumbnails. Tiny assets (~<300KB);
-- intentionally NOT the G-207 user-media decision — migrating these later is
-- a copy job. Writes are service-role only (no storage policies for users).
insert into storage.buckets (id, name, public)
values ('link-previews', 'link-previews', true)
on conflict (id) do nothing;
