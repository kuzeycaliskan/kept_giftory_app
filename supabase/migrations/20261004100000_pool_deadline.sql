-- Group gifts live 24 hours (Kuzey, 4 Oct 2026). A pool that has not
-- reached its price within a day is removed outright — pledges and all —
-- and its people are told. Reaching the price (or logging the gift) stops
-- the clock; falling back under it (a withdrawal) starts a fresh day.
-- The rule needs a price to measure against, so every pool has one.

alter table public.wishlist_claims
  add column expires_at timestamptz;
create index wishlist_claims_expires_idx
  on public.wishlist_claims (expires_at) where expires_at is not null;

-- Pools carry a price: new rows and solo→shared conversions.
create or replace function public.guard_pool_price()
returns trigger
language plpgsql
as $$
begin
  if new.kind = 'shared' and new.target_amount is null then
    raise exception 'a group gift needs the product price'
      using errcode = 'check_violation';
  end if;
  if new.kind = 'shared' and new.gift_id is null
     and (tg_op = 'INSERT' or old.kind <> 'shared') then
    new.expires_at := now() + interval '24 hours';
  end if;
  if new.gift_id is not null or new.kind <> 'shared' then
    new.expires_at := null;
  end if;
  return new;
end;
$$;

create trigger wishlist_claims_pool_price
  before insert or update on public.wishlist_claims
  for each row execute function public.guard_pool_price();

-- The clock follows the money: funded → no deadline; under again → a new day.
create or replace function public.refresh_pool_deadline()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_claim uuid := coalesce(new.claim_id, old.claim_id);
  v_target numeric(12, 2);
  v_total numeric(12, 2);
  v_expires timestamptz;
  v_gift uuid;
begin
  select c.target_amount, c.expires_at, c.gift_id into v_target, v_expires, v_gift
    from public.wishlist_claims c where c.id = v_claim;
  if v_target is null or v_gift is not null then
    return coalesce(new, old);
  end if;
  select coalesce(sum(p.amount), 0) into v_total
    from public.claim_pledges p where p.claim_id = v_claim;
  if v_total >= v_target then
    update public.wishlist_claims set expires_at = null where id = v_claim;
  elsif v_expires is null then
    update public.wishlist_claims set expires_at = now() + interval '24 hours'
     where id = v_claim;
  end if;
  return coalesce(new, old);
end;
$$;

create trigger claim_pledges_refresh_deadline
  after insert or update or delete on public.claim_pledges
  for each row execute function public.refresh_pool_deadline();

-- Service: remove pools past their day, hand back who to tell.
create or replace function public.expire_pools()
returns table (claim_id uuid, item_title text, user_ids uuid[])
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
    with due as (
      select c.id, c.claimer_id,
             coalesce(lp.title, w.title) as title,
             array_agg(p.user_id) filter (where p.user_id is not null) as pledgers
        from public.wishlist_claims c
        join public.wishlist_items w on w.id = c.item_id
        left join public.link_previews lp on lp.id = w.link_preview_id
        left join public.claim_pledges p on p.claim_id = c.id
       where c.kind = 'shared' and c.gift_id is null
         and c.expires_at is not null and c.expires_at <= now()
       group by c.id, c.claimer_id, lp.title, w.title
    ), gone as (
      delete from public.wishlist_claims c using due d where c.id = d.id
      returning d.id, d.title, d.claimer_id, d.pledgers
    )
    select g.id, g.title,
           array(select distinct u from unnest(array_append(coalesce(g.pledgers, '{}'), g.claimer_id)) u)
      from gone g;
end;
$$;
revoke execute on function public.expire_pools() from public, anon, authenticated;
grant execute on function public.expire_pools() to service_role;

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
  perform cron.schedule(
    'expire-pools-hourly',
    '20 * * * *',
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
