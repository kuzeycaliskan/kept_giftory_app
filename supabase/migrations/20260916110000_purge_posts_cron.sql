-- G-203: hourly purge schedule, expressed as a migration (CLAUDE.md §11: no
-- console-only prod state). Cloud-only by construction: the job is created
-- only where the Vault secret exists (local stacks skip silently). Reads the
-- secret at run time, like the birthday-reminders job, so rotating it needs
-- no reschedule. Re-runnable: an existing job is replaced.

do $$
declare
  has_secret boolean;
begin
  select exists (
    select 1 from vault.decrypted_secrets where name = 'birthday_cron_secret'
  ) into has_secret;
  if not has_secret then
    raise notice 'purge-expired-posts: no cron secret in Vault, schedule skipped';
    return;
  end if;

  if exists (select 1 from cron.job where jobname = 'purge-expired-posts-hourly') then
    perform cron.unschedule('purge-expired-posts-hourly');
  end if;

  perform cron.schedule(
    'purge-expired-posts-hourly',
    '15 * * * *',
    $job$
      select net.http_post(
        url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/purge-expired-posts',
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
