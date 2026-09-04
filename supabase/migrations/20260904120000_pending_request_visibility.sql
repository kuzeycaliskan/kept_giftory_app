-- ============================================================================
-- G-31: parties of a PENDING friend request may see each other's profile.
--
-- Without this, an addressee whose requester has a friends-only profile
-- cannot render who is asking (and vice versa for the requester's outgoing
-- list). Scope stays minimal: only while a pending row exists between the two.
-- ============================================================================

create or replace function public.has_pending_request(other_user uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.friendships f
    where f.status = 'pending'
      and (
        (f.requester_id = other_user and f.addressee_id = auth.uid()) or
        (f.requester_id = auth.uid() and f.addressee_id = other_user)
      )
  );
$$;

grant execute on function public.has_pending_request(uuid) to authenticated;

drop policy profiles_select on public.profiles;

create policy profiles_select on public.profiles
  for select to authenticated
  using (
    public.can_view_section(id, profile_visibility)
    or public.has_pending_request(id)
  );
