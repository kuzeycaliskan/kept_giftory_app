-- ============================================================================
-- G-63: notification preferences.
-- V1 has exactly one push type (birthday reminders), so the preference is a
-- single column on profiles — no separate prefs table until V2 multiplies
-- notification kinds. The dispatch query filters server-side: opting out
-- stops the send, not just the display. RLS is free (own-row update).
-- ============================================================================

alter table public.profiles
  add column birthday_reminders_enabled boolean not null default true;

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
    -- The recipient opted out of birthday reminders (G-63).
    and friend.birthday_reminders_enabled
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

revoke execute on function
  public.birthday_reminder_targets(text, boolean, date)
  from public, anon, authenticated;
