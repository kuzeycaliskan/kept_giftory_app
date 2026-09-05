-- Fix: the birthday-reminders Edge Function runs as service_role and must
-- write the idempotency log and prune stale device tokens. Explicit grants
-- (RLS stays deny-all on the log; service_role bypasses RLS but still needs
-- table privileges).
grant insert, select, delete on public.birthday_reminder_log to service_role;
grant select, delete on public.device_tokens to service_role;
