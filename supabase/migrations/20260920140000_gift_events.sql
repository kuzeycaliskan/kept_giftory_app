-- ============================================================================
-- Kept — Gift events (V3.0-a: G-301 create + suggest, G-302 invite/join).
-- Decisions 2026-09-20: only the honoree's friends open an event; the
-- honoree never sees it (rows are invisible to them until G-306 reveal);
-- 14 days before the birthday every friend is nudged; the first to act
-- opens the event, later friends join it.
--
-- Access: events and members are visible only to members (invited/joined)
-- and never to the honoree; creation/invite/response go through definer
-- RPCs that enforce friendship with the honoree, one event per honoree per
-- birthday, and block rules. Organizers may cancel and set the group link.
-- ============================================================================

create type public.event_status as enum ('open', 'revealed', 'cancelled');
create type public.event_member_role as enum ('organizer', 'member');
create type public.event_member_status as enum ('invited', 'joined', 'declined');

create table public.gift_events (
  id                 uuid primary key default gen_random_uuid(),
  honoree_id         uuid not null references public.profiles (id) on delete cascade,
  creator_id         uuid references public.profiles (id) on delete set null,
  event_date         date not null,
  reveal_at          timestamptz not null,
  status             public.event_status not null default 'open',
  external_chat_url  text,
  created_at         timestamptz not null default now(),
  constraint gift_events_chat_url_http
    check (external_chat_url is null or external_chat_url ~* '^https?://'),
  constraint gift_events_one_per_birthday unique (honoree_id, event_date)
);

create table public.gift_event_members (
  event_id      uuid not null references public.gift_events (id) on delete cascade,
  user_id       uuid not null references public.profiles (id) on delete cascade,
  role          public.event_member_role not null default 'member',
  status        public.event_member_status not null default 'invited',
  invited_by    uuid references public.profiles (id) on delete set null,
  created_at    timestamptz not null default now(),
  responded_at  timestamptz,
  primary key (event_id, user_id)
);
create index gift_event_members_user_idx on public.gift_event_members (user_id);

-- ── helpers ─────────────────────────────────────────────────────────────────
-- Next occurrence of a birthday on/after `today` (Feb 29 → Mar 1 off-leap),
-- mirroring the app's birthday_math.
create or replace function public.next_birthday(p_birthday date, p_today date)
returns date
language plpgsql
immutable
as $$
declare
  candidate date;
  yr integer := extract(year from p_today)::integer;
begin
  candidate := public.birthday_in_year(p_birthday, yr);
  if candidate < p_today then
    candidate := public.birthday_in_year(p_birthday, yr + 1);
  end if;
  return candidate;
end;
$$;

create or replace function public.birthday_in_year(p_birthday date, p_year integer)
returns date
language sql
immutable
as $$
  select case
    when extract(month from p_birthday) = 2 and extract(day from p_birthday) = 29
         and not (p_year % 4 = 0 and (p_year % 100 <> 0 or p_year % 400 = 0))
      then make_date(p_year, 3, 1)
    else make_date(p_year, extract(month from p_birthday)::int, extract(day from p_birthday)::int)
  end;
$$;

-- Membership check usable inside policies (definer: reads across RLS).
create or replace function public.is_event_member(p_event uuid, p_user uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.gift_event_members m
    where m.event_id = p_event and m.user_id = p_user
      and m.status in ('invited', 'joined')
  );
$$;

create or replace function public.is_event_organizer(p_event uuid, p_user uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.gift_event_members m
    where m.event_id = p_event and m.user_id = p_user
      and m.role = 'organizer' and m.status = 'joined'
  );
$$;

-- ── grants + RLS ────────────────────────────────────────────────────────────
-- No insert grants: creation and invites go through the RPCs below.
grant select, update on public.gift_events to authenticated;
grant select, update, delete on public.gift_event_members to authenticated;
grant select, update on public.gift_events to service_role;
grant select on public.gift_event_members to service_role;

alter table public.gift_events enable row level security;
alter table public.gift_event_members enable row level security;

-- The honoree is excluded by construction (they are never a member and
-- the policy re-checks), so nothing about the event reaches them.
create policy gift_events_select on public.gift_events
  for select to authenticated
  using (honoree_id <> auth.uid() and public.is_event_member(id, auth.uid()));

create policy gift_events_update on public.gift_events
  for update to authenticated
  using (public.is_event_organizer(id, auth.uid()))
  with check (public.is_event_organizer(id, auth.uid()));

create policy gift_event_members_select on public.gift_event_members
  for select to authenticated
  using (
    public.is_event_member(event_id, auth.uid())
    and not public.is_blocked_pair(auth.uid(), user_id)
    and not exists (
      select 1 from public.gift_events e
      where e.id = event_id and e.honoree_id = auth.uid()
    )
  );

-- Respond to my own invite (status only; the trigger guards the rest).
create policy gift_event_members_update on public.gift_event_members
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Leave.
create policy gift_event_members_delete on public.gift_event_members
  for delete to authenticated
  using (user_id = auth.uid());

-- Organizers edit status + chat link only; identity/date columns are frozen.
create or replace function public.guard_gift_event_update()
returns trigger
language plpgsql
as $$
begin
  new.honoree_id := old.honoree_id;
  new.creator_id := old.creator_id;
  new.event_date := old.event_date;
  new.reveal_at  := old.reveal_at;
  new.created_at := old.created_at;
  if new.status = 'revealed' and old.status <> 'revealed' then
    -- Reveal is the state machine's job (G-306), never a client update.
    new.status := old.status;
  end if;
  return new;
