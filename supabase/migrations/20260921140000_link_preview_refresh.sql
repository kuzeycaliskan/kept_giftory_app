-- Periodic price refresh for link previews (Kuzey, 21 Sep 2026): a row
-- without a price is retried once a day, a priced row once a month.
-- The server owns the clock — `price_checked_at` is stamped when a refresh
-- slot is claimed, so ten users viewing the same product cause one attempt
-- per period, not ten. Clients only ask; nothing retries in a loop.
alter table public.link_previews
  add column price_checked_at timestamptz not null default now();

update public.link_previews set price_checked_at = fetched_at;

create index link_previews_price_checked_idx
  on public.link_previews (price_checked_at);
