-- ============================================================================
-- G-62: idempotency log for birthday reminders.
-- One row per (notified friend, birthday person, that birthday date) — the
-- Edge Function inserts before sending; a rerun (cron overlap, retry) hits
-- the PK and skips. Service-role only: RLS enabled with no policies.
-- ============================================================================

create table public.birthday_reminder_log (
  notified_user uuid not null references public.profiles (id) on delete cascade,
  birthday_user uuid not null references public.profiles (id) on delete cascade,
  birthday_on   date not null,
  sent_at       timestamptz not null default now(),
  primary key (notified_user, birthday_user, birthday_on)
);

alter table public.birthday_reminder_log enable row level security;
-- no policies: clients can never touch this table (default deny).

-- ── Dispatch target query (service-role only) ───────────────────────────────
-- All filtering happens here in one pass:
--  * birthday people whose celebrated MM-DD is p_mmdd (+ Feb-29 → Mar 1);
--  * each accepted friend of theirs, joined to that friend's device tokens;
--  * minus friends already notified for this birthday (idempotency log);
--  * minus friends who already logged a gift for them this cycle (45 days).
create or replace function public.birthday_reminder_targets(
  p_mmdd text,
  p_include_feb29 boolean,
  p_birthday_on date
)
returns table (
  token text,
  platform text,
  notified_user uuid,
  birthday_user uuid,
  birthday_label text,
  birthday_on date
)
language sql
security definer
set search_path = public
stable
as $$
  select
    dt.token,
    dt.platform,
    friend.id as notified_user,
    p.id as birthday_user,
    coalesce(p.display_name, p.username) as birthday_label,
    p_birthday_on as birthday_on
  from public.profiles p
  join public.friendships fr
    on fr.status = 'accepted'
   and (fr.requester_id = p.id or fr.addressee_id = p.id)
  join public.profiles friend
    on friend.id = case
         when fr.requester_id = p.id then fr.addressee_id
         else fr.requester_id
       end
  join public.device_tokens dt on dt.user_id = friend.id
  where p.birthday is not null
    and (
      to_char(p.birthday, 'MM-DD') = p_mmdd
      or (p_include_feb29 and to_char(p.birthday, 'MM-DD') = '02-29')
    )
    and not exists (
      select 1 from public.birthday_reminder_log l
      where l.notified_user = friend.id
        and l.birthday_user = p.id
        and l.birthday_on = p_birthday_on
    )
    and not exists (
      select 1 from public.gifts g
      where g.giver_id = friend.id
        and g.recipient_id = p.id
        and g.created_at >= (p_birthday_on::timestamptz - interval '45 days')
    );
$$;

-- Service-role only: strip the default PUBLIC execute grant.
revoke execute on function
  public.birthday_reminder_targets(text, boolean, date)
  from public, anon, authenticated;