end;
$$;
create trigger gift_events_guard_update
  before update on public.gift_events
  for each row execute function public.guard_gift_event_update();

-- Members change only their own status (invited → joined/declined).
create or replace function public.guard_gift_event_member_update()
returns trigger
language plpgsql
as $$
begin
  new.event_id   := old.event_id;
  new.user_id    := old.user_id;
  new.role       := old.role;
  new.invited_by := old.invited_by;
  new.created_at := old.created_at;
  if new.status <> old.status then
    new.responded_at := now();
  end if;
  return new;
end;
$$;
create trigger gift_event_members_guard_update
  before update on public.gift_event_members
  for each row execute function public.guard_gift_event_member_update();

-- ── RPC: create (or join the existing) event for a friend's next birthday ──
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

  select id into v_event from public.gift_events
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

-- ── RPC: invite one of the honoree's friends ────────────────────────────────
create or replace function public.invite_to_gift_event(p_event uuid, p_user uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  v_honoree uuid;
  v_status public.event_status;
begin
  select honoree_id, status into v_honoree, v_status from public.gift_events where id = p_event;
  if v_honoree is null or v_status <> 'open' then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.gift_event_members
    where event_id = p_event and user_id = me and status = 'joined'
  ) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  if p_user = v_honoree
     or not public.are_friends(p_user, v_honoree)
     or public.is_blocked_pair(me, p_user) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  insert into public.gift_event_members (event_id, user_id, role, status, invited_by)
  values (p_event, p_user, 'member', 'invited', me)
  on conflict (event_id, user_id) do nothing;
end;
$$;

-- ── RPC: who can still be invited (honoree's friends, minus members) ────────
create or replace function public.event_invitable_friends(p_event uuid)
returns table (id uuid, username text, display_name text, avatar_url text)
language sql
security definer
set search_path = public
stable
as $$
  select p.id, p.username, p.display_name, p.avatar_url
    from public.gift_events e
    join public.friendships f
      on f.status = 'accepted'
     and (f.requester_id = e.honoree_id or f.addressee_id = e.honoree_id)
    join public.profiles p
      on p.id = case when f.requester_id = e.honoree_id then f.addressee_id else f.requester_id end
   where e.id = p_event
     and public.is_event_member(p_event, auth.uid())
     and e.honoree_id <> auth.uid()
     and p.id <> auth.uid()
     and not public.is_blocked_pair(auth.uid(), p.id)
     and not exists (
       select 1 from public.gift_event_members m
       where m.event_id = p_event and m.user_id = p.id
     )
   order by coalesce(p.display_name, p.username);
$$;

-- ── RPC: the open event for a friend's next birthday, from my side ──────────
-- Powers the Home row ("open" vs "go to event"). Returns nothing when there
-- is no event I could see; never callable about myself.
create or replace function public.gift_event_for_honoree(p_honoree uuid)
returns table (event_id uuid, event_date date, my_status public.event_member_status)
language sql
security definer
set search_path = public
stable
as $$
  select e.id, e.event_date, m.status
    from public.gift_events e
    left join public.gift_event_members m
      on m.event_id = e.id and m.user_id = auth.uid()
   where e.honoree_id = p_honoree
     and p_honoree <> auth.uid()
     and e.status = 'open'
     and e.event_date >= (now() at time zone 'Europe/Istanbul')::date
     and public.are_friends(auth.uid(), p_honoree)
   order by e.event_date
   limit 1;
$$;

revoke execute on function public.create_gift_event(uuid) from public, anon;
revoke execute on function public.invite_to_gift_event(uuid, uuid) from public, anon;
revoke execute on function public.event_invitable_friends(uuid) from public, anon;
revoke execute on function public.gift_event_for_honoree(uuid) from public, anon;
revoke execute on function public.is_event_member(uuid, uuid) from public, anon;
revoke execute on function public.is_event_organizer(uuid, uuid) from public, anon;
grant execute on function
  public.create_gift_event(uuid),
  public.invite_to_gift_event(uuid, uuid),
  public.event_invitable_friends(uuid),
  public.gift_event_for_honoree(uuid),
  public.is_event_member(uuid, uuid),
  public.is_event_organizer(uuid, uuid)
to authenticated;

-- ── 14-day suggestion push: second reminder kind on the same pipeline ──────
alter table public.birthday_reminder_log
  add column kind text not null default 'reminder';
alter table public.birthday_reminder_log
  drop constraint birthday_reminder_log_pkey;
alter table public.birthday_reminder_log
  add primary key (notified_user, birthday_user, birthday_on, kind);

do $$
declare
  has_secret boolean;
begin
  select exists (
    select 1 from vault.decrypted_secrets where name = 'birthday_cron_secret'
  ) into has_secret;
  if not has_secret then
    raise notice 'event-suggestion: no cron secret in Vault, schedule skipped';
    return;
  end if;
  if exists (select 1 from cron.job where jobname = 'event-suggestion-daily') then
    perform cron.unschedule('event-suggestion-daily');
  end if;
  perform cron.schedule(
    'event-suggestion-daily',
    '10 6 * * *',
    $job$
      select net.http_post(
        url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/birthday-reminders?days=14&kind=event',
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
