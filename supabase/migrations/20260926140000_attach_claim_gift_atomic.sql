-- attach_claim_gift: the link is claimed atomically. Two records logged at
-- once (the organizer on two devices) must never both attach — the second
-- update finds the slot taken and the client rolls its record back.
create or replace function public.attach_claim_gift(p_claim uuid, p_gift uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  c  public.wishlist_claims%rowtype;
  g  public.gifts%rowtype;
  v_event uuid;
begin
  select * into c from public.wishlist_claims where id = p_claim;
  if c.id is null or c.claimer_id <> me then
    raise exception 'not your claim' using errcode = '42501';
  end if;
  select * into g from public.gifts where id = p_gift;
  if g.id is null or g.giver_id <> me or g.recipient_id <> c.owner_id then
    raise exception 'gift does not match the claim' using errcode = '42501';
  end if;

  update public.wishlist_claims
     set gift_id = p_gift
   where id = p_claim and gift_id is null;
  if not found then
    raise exception 'claim already has a gift' using errcode = 'check_violation';
  end if;

  if c.kind = 'shared' then
    insert into public.gift_contributors (gift_id, user_id, amount)
    select p_gift, p.user_id, p.amount
      from public.claim_pledges p
     where p.claim_id = p_claim and p.user_id <> me
    on conflict do nothing;
  end if;

  if g.event_id is null then
    select e.id into v_event
      from public.gift_events e
      join public.gift_event_members m on m.event_id = e.id
     where e.honoree_id = c.owner_id
       and e.status <> 'cancelled'
       and m.user_id = me and m.status = 'joined'
     order by e.event_date
     limit 1;
    if v_event is not null then
      update public.gifts
         set event_id = v_event, is_surprise = true,
             reveal_at = coalesce(reveal_at, now())
       where id = p_gift;
    end if;
  end if;
end;
$$;
