-- ============================================================================
-- Kept — Social push (G-210 slice 3, part D; product decision 2026-09-19):
-- push for COMMENTS and for "your surprise opened"; reactions stay silent.
--
--  * profiles.social_notifications_enabled — one switch for both kinds.
--  * comment_push_targets(kind, comment_id): who to notify about a comment
--    (gift parties / moment author + earlier commenters), minus the author,
--    minus opt-outs and blocked pairs, minus the recipient of a still-pending
--    surprise (no spoilers through a comment ping).
--  * surprise_reveal_targets(): surprises whose reveal time passed and that
--    were not announced yet; gifts.reveal_notified_at makes it idempotent.
--  * comment inserts ping the notify-comment function through pg_net (cloud
--    only: skipped where the Vault secret is absent); an hourly pg_cron job
--    calls surprise-revealed, same wiring as the purge job.
-- ============================================================================

alter table public.profiles
  add column social_notifications_enabled boolean not null default true;

alter table public.gifts add column reveal_notified_at timestamptz;
-- Already-open surprises were seen without a push: never announce them.
update public.gifts set reveal_notified_at = now()
 where is_surprise and reveal_at <= now();

grant update on public.gifts to service_role;

-- ── comment targets ─────────────────────────────────────────────────────────
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
      )
      select dt.token, dt.platform, p.id,
             coalesce(a.display_name, a.username),
             v_item, left(v_body, 120),
             '/gifts/' || v_gift::text || '?side='
               || case when p.id = v_giver then 'recipient' else 'giver' end
        from people pp
        join public.profiles p on p.id = pp.uid
        join public.profiles a on a.id = v_author
        join public.device_tokens dt on dt.user_id = p.id
       where pp.uid is not null
         and pp.uid <> v_author
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
    )
    select dt.token, dt.platform, p.id,
           coalesce(a.display_name, a.username),
           v_item, left(v_body, 120),
           '/stories/' || v_post_author::text
      from people pp
      join public.profiles p on p.id = pp.uid
      join public.profiles a on a.id = v_author
      join public.device_tokens dt on dt.user_id = p.id
     where pp.uid <> v_author
       and p.social_notifications_enabled
       and not public.is_blocked_pair(v_author, p.id);
end;
$$;

-- ── surprise reveal targets ─────────────────────────────────────────────────
-- One row per (due gift, device); gifts without a device still come back
-- (token null) so the caller can mark them announced. `enabled` carries the
-- recipient's preference: mark regardless, send only when true.
create or replace function public.surprise_reveal_targets()
returns table (
  gift_id uuid,
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
  select g.id, dt.token, dt.platform, g.recipient_id,
         coalesce(giver.display_name, giver.username),
         g.item, r.social_notifications_enabled
    from public.gifts g
    join public.profiles r on r.id = g.recipient_id
    left join public.profiles giver on giver.id = g.giver_id
    left join public.device_tokens dt on dt.user_id = g.recipient_id
   where g.is_surprise
     and g.reveal_at <= now()
     and g.reveal_notified_at is null;
$$;

grant execute on function public.comment_push_targets(text, uuid) to service_role;
grant execute on function public.surprise_reveal_targets() to service_role;

-- ── comment → notify-comment (pg_net; cloud only) ──────────────────────────
create or replace function public.notify_comment_inserted()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
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
  return new;
end;
$$;

create trigger gift_comments_notify
  after insert on public.gift_comments
  for each row execute function public.notify_comment_inserted();

create trigger post_comments_notify
  after insert on public.post_comments
  for each row execute function public.notify_comment_inserted();

-- ── hourly: surprise-revealed (cloud only, re-runnable) ────────────────────
do $$
declare
  has_secret boolean;
begin
  select exists (
    select 1 from vault.decrypted_secrets where name = 'birthday_cron_secret'
  ) into has_secret;
  if not has_secret then
    raise notice 'surprise-revealed: no cron secret in Vault, schedule skipped';
    return;
  end if;

  if exists (select 1 from cron.job where jobname = 'surprise-revealed-hourly') then
    perform cron.unschedule('surprise-revealed-hourly');
  end if;

  perform cron.schedule(
    'surprise-revealed-hourly',
    '5 * * * *',
    $job$
      select net.http_post(
        url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/surprise-revealed',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'x-cron-secret',
          (select decrypted_secret from vault.decrypted_secrets
            where name = 'birthday_cron_secret')
        ),
        body := '{}'::jsonb
      );
    $job$
  );
end $$;
