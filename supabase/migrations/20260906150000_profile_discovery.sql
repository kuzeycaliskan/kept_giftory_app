-- ============================================================================
-- G-32 follow-up: Instagram-style discoverability.
--
-- Product rule: EVERY profile is discoverable by search — profile_visibility
-- gates the full profile (bio, birthday, sections...), not existence. A
-- stranger hitting a friends-only profile sees a minimal "card" (avatar,
-- username, display name) plus a private notice, and can send a request.
--
-- Deliberately NOT an open view: discovery goes through two bounded
-- SECURITY DEFINER functions so the card columns are the only thing that can
-- ever leak, and search can't be used to bulk-enumerate (min length + limit).
-- ============================================================================

create or replace function public.search_profiles(q text)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text
)
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  esc text;
begin
  if auth.uid() is null then
    return;
  end if;
  q := trim(q);
  if length(q) < 2 then
    return;
  end if;
  -- Literal match: escape LIKE wildcards in user input.
  esc := replace(replace(replace(q, '\', '\\'), '%', '\%'), '_', '\_');
  return query
    select p.id, p.username, p.display_name, p.avatar_url
    from public.profiles p
    where p.id <> auth.uid()
      and (p.username ilike '%' || esc || '%' escape '\'
           or p.display_name ilike '%' || esc || '%' escape '\')
    order by p.username
    limit 20;
end;
$$;

-- Card for one profile — lets the profile screen render the private state
-- (avatar + name + request button) when RLS hides the full row.
create or replace function public.profile_card(target uuid)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text
)
language sql
security definer
set search_path = public
stable
as $$
  select p.id, p.username, p.display_name, p.avatar_url
  from public.profiles p
  where p.id = target
    and auth.uid() is not null;
$$;

revoke execute on function public.search_profiles(text) from public, anon;
revoke execute on function public.profile_card(uuid) from public, anon;
grant execute on function public.search_profiles(text) to authenticated;
grant execute on function public.profile_card(uuid) to authenticated;
