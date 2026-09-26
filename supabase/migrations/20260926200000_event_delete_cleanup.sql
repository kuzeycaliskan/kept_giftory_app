-- Deleting an open event also drops the group-gift records that were
-- logged before their pool reached its price (Kuzey, 26 Sep 2026): such a
-- record was a plan, not a purchase. Solo gifts and fully funded group
-- gifts stay (link cleared by the FK). Joined members are told; the
-- payload carries their ids because the membership rows cascade away
-- with the event.

create or replace function public.push_targets_for_users(p_ids uuid[])
returns table (user_id uuid, token text, platform text, enabled boolean)
language sql
security definer
set search_path = public
stable
as $$
  select dt.user_id, dt.token, dt.platform, p.social_notifications_enabled
    from public.device_tokens dt
    join public.profiles p on p.id = dt.user_id
   where dt.user_id = any(p_ids);
$$;
revoke execute on function public.push_targets_for_users(uuid[]) from public, anon, authenticated;
grant execute on function public.push_targets_for_users(uuid[]) to service_role;

create or replace function public.event_delete_cleanup()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  secret text;
  v_members uuid[];
  v_removed text[];
  v_honoree text;
begin
  select array_agg(m.user_id) into v_members
    from public.gift_event_members m
   where m.event_id = old.id and m.status = 'joined'
     and (me is null or m.user_id <> me);
  select coalesce(p.display_name, p.username) into v_honoree
    from public.profiles p where p.id = old.honoree_id;

  -- Group gifts logged below their price, still unrevealed: gone.
  with doomed as (
    select g.id, g.item
      from public.gifts g
      join public.wishlist_claims c on c.gift_id = g.id
     where g.event_id = old.id
       and c.kind = 'shared'
       and c.target_amount is not null
       and g.is_surprise and g.reveal_at > now()
       and (select coalesce(sum(p.amount), 0) from public.claim_pledges p
             where p.claim_id = c.id) < c.target_amount
  ), gone as (
    delete from public.gifts g using doomed d where g.id = d.id
    returning d.item
  )
  select array_agg(item) into v_removed from gone;

  if coalesce(array_length(v_members, 1), 0) > 0 then
    begin
      select decrypted_secret into secret
        from vault.decrypted_secrets where name = 'birthday_cron_secret';
      if secret is not null then
        perform net.http_post(
          url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-event-deleted',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'x-cron-secret', secret
          ),
          body := jsonb_build_object(
            'event_id', old.id,
            'honoree', v_honoree,
            'member_ids', to_jsonb(v_members),
            'removed_items', to_jsonb(coalesce(v_removed, '{}'::text[]))
          )
        );
      end if;
    exception when others then
      raise warning 'event_delete_cleanup: % (event %)', sqlerrm, old.id;
    end;
  end if;
  return old;
end;
$$;

create trigger gift_events_delete_cleanup
  before delete on public.gift_events
  for each row execute function public.event_delete_cleanup();
