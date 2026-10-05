-- Reveal notifiers claimed their batch LAST (inbox → push → mark), so a
-- failure in between (FCM) left reveal_notified_at null and the hourly job
-- re-announced the same gifts every run — fifty "your surprise opened"
-- rows in one inbox. The functions now mark first; this is the marker for
-- surprises (events already had mark_event_reveal_notified) and a one-off
-- sweep of the duplicates already written.

create or replace function public.mark_surprises_notified(p_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform set_config('kept.reveal', 'on', true);
  update public.gifts
     set reveal_notified_at = now()
   where id = any(p_ids) and reveal_notified_at is null;
end;
$$;
revoke execute on function public.mark_surprises_notified(uuid[]) from public, anon, authenticated;
grant execute on function public.mark_surprises_notified(uuid[]) to service_role;

-- Keep the first of each repeated notice; the rest were re-runs.
delete from public.notifications n
 using public.notifications first
 where first.user_id = n.user_id
   and first.kind = n.kind
   and first.title = n.title
   and first.body = n.body
   and first.route is not distinct from n.route
   and n.kind in ('surprise', 'event:reveal')
   and first.created_at < n.created_at;
