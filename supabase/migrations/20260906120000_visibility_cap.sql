-- G-22 follow-up: a section must never be more open than the profile itself.
-- Previously can_view_wishlist / can_view_gift_history checked only the
-- section column, so "profile: friends + wishlist: public" leaked wishlist
-- rows to strangers who couldn't even see the profile. Effective visibility
-- is now min(profile_visibility, section_visibility): both checks must pass.
-- (Owner always passes both; stored section preferences are untouched, so
-- re-opening the profile restores them.)

create or replace function public.can_view_wishlist(owner_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select
    public.can_view_section(
      owner_id,
      (select p.profile_visibility from public.profiles p where p.id = owner_id)
    )
    and public.can_view_section(
      owner_id,
      (select p.wishlist_visibility from public.profiles p where p.id = owner_id)
    );
$$;

create or replace function public.can_view_gift_history(owner_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select
    public.can_view_section(
      owner_id,
      (select p.profile_visibility from public.profiles p where p.id = owner_id)
    )
    and public.can_view_section(
      owner_id,
      (select p.gift_history_visibility from public.profiles p where p.id = owner_id)
    );
$$;
