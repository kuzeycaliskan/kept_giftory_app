-- Clean event deletion (Kuzey, 26 Sep 2026). The organizer removes an OPEN
-- event outright: members, invitations and the notes board cascade away;
-- logged gifts keep existing (event_id → null) and reservations are not
-- touched — the event was only the coordination space. A revealed event is
-- the honoree's memory (and thanks) and cannot be deleted.
--
-- Also: the one-event-per-birthday rule must ignore cancelled rows, or a
-- cancelled event blocks opening a new one for the same date.
alter table public.gift_events drop constraint gift_events_one_per_birthday;
create unique index gift_events_one_per_birthday
  on public.gift_events (honoree_id, event_date)
  where status <> 'cancelled';

create policy gift_events_delete on public.gift_events
  for delete to authenticated
  using (public.is_event_organizer(id, auth.uid()) and status = 'open');
