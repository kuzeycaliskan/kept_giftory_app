-- A group gift that reached its price takes no new participants (Kuzey,
-- 21 Sep 2026). Existing participants may still change their share — if
-- one lowers it, the pool reopens by itself. Pools without a price never
-- lock. Enforced here so the rule holds whatever the client shows.
create or replace function public.guard_pledge_kind()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_target numeric(12, 2);
  v_kind public.claim_kind;
  v_total numeric(12, 2);
begin
  select c.kind, c.target_amount into v_kind, v_target
  from public.wishlist_claims c
  where c.id = new.claim_id;
  if v_kind is distinct from 'shared' then
    raise exception 'pledges require a group gift' using errcode = 'check_violation';
  end if;
  if tg_op = 'INSERT' and v_target is not null then
    select coalesce(sum(p.amount), 0) into v_total
    from public.claim_pledges p
    where p.claim_id = new.claim_id;
    if v_total >= v_target then
      raise exception 'the group gift is fully funded' using errcode = 'check_violation';
    end if;
  end if;
  return new;
end;
$$;
