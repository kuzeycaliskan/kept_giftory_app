-- Push when a member logs a (non-surprise) gift for you (Kuzey, 2026-09-20).
-- Surprises stay silent until reveal (surprise-revealed announces them);
-- external gifts are the recipient's own record — no push.

create or replace function public.gift_push_targets(p_gift_id uuid)
returns table (
  token text,
  platform text,
  recipient_id uuid,
  giver_label text,
  item_label text
)
language sql
security definer
set search_path = public
stable
as $$
  select dt.token, dt.platform, g.recipient_id,
         coalesce(giver.display_name, giver.username), g.item
    from public.gifts g
    join public.profiles giver on giver.id = g.giver_id
    join public.profiles r on r.id = g.recipient_id
    join public.device_tokens dt on dt.user_id = g.recipient_id
   where g.id = p_gift_id
     and not g.is_surprise
     and r.social_notifications_enabled
     and not public.is_blocked_pair(g.giver_id, g.recipient_id);
$$;

revoke execute on function public.gift_push_targets(uuid) from public, anon, authenticated;
grant execute on function public.gift_push_targets(uuid) to service_role;

create or replace function public.notify_gift_inserted()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
begin
  if new.giver_id is null or new.is_surprise then
    return new;
  end if;
  begin
    select decrypted_secret into secret
      from vault.decrypted_secrets where name = 'birthday_cron_secret';
    if secret is null then
      return new; -- local / no cloud wiring
    end if;
    perform net.http_post(
      url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-gift',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-cron-secret', secret
      ),
      body := jsonb_build_object('gift_id', new.id)
    );
  exception when others then
    raise warning 'notify_gift_inserted: % (gift %)', sqlerrm, new.id;
  end;
  return new;
end;
$$;

create trigger gifts_notify
  after insert on public.gifts
  for each row execute function public.notify_gift_inserted();
