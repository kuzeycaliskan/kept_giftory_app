-- G-308 — unboxing moments. A moment (post) may point at a gift the author
-- received; the feed shows it as "opened a gift from …" and the giver (plus
-- group-gift contributors) hear about it. Rules, all server-side:
--   * only the gift's recipient may link it, and only once the gift is
--     open to them (never a pending surprise — RLS hides it, and this guard
--     says so explicitly);
--   * posts stay immutable (no update policy), so the link cannot move;
--   * the gift embed in feed reads follows gifts RLS: a viewer who may not
--     see the gift gets a bare "unboxing" tag, no giver, no item.

alter table public.posts
  add column gift_id uuid references public.gifts (id) on delete set null;
create index posts_gift_idx on public.posts (gift_id) where gift_id is not null;

comment on column public.posts.gift_id is
  'G-308: the received gift this moment unboxes (recipient-only, open gifts only).';

create or replace function public.guard_post_gift_link()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_recipient uuid;
  v_pending boolean;
begin
  if new.gift_id is null then
    return new;
  end if;
  select g.recipient_id, (g.is_surprise and g.reveal_at > now())
    into v_recipient, v_pending
    from public.gifts g where g.id = new.gift_id;
  if v_recipient is null or v_recipient <> new.author_id or v_pending then
    raise exception 'unboxing: only the recipient of an open gift can link it'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger posts_guard_gift_link
  before insert on public.posts
  for each row execute function public.guard_post_gift_link();

-- Who hears about an unboxing: the giver and every contributor, never the
-- author. Device-less people still get their inbox row (token null).
create or replace function public.unboxing_targets(p_post uuid)
returns table (
  token text,
  platform text,
  user_id uuid,
  author_id uuid,
  recipient_label text,
  item_label text,
  enabled boolean
)
language sql
security definer
set search_path = public
stable
as $$
  with people as (
    select g.giver_id as uid, p.author_id, g.id as gift_id
      from public.posts p
      join public.gifts g on g.id = p.gift_id
     where p.id = p_post
    union
    select gc.user_id, p.author_id, g.id
      from public.posts p
      join public.gifts g on g.id = p.gift_id
      join public.gift_contributors gc on gc.gift_id = g.id
     where p.id = p_post
  )
  select dt.token, dt.platform, pp.uid, pp.author_id,
         coalesce(r.display_name, r.username), g.item,
         pr.social_notifications_enabled
    from people pp
    join public.gifts g on g.id = pp.gift_id
    join public.profiles r on r.id = pp.author_id
    join public.profiles pr on pr.id = pp.uid
    left join public.device_tokens dt on dt.user_id = pp.uid
   where pp.uid is not null
     and pp.uid <> pp.author_id
     and not public.is_blocked_pair(pp.uid, pp.author_id);
$$;
revoke execute on function public.unboxing_targets(uuid) from public, anon, authenticated;
grant execute on function public.unboxing_targets(uuid) to service_role;

create or replace function public.notify_unboxing()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
begin
  if new.gift_id is null then
    return new;
  end if;
  begin
    select decrypted_secret into secret
      from vault.decrypted_secrets where name = 'birthday_cron_secret';
    if secret is null then
      return new; -- local / no cloud wiring
    end if;
    perform net.http_post(
      url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-unboxing',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-cron-secret', secret
      ),
      body := jsonb_build_object('post_id', new.id)
    );
  exception when others then
    raise warning 'notify_unboxing: % (post %)', sqlerrm, new.id;
  end;
  return new;
end;
$$;

create trigger posts_notify_unboxing
  after insert on public.posts
  for each row execute function public.notify_unboxing();
