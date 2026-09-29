-- A revealed event is an archive (Kuzey, 29 Sep 2026): who was in and who
-- gave what is history now. Membership stops changing — no leaving, no
-- answering old invitations (inviting was already open-only).
drop policy gift_event_members_update on public.gift_event_members;
create policy gift_event_members_update on public.gift_event_members
  for update to authenticated
  using (
    user_id = auth.uid()
    and exists (
      select 1 from public.gift_events e
      where e.id = event_id and e.status = 'open'
    )
  )
  with check (user_id = auth.uid());

drop policy gift_event_members_delete on public.gift_event_members;
create policy gift_event_members_delete on public.gift_event_members
  for delete to authenticated
  using (
    user_id = auth.uid()
    and exists (
      select 1 from public.gift_events e
      where e.id = event_id and e.status = 'open'
    )
  );
