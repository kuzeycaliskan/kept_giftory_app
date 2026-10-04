-- The inbox (bell) must list a notice whether or not the person has a
-- push-capable device: target queries now LEFT JOIN device_tokens and hand
-- the push opt-out back as `enabled` instead of filtering on it, so the
-- Edge Function writes the inbox row for everyone and pushes only to
-- enabled tokens. Visibility, spoiler and block rules are unchanged.

drop function if exists public.gift_push_targets(uuid);
create function public.gift_push_targets(p_gift_id uuid)
returns table (
  token text,
  platform text,
  recipient_id uuid,
  giver_label text,
  item_label text,
  enabled boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select dt.token, dt.platform, g.recipient_id,
         coalesce(giver.display_name, giver.username), g.item,
         r.social_notifications_enabled
    from public.gifts g
    join public.profiles giver on giver.id = g.giver_id
    join public.profiles r on r.id = g.recipient_id
    left join public.device_tokens dt on dt.user_id = g.recipient_id
   where g.id = p_gift_id
     and not g.is_surprise
     and not public.is_blocked_pair(g.giver_id, g.recipient_id);
$$;
revoke execute on function public.gift_push_targets(uuid) from public, anon, authenticated;
grant execute on function public.gift_push_targets(uuid) to service_role;

drop function if exists public.event_comment_push_targets(uuid);
create function public.event_comment_push_targets(p_comment_id uuid)
returns table (
  token text,
  platform text,
  notified_user uuid,
  commenter_label text,
  item_label text,
  snippet text,
  route text,
  enabled boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select dt.token, dt.platform, p.id,
         coalesce(a.display_name, a.username),
         coalesce(h.display_name, h.username),
         left(c.body, 120),
         '/events/' || e.id::text,
         p.social_notifications_enabled
    from public.event_comments c
    join public.gift_events e on e.id = c.event_id
    join public.profiles a on a.id = c.author_id
    join public.profiles h on h.id = e.honoree_id
    join public.gift_event_members m
      on m.event_id = e.id and m.status = 'joined' and m.user_id <> c.author_id
    join public.profiles p on p.id = m.user_id
    left join public.device_tokens dt on dt.user_id = p.id
   where c.id = p_comment_id
     and not public.is_blocked_pair(c.author_id, p.id);
$$;
revoke execute on function public.event_comment_push_targets(uuid) from public, anon, authenticated;
grant execute on function public.event_comment_push_targets(uuid) to service_role;

drop function if exists public.comment_push_targets(text, uuid);
create function public.comment_push_targets(p_kind text, p_comment_id uuid)
returns table (
  token text,
  platform text,
  notified_user uuid,
  commenter_label text,
  item_label text,
  snippet text,
  route text,
  enabled boolean
)
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  v_author uuid;
  v_body text;
  v_gift uuid;
  v_giver uuid;
  v_recipient uuid;
  v_item text;
  v_pending boolean;
  v_post uuid;
  v_post_author uuid;
begin
  if p_kind = 'gift' then
    select c.author_id, c.body, g.id, g.giver_id, g.recipient_id, g.item,
           (g.is_surprise and g.reveal_at > now())
      into v_author, v_body, v_gift, v_giver, v_recipient, v_item, v_pending
      from public.gift_comments c
      join public.gifts g on g.id = c.gift_id
     where c.id = p_comment_id;
    if not found then return; end if;

    return query
      with people as (
        select v_giver as uid
        union select v_recipient
        union select gc.author_id from public.gift_comments gc where gc.gift_id = v_gift
      ),
      visible as (
        select pp.uid
          from people pp
          join public.profiles rp on rp.id = v_recipient
         where pp.uid is not null
           and (
             pp.uid = v_giver
             or pp.uid = v_recipient
             or (
               not public.is_blocked_pair(pp.uid, v_recipient)
               and (
                 (rp.profile_visibility = 'public' and rp.gift_history_visibility = 'public')
                 or (
                   rp.profile_visibility <> 'private'
                   and rp.gift_history_visibility <> 'private'
                   and public.are_friends(pp.uid, v_recipient)
                 )
               )
             )
           )
      )
      select dt.token, dt.platform, p.id,
             coalesce(a.display_name, a.username),
             v_item, left(v_body, 120),
             '/gifts/' || v_gift::text || '?side='
               || case when p.id = v_giver then 'recipient' else 'giver' end,
             p.social_notifications_enabled
        from visible vv
        join public.profiles p on p.id = vv.uid
        join public.profiles a on a.id = v_author
        left join public.device_tokens dt on dt.user_id = p.id
       where vv.uid <> v_author
         and not public.is_blocked_pair(v_author, p.id)
         -- A comment must not leak a pending surprise to its recipient.
         and not (v_pending and p.id = v_recipient);
    return;
  end if;

  select c.author_id, c.body, po.id, po.author_id, coalesce(po.caption, '')
    into v_author, v_body, v_post, v_post_author, v_item
    from public.post_comments c
    join public.posts po on po.id = c.post_id
   where c.id = p_comment_id;
  if not found then return; end if;

  return query
    with people as (
      select v_post_author as uid
      union select pc.author_id from public.post_comments pc where pc.post_id = v_post
    ),
    visible as (
      select pp.uid
        from people pp
        join public.profiles ap on ap.id = v_post_author
       where pp.uid = v_post_author
          or (
            not public.is_blocked_pair(pp.uid, v_post_author)
            and (
              ap.profile_visibility = 'public'
              or (ap.profile_visibility = 'friends'
                  and public.are_friends(pp.uid, v_post_author))
            )
          )
    )
    select dt.token, dt.platform, p.id,
           coalesce(a.display_name, a.username),
           v_item, left(v_body, 120),
           '/stories/' || v_post_author::text,
           p.social_notifications_enabled
      from visible vv
      join public.profiles p on p.id = vv.uid
      join public.profiles a on a.id = v_author
      left join public.device_tokens dt on dt.user_id = p.id
     where vv.uid <> v_author
       and not public.is_blocked_pair(v_author, p.id);
end;
$$;
revoke execute on function public.comment_push_targets(text, uuid) from public, anon, authenticated;
grant execute on function public.comment_push_targets(text, uuid) to service_role;

-- Already returned `enabled`; only the device join changes.
create or replace function public.event_thanks_targets(p_event uuid)
returns table (
  token text,
  platform text,
  member_id uuid,
  honoree_label text,
  note text,
  enabled boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select dt.token, dt.platform, m.user_id,
         coalesce(h.display_name, h.username), e.thanks_note,
         p.social_notifications_enabled
    from public.gift_events e
    join public.profiles h on h.id = e.honoree_id
    join public.gift_event_members m on m.event_id = e.id and m.status = 'joined'
    join public.profiles p on p.id = m.user_id
    left join public.device_tokens dt on dt.user_id = m.user_id
   where e.id = p_event and e.thanks_note is not null
     and not public.is_blocked_pair(e.honoree_id, m.user_id);
$$;
