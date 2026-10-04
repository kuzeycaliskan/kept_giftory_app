-- Pool rules, round 2 (Kuzey, 5 Oct 2026).
-- 1. Exact expiry: an overdue pool takes no pledge (even before the sweep),
--    is invisible to readers, and the sweep runs every minute.
-- 2. The organizer may edit the price; the clock follows: under the new
--    price with no clock → a fresh day; at or over it → clock off.
-- 3. The owner removing the item tells the pool's people (BEFORE the
--    cascade takes the pledges away).
-- 4. A reminder two hours before the end (once).

alter table public.wishlist_claims add column reminded_at timestamptz;

-- ── 1. exact expiry ──────────────────────────────────────────────────────────
drop policy wishlist_claims_select on public.wishlist_claims;
create policy wishlist_claims_select on public.wishlist_claims
  for select to authenticated
  using (
    owner_id <> auth.uid()
    and public.are_friends(owner_id, auth.uid())
    and public.can_view_wishlist(owner_id)
    and (expires_at is null or expires_at > now())
  );

create or replace function public.guard_pledge_kind()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_target numeric(12, 2);
  v_kind public.claim_kind;
  v_gift uuid;
  v_expires timestamptz;
  v_total numeric(12, 2);
  v_claim uuid := coalesce(new.claim_id, old.claim_id);
begin
  select c.kind, c.target_amount, c.gift_id, c.expires_at
    into v_kind, v_target, v_gift, v_expires
  from public.wishlist_claims c
  where c.id = v_claim;
  if tg_op = 'DELETE' and (
       v_kind is null
       or not exists (select 1 from public.profiles p where p.id = old.user_id)
     ) then
    return old;
  end if;
  if v_kind is distinct from 'shared' then
    raise exception 'pledges require a group gift' using errcode = 'check_violation';
  end if;
  if v_gift is not null then
    raise exception 'the group gift is already logged' using errcode = 'check_violation';
  end if;
  if tg_op <> 'DELETE' and v_expires is not null and v_expires <= now() then
    raise exception 'the group gift has expired' using errcode = 'check_violation';
  end if;
  if tg_op = 'INSERT' and v_target is not null then
    select coalesce(sum(p.amount), 0) into v_total
    from public.claim_pledges p
    where p.claim_id = new.claim_id;
    if v_total >= v_target then
      raise exception 'the group gift is fully funded' using errcode = 'check_violation';
    end if;
  end if;
  return coalesce(new, old);
end;
$$;

-- A new claim on an item whose expired pool has not been swept yet takes
-- its place: the sweep would remove it within the minute anyway.
create or replace function public.replace_expired_pool()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.wishlist_claims c
   where c.item_id = new.item_id and c.kind = 'shared' and c.gift_id is null
     and c.expires_at is not null and c.expires_at <= now();
  return new;
end;
$$;
create trigger wishlist_claims_replace_expired
  before insert on public.wishlist_claims
  for each row execute function public.replace_expired_pool();

-- ── 2. price edits move the clock ────────────────────────────────────────────
create or replace function public.guard_pool_price()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total numeric(12, 2);
begin
  if new.kind = 'shared' and new.target_amount is null then
    raise exception 'a group gift needs the product price'
      using errcode = 'check_violation';
  end if;
  if new.kind = 'shared' and new.gift_id is null
     and (tg_op = 'INSERT' or old.kind <> 'shared') then
    new.expires_at := now() + interval '24 hours';
    new.reminded_at := null;
  end if;
  if tg_op = 'UPDATE' and new.kind = 'shared' and new.gift_id is null
     and new.target_amount is distinct from old.target_amount then
    select coalesce(sum(p.amount), 0) into v_total
      from public.claim_pledges p where p.claim_id = new.id;
    if v_total >= new.target_amount then
      new.expires_at := null;
    elsif new.expires_at is null then
      new.expires_at := now() + interval '24 hours';
      new.reminded_at := null;
    end if;
  end if;
  if new.gift_id is not null or new.kind <> 'shared' then
    new.expires_at := null;
  end if;
  return new;
end;
$$;

