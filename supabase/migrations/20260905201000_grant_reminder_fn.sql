-- Revoking PUBLIC execute also stripped service_role — grant it back
-- explicitly (the Edge Function runs as service_role).
grant execute on function
  public.birthday_reminder_targets(text, boolean, date)
  to service_role;
