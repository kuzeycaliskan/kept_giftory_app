-- G-210 (product decision 2026-09-19): the recipient may know that a
-- surprise is coming and when it opens — nothing else. The gift row stays
-- RLS-hidden from them (giver, item, note, photos, count of rows all
-- private); this definer function exposes exactly two facts for the caller:
-- whether at least one unrevealed surprise exists, and the earliest reveal
-- time. Supersedes the V1 "existence also hidden" stance.

create or replace function public.pending_surprise_teaser()
returns table (has_pending boolean, next_reveal_at timestamptz)
language sql
security definer
set search_path = public
stable
as $$
  select count(*) > 0, min(reveal_at)
  from public.gifts
  where recipient_id = auth.uid()
    and is_surprise
    and reveal_at > now();
$$;

grant execute on function public.pending_surprise_teaser() to authenticated;
