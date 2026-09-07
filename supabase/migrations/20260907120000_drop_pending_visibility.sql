-- Privacy fix: sending a request no longer unlocks the FULL profile.
--
-- G-31 added a pending-request exception to profiles_select so request rows
-- could be rendered at all. Since 20260906150000 the minimal card
-- (profile_card / search_profiles) covers that need — keeping the exception
-- let anyone peek at a private profile's details (bio, birthday, occupation)
-- just by sending a request, unilaterally. Full profile now unlocks only on
-- acceptance (are_friends); the client renders pending counterparts from
-- their cards.

drop policy profiles_select on public.profiles;

create policy profiles_select on public.profiles
  for select to authenticated
  using (public.can_view_section(id, profile_visibility));

drop function public.has_pending_request(uuid);
