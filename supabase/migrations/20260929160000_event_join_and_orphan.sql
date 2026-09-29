-- Review hardening, round 3 (29 Sep 2026).
--
-- 1. create_gift_event joined the honoree's existing event whatever its
--    state — including one the organizer revealed early. A revealed event
--    is an archive: it returns to existing members, refuses newcomers.
-- 2. An organizer deleting their account left the event without anyone
--    who could reveal early, invite or delete. When the organizer's row
--    cascades away from an open event, the earliest joined member becomes
--    organizer; with nobody left, the event goes.

create or replace function public.create_gift_event(p_honoree uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  bday date;
  target date;
  v_event uuid;
  v_status public.event_status;
begin
  if me is null or me = p_honoree then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  if not public.are_friends(me, p_honoree) or public.is_blocked_pair(me, p_honoree) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  select birthday into bday from public.profiles where id = p_honoree;
  if bday is null then
    raise exception 'honoree has no birthday' using errcode = 'check_violation';
  end if;
  target := public.next_birthday(bday, (now() at time zone 'Europe/Istanbul')::date);

  select id, status into v_event, v_status from public.gift_events
   where honoree_id = p_honoree and event_date = target and status <> 'cancelled';

  if v_event is null then
    insert into public.gift_events (honoree_id, creator_id, event_date, reveal_at)
    values (
      p_honoree, me, target,
      ((target + 1)::timestamp at time zone 'Europe/Istanbul')
    )
    returning id into v_event;
    insert into public.gift_event_members (event_id, user_id, role, status, invited_by, responded_at)
    values (v_event, me, 'organizer', 'joined', me, now());
  elsif v_status = 'revealed' then
    -- An archive: members keep their way in, nobody new joins.
    if not exists (
      select 1 from public.gift_event_members m
      where m.event_id = v_event and m.user_id = me and m.status = 'joined'
    ) then
      raise exception 'event already revealed' using errcode = 'check_violation';
    end if;
  else
    -- Someone was first: join theirs (friends of the honoree may always join).
    insert into public.gift_event_members (event_id, user_id, role, status, invited_by, responded_at)
    values (v_event, me, 'member', 'joined', me, now())
    on conflict (event_id, user_id) do update
      set status = 'joined', responded_at = now()
      where public.gift_event_members.status <> 'joined';
  end if;
  return v_event;
end;
$$;

create or replace function public.reassign_event_organizer()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_next uuid;
begin
  if old.role <> 'organizer' then
    return old;
  end if;
  -- Event already gone (its own deletion cascaded here) or archived: nothing.
  if not exists (
    select 1 from public.gift_events e where e.id = old.event_id and e.status = 'open'
  ) then
    return old;
  end if;
  select m.user_id into v_next
    from public.gift_event_members m
   where m.event_id = old.event_id and m.status = 'joined'
   order by m.created_at
   limit 1;
  if v_next is null then
    delete from public.gift_events where id = old.event_id;
  else
    -- The member guard freezes roles for clients; the machine may promote.
    perform set_config('kept.reveal', 'on', true);
    update public.gift_event_members set role = 'organizer'
     where event_id = old.event_id and user_id = v_next;
  end if;
  return old;
end;
$$;

-- Members change only their own status; the role changes only when the
-- state machine hands the event to a new organizer.
create or replace function public.guard_gift_event_member_update()
returns trigger
language plpgsql
as $$
begin
  new.event_id   := old.event_id;
  new.user_id    := old.user_id;
  if coalesce(current_setting('kept.reveal', true), '') <> 'on' then
    new.role := old.role;
  end if;
  new.invited_by := old.invited_by;
  new.created_at := old.created_at;
  if new.status <> old.status then
    new.responded_at := now();
  end if;
  return new;
end;
$$;

create trigger gift_event_members_reassign_organizer
  after delete on public.gift_event_members
  for each row execute function public.reassign_event_organizer();

-- 3. The event guard froze creator_id so hard that the FK's own
--    ON DELETE SET NULL was rejected — deleting the account of anyone who
--    ever created an event failed. Identity may be cleared, never moved.
create or replace function public.guard_gift_event_update()
returns trigger
language plpgsql
as $$
declare
  by_machine boolean := coalesce(current_setting('kept.reveal', true), '') = 'on';
begin
  new.honoree_id := old.honoree_id;
  if new.creator_id is not null then
    new.creator_id := old.creator_id;
  end if;
  new.event_date := old.event_date;
  new.reveal_at  := old.reveal_at;
  new.created_at := old.created_at;
  if not by_machine then
    new.revealed_at        := old.revealed_at;
    new.reveal_notified_at := old.reveal_notified_at;
    if new.status = 'revealed' and old.status <> 'revealed' then
      new.status := old.status;
    end if;
  end if;
  if auth.uid() = old.honoree_id then
    new.status            := old.status;
    new.external_chat_url := old.external_chat_url;
    if new.thanks_note is null then
      new.thanks_note := old.thanks_note;
      new.thanks_at   := old.thanks_at;
    elsif old.thanks_note is null then
      new.thanks_at := now();
    else
      new.thanks_at := old.thanks_at;
    end if;
  else
    new.thanks_note := old.thanks_note;
    new.thanks_at   := old.thanks_at;
  end if;
  return new;
end;
$$;
