-- G-206 follow-up (product rule 2026-09-19): reacting is a deliberate act
-- toward the author, so the reactor's name/avatar is always shown — even
-- when their profile is otherwise hidden from the viewer. SECURITY DEFINER
-- so the join bypasses profiles RLS; the moment itself must still be
-- visible to the caller (same rule as posts_select), and blocked pairs
-- stay invisible.

create or replace function public.post_reaction_cards(p_post_ids uuid[])
returns table (
  post_id      uuid,
  user_id      uuid,
  kind         public.reaction_kind,
  username     text,
  display_name text,
  avatar_url   text
)
language sql
security definer
set search_path = public
stable
as $$
  select r.post_id, r.user_id, r.kind, p.username, p.display_name, p.avatar_url
  from public.post_reactions r
  join public.profiles p on p.id = r.user_id
  join public.posts po on po.id = r.post_id
  where r.post_id = any(p_post_ids)
    and po.expires_at > now()
    and public.can_view_profile(po.author_id)
    and not public.is_blocked_pair(auth.uid(), r.user_id)
  order by r.created_at;
$$;

grant execute on function public.post_reaction_cards(uuid[]) to authenticated;
