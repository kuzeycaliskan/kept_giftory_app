-- special_days shipped without table grants: the cloud project grants
-- nothing by default, so every authenticated read failed (42501) and Home's
-- Upcoming section showed its error. RLS still decides row visibility.
grant select, insert, update, delete on public.special_days to authenticated;
grant select, delete on public.special_days to service_role;
