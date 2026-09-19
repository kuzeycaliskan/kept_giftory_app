-- ============================================================================
-- Kept — Social hardening (review findings, 2026-09-19).
--  1. Push-target functions were EXECUTE-able by anon/authenticated through
--     Supabase's default function privileges: any signed-in user could read
--     other users' device tokens. Service-role only now; the other definer
--     helpers lose anon as well.
--  2. Blocked users' comments/reactions stayed visible on shared items:
--     select policies now filter blocked pairs like every other surface.
--  3. Comment pushes reached earlier commenters who could no longer see the
--     item (unfriended/hidden): targets must still be able to see it.
--  4. The comment trigger could fail a user's insert if pg_net misbehaved:
--     the push ping is best-effort now.
-- ============================================================================

-- ── 1. function privileges ─────────────────────────────────────────────────
revoke execute on function public.comment_push_targets(text, uuid)
  from public, anon, authenticated;
revoke execute on function public.surprise_reveal_targets()
  from public, anon, authenticated;
grant execute on function public.comment_push_targets(text, uuid) to service_role;
grant execute on function public.surprise_reveal_targets() to service_role;

revoke execute on function public.post_reaction_cards(uuid[]) from public, anon;
revoke execute on function public.profile_cards(uuid[]) from public, anon;
revoke execute on function public.pending_surprise_teaser() from public, anon;
revoke execute on function public.can_view_profile(uuid) from public, anon;

-- ── 2. blocked pairs never see each other's comments / reactions ───────────
drop policy gift_comments_select on public.gift_comments;
create policy gift_comments_select on public.gift_comments
  for select to authenticated
  using (
    exists (select 1 from public.gifts g where g.id = gift_id)
    and not public.is_blocked_pair(auth.uid(), author_id)
  );

drop policy post_comments_select on public.post_comments;
create policy post_comments_select on public.post_comments
  for select to authenticated
  using (
    exists (select 1 from public.posts p where p.id = post_id)
    and not public.is_blocked_pair(auth.uid(), author_id)
  );

drop policy gift_reactions_select on public.gift_reactions;
create policy gift_reactions_select on public.gift_reactions
  for select to authenticated
  using (
    exists (select 1 from public.gifts g where g.id = gift_id)
    and not public.is_blocked_pair(auth.uid(), user_id)
  );

drop policy post_reactions_select on public.post_reactions;
create policy post_reactions_select on public.post_reactions
  for select to authenticated
  using (
    exists (select 1 from public.posts p where p.id = post_id)
    and not public.is_blocked_pair(auth.uid(), user_id)
  );

-- ── 3. comment targets must still be able to see the item ──────────────────
-- Visibility is re-derived per target (auth.uid() is the service role here):
-- gift parties always; others only while friends with the recipient (or the
-- recipient's history is public) and not blocked with them. Moments: the
-- author always; others only while the author's profile is visible to them.
create or replace function public.comment_push_targets(p_kind text, p_comment_id uuid)
returns table (
  token text,
  platform text,
  notified_user uuid,
  commenter_label text,
  item_label text,
  snippet text,
  route text
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
               || case when p.id = v_giver then 'recipient' else 'giver' end
        from visible vv
        join public.profiles p on p.id = vv.uid
        join public.profiles a on a.id = v_author
        join public.device_tokens dt on dt.user_id = p.id
       where vv.uid <> v_author
         and p.social_notifications_enabled
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
           '/stories/' || v_post_author::text
      from visible vv
      join public.profiles p on p.id = vv.uid
      join public.profiles a on a.id = v_author
      join public.device_tokens dt on dt.user_id = p.id
     where vv.uid <> v_author
       and p.social_notifications_enabled
       and not public.is_blocked_pair(v_author, p.id);
end;
$$;

-- ── 4. the push ping never breaks the insert ───────────────────────────────
create or replace function public.notify_comment_inserted()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
begin
  begin
    select decrypted_secret into secret
      from vault.decrypted_secrets where name = 'birthday_cron_secret';
    if secret is null then
      return new; -- local / no cloud wiring
    end if;
    perform net.http_post(
      url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-comment',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-cron-secret', secret
      ),
      body := jsonb_build_object(
        'kind', case tg_table_name when 'gift_comments' then 'gift' else 'post' end,
        'comment_id', new.id
      )
    );
  exception when others then
    -- A lost push is recoverable; a lost comment is not.
    raise warning 'notify_comment_inserted: % (comment %)', sqlerrm, new.id;
  end;
  return new;
end;
$$;
