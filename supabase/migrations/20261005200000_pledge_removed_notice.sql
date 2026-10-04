-- When the organizer removes someone's share from the pool, that person
-- is told (push + inbox). A self-withdrawal or a cascade says nothing.
create or replace function public.notify_pledge_removed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  v_claimer uuid;
  v_item uuid;
  v_title text;
  v_actor text;
begin
  if me is null or me = old.user_id then
    return old;
  end if;
  select c.claimer_id, c.item_id into v_claimer, v_item
    from public.wishlist_claims c where c.id = old.claim_id;
  if v_claimer is null or v_claimer <> me then
    return old;
  end if;
  select coalesce(lp.title, w.title) into v_title
    from public.wishlist_items w
    left join public.link_previews lp on lp.id = w.link_preview_id
   where w.id = v_item;
  select coalesce(display_name, username) into v_actor
    from public.profiles where id = me;
  perform public.notify_pool_people(
    'share_removed', array[old.user_id], v_title, v_actor);
  return old;
end;
$$;

create trigger claim_pledges_notify_removed
  after delete on public.claim_pledges
  for each row execute function public.notify_pledge_removed();
