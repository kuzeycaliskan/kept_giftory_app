-- G-410b — a person's own announced occasions ("my baby is due 12 March").
-- Friends see them on Home's Upcoming list (next to birthdays) and open the
-- gift event from there; an occasion nobody announced lives only in the
-- event. Visibility follows the profile (can_view_profile), the owner
-- alone writes, and a day in the past is refused.

create table public.special_days (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  kind        public.event_kind not null,
  title       text,
  day         date not null,
  created_at  timestamptz not null default now(),
  constraint special_days_not_birthday check (kind <> 'birthday'),
  constraint special_days_title_len
    check (title is null or char_length(title) between 1 and 60),
  constraint special_days_other_needs_title
    check (kind <> 'other' or title is not null),
  constraint special_days_one_per_occasion unique (user_id, kind, day)
);
create index special_days_user_day_idx on public.special_days (user_id, day);

comment on table public.special_days is
  'G-410b: occasions a user announces on their profile; friends see them as upcoming and open gift events from them.';

alter table public.special_days enable row level security;

create policy special_days_select on public.special_days
  for select to authenticated
  using (user_id = auth.uid() or public.can_view_profile(user_id));

create policy special_days_insert on public.special_days
  for insert to authenticated
  with check (user_id = auth.uid());

create policy special_days_update on public.special_days
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy special_days_delete on public.special_days
  for delete to authenticated
  using (user_id = auth.uid());

create or replace function public.guard_special_day()
returns trigger
language plpgsql
as $$
begin
  if new.day < (now() at time zone 'Europe/Istanbul')::date then
    raise exception 'special day in the past' using errcode = 'check_violation';
  end if;
  if new.kind <> 'other' then
    new.title := null;
  else
    new.title := nullif(btrim(coalesce(new.title, '')), '');
  end if;
  return new;
end;
$$;

create trigger special_days_guard
  before insert or update on public.special_days
  for each row execute function public.guard_special_day();

-- The Home row's lookup now knows which occasion it asks about. One
-- signature with defaults: the one-argument call keeps meaning "next
-- birthday".
drop function public.gift_event_for_honoree(uuid);
create function public.gift_event_for_honoree(
  p_honoree uuid,
  p_kind public.event_kind default 'birthday',
  p_date date default null
)
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
     and e.kind = p_kind
     and (p_date is null or e.event_date = p_date)
     and e.event_date >= (now() at time zone 'Europe/Istanbul')::date
     and public.are_friends(auth.uid(), p_honoree)
   order by e.event_date
   limit 1;
$$;
revoke execute on function public.gift_event_for_honoree(uuid, public.event_kind, date) from public, anon;
grant execute on function public.gift_event_for_honoree(uuid, public.event_kind, date) to authenticated;
