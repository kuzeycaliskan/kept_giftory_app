-- Review hardening, round 2 (29 Sep 2026).
--
-- 1. Storage never leaks: whenever a gift photo ROW goes (the user removed
--    it, the gift was deleted, a claim was released, an event was deleted),
--    its object is queued and the hourly purge job removes it. Removing an
--    already-removed object is a no-op for the Storage API, so the client's
--    best-effort delete and the queue converge.
-- 2. Account deletion must never be blocked by the claim/pledge guards:
--    when the claimer's or pledger's profile is gone, their rows cascade —
--    that is neither a release nor a withdrawal.
-- 3. An organizer cannot leave their open event (the event would have no
--    one to reveal early, invite or delete); they delete it instead.

create table public.storage_purge_queue (
  id         bigserial primary key,
  bucket     text not null,
  path       text not null,
  queued_at  timestamptz not null default now()
);
alter table public.storage_purge_queue enable row level security;
grant select, delete on public.storage_purge_queue to service_role;

create or replace function public.enqueue_gift_photo_purge()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.storage_purge_queue (bucket, path)
  values ('gift-media', old.media_path);
  return old;
end;
$$;

create trigger gift_photos_enqueue_purge
  after delete on public.gift_photos
  for each row execute function public.enqueue_gift_photo_purge();

-- ── claim guards: cascades from a vanished user are not releases ─────────────
create or replace function public.guard_claim_release()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  g public.gifts%rowtype;
begin
  if old.gift_id is null then
    return old;
  end if;
  if not exists (select 1 from public.wishlist_items w where w.id = old.item_id)
     or not exists (select 1 from public.profiles p where p.id = old.claimer_id) then
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

create or replace function public.drop_released_claim_gift()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.gift_id is not null
     and exists (select 1 from public.wishlist_items w where w.id = old.item_id)
     and exists (select 1 from public.profiles p where p.id = old.claimer_id) then
    delete from public.gifts where id = old.gift_id;
  end if;
  return old;
end;
$$;

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
  v_total numeric(12, 2);
  v_claim uuid := coalesce(new.claim_id, old.claim_id);
begin
  select c.kind, c.target_amount, c.gift_id into v_kind, v_target, v_gift
  from public.wishlist_claims c
  where c.id = v_claim;
  if tg_op = 'DELETE' and (
       v_kind is null
       or not exists (select 1 from public.profiles p where p.id = old.user_id)
     ) then
    -- The claim or the pledger is going away; the pledge cascades.
    return old;
  end if;
  if v_kind is distinct from 'shared' then
    raise exception 'pledges require a group gift' using errcode = 'check_violation';
  end if;
  if v_gift is not null then
    raise exception 'the group gift is already logged' using errcode = 'check_violation';
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

-- ── the organizer stays ──────────────────────────────────────────────────────
drop policy gift_event_members_delete on public.gift_event_members;
create policy gift_event_members_delete on public.gift_event_members
  for delete to authenticated
  using (
    user_id = auth.uid()
    and role <> 'organizer'
    and exists (
      select 1 from public.gift_events e
      where e.id = event_id and e.status = 'open'
    )
  );
