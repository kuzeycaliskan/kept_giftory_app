-- Link previews follow the visibility of what references them.
--
-- The original policy let only the giver and the recipient read a gift's
-- preview, while `gifts_select` also shows a gift to the recipient's friends
-- (gift-history visibility). Friends therefore got the gift row with a null
-- preview embed and the product card silently disappeared from the feed.
-- Defer to the parent tables' own RLS instead of restating it here — the
-- subqueries run as the caller, so an unrevealed surprise stays hidden too.
drop policy if exists link_previews_select on public.link_previews;

create policy link_previews_select on public.link_previews
  for select to authenticated
  using (
    exists (
      select 1 from public.wishlist_items w
      where w.link_preview_id = link_previews.id
    )
    or exists (
      select 1 from public.gifts g
      where g.link_preview_id = link_previews.id
    )
  );
