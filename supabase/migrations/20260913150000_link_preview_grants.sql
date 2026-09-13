-- G-211 hotfix: the edge function's service_role writes were failing on
-- cloud with 42501 — RLS-bypass does not imply table privileges, and the
-- new tables only granted select to authenticated. Same failure class as
-- the birthday-reminder grants fix (20260905210000).

grant select, insert, update on public.link_previews to service_role;
grant select, insert, delete on public.link_preview_requests to service_role;