-- ── 3. item removed → tell the pool's people ─────────────────────────────────
create or replace function public.guard_claim_release()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  g public.gifts%rowtype;
  secret text;
  v_people uuid[];
  v_title text;
begin
  -- Cascade from a vanished item: notify the people, keep any gift.
  if not exists (select 1 from public.wishlist_items w where w.id = old.item_id) then
    if old.kind = 'shared' and old.gift_id is null
       and exists (select 1 from public.profiles p where p.id = old.claimer_id) then
      select array_agg(distinct u) into v_people
        from unnest(array_append(
          (select coalesce(array_agg(p.user_id), '{}') from public.claim_pledges p
            where p.claim_id = old.id),
          old.claimer_id)) u;
      select lp.title into v_title from public.link_previews lp
        join public.wishlist_items w on w.link_preview_id = lp.id where w.id = old.item_id;
      begin
        select decrypted_secret into secret
          from vault.decrypted_secrets where name = 'birthday_cron_secret';
        if secret is not null and coalesce(array_length(v_people, 1), 0) > 0 then
          perform net.http_post(
            url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-pool-removed',
            headers := jsonb_build_object(
              'Content-Type', 'application/json',
              'x-cron-secret', secret
            ),
            body := jsonb_build_object(
              'user_ids', to_jsonb(v_people),
              'item_title', v_title
            )
          );
        end if;
      exception when others then
        raise warning 'guard_claim_release notify: % (claim %)', sqlerrm, old.id;
      end;
    end if;
    return old;
  end if;
  if old.gift_id is null then
    return old;
  end if;
  if not exists (select 1 from public.profiles p where p.id = old.claimer_id) then
    return old;
  end if;
  select * into g from public.gifts where id = old.gift_id;
  if g.id is not null and (not g.is_surprise or g.reveal_at <= now()) then
    raise exception 'the gift has already been given'
      using errcode = 'check_violation';
  end if;
  return old;
end;
$$;

-- ── 4. reminders ─────────────────────────────────────────────────────────────
create or replace function public.pool_reminder_targets()
returns table (claim_id uuid, item_title text, organizer_id uuid, total numeric, target numeric, expires_at timestamptz)
language sql
security definer
set search_path = public
stable
as $$
  select c.id, coalesce(lp.title, w.title), c.claimer_id,
         (select coalesce(sum(p.amount), 0) from public.claim_pledges p where p.claim_id = c.id),
         c.target_amount, c.expires_at
    from public.wishlist_claims c
    join public.wishlist_items w on w.id = c.item_id
    left join public.link_previews lp on lp.id = w.link_preview_id
   where c.kind = 'shared' and c.gift_id is null and c.reminded_at is null
     and c.expires_at is not null
     and c.expires_at > now() and c.expires_at <= now() + interval '2 hours';
$$;
revoke execute on function public.pool_reminder_targets() from public, anon, authenticated;
grant execute on function public.pool_reminder_targets() to service_role;

create or replace function public.mark_pools_reminded(p_ids uuid[])
returns void
language sql
security definer
set search_path = public
as $$
  update public.wishlist_claims set reminded_at = now()
   where id = any(p_ids) and reminded_at is null;
$$;
revoke execute on function public.mark_pools_reminded(uuid[]) from public, anon, authenticated;
grant execute on function public.mark_pools_reminded(uuid[]) to service_role;

-- ── sweep every minute ───────────────────────────────────────────────────────
do $$
declare
  has_secret boolean;
begin
  select exists (
    select 1 from vault.decrypted_secrets where name = 'birthday_cron_secret'
  ) into has_secret;
  if not has_secret then
    raise notice 'expire-pools: no cron secret in Vault, schedule skipped';
    return;
  end if;
  if exists (select 1 from cron.job where jobname = 'expire-pools-hourly') then
    perform cron.unschedule('expire-pools-hourly');
  end if;
  if exists (select 1 from cron.job where jobname = 'expire-pools-minutely') then
    perform cron.unschedule('expire-pools-minutely');
  end if;
  perform cron.schedule(
    'expire-pools-minutely',
    '* * * * *',
    $job$
      select net.http_post(
        url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/expire-pools',
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
