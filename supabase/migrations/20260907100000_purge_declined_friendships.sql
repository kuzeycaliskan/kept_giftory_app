-- Bugfix: declining a request used to flip status to 'declined' and KEEP the
-- row. The unique-pair index then blocked any future request between the two
-- forever, while the UI (which hides declined rows) still offered "Add
-- friend" → 23505 → "something went wrong". The client now deletes the row
-- on decline; purge legacy declined rows so stuck pairs can request again.
-- ('declined' stays in the enum — dropping enum values is not worth the
-- churn; nothing writes it anymore.)

delete from public.friendships where status = 'declined';
