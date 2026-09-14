-- ============================================================================
-- G-212: gifts received from people outside the app.
--
-- The giver is a RELATION picked from a fixed list (no free text — i18n-proof
-- wire values, no PII/moderation surface). Three giver states become explicit:
--   giver_id set                          → member gift (existing behavior)
--   giver_id null + giver_relation set    → external gift (this feature)
--   both null                             → deleted member (G-71 anonymization)
-- ============================================================================

create type public.giver_relation as enum (
  'mother', 'father', 'sibling', 'partner',
  'relative', 'friend', 'coworker', 'other'
);

alter table public.gifts
  add column giver_relation public.giver_relation,
  add constraint gifts_giver_xor_relation
    check (giver_id is null or giver_relation is null);

-- Recipients manage their own external records; member-given rows keep the
-- existing giver-only mutation rules.
create policy gifts_insert_external on public.gifts
  for insert to authenticated
  with check (
    recipient_id = auth.uid()
    and giver_id is null
    and giver_relation is not null
    -- External records are the recipient's own memory — never a surprise.
    and not is_surprise
  );

create policy gifts_update_external on public.gifts
  for update to authenticated
  using (recipient_id = auth.uid() and giver_id is null)
  with check (
    recipient_id = auth.uid()
    and giver_id is null
    and giver_relation is not null
    and not is_surprise
  );

create policy gifts_delete_external on public.gifts
  for delete to authenticated
  using (recipient_id = auth.uid() and giver_id is null);
