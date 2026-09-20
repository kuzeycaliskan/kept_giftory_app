-- ============================================================================
-- Kept — Event notes board (G-305 as decided: no chat, a board on the
-- comment infrastructure). Visible to members only, never to the honoree
-- (defers to gift_events RLS); joined members write; the author or an
-- organizer deletes. New notes push to the other joined members.
-- ============================================================================

create table public.event_comments (
  id          uuid primary key default gen_random_uuid(),
  event_id    uuid not null references public.gift_events (id) on delete cascade,
  author_id   uuid not null references public.profiles (id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 500),
  created_at  timestamptz not null default now()
);
create index event_comments_event_idx on public.event_comments (event_id, created_at);

grant select, insert, delete on public.event_comments to authenticated;
grant select, delete on public.event_comments to service_role;

alter table public.event_comments enable row level security;

create policy event_comments_select on public.event_comments
  for select to authenticated
  using (
    exists (select 1 from public.gift_events e where e.id = event_id)
    and not public.is_blocked_pair(auth.uid(), author_id)
  );

create policy event_comments_insert on public.event_comments
  for insert to authenticated
  with check (
    author_id = auth.uid()
    and exists (
      select 1 from public.gift_event_members m
      where m.event_id = event_comments.event_id
        and m.user_id = auth.uid() and m.status = 'joined'
    )
    and exists (
      select 1 from public.gift_events e
      where e.id = event_comments.event_id and e.status = 'open'
    )
  );

create policy event_comments_delete on public.event_comments
  for delete to authenticated
  using (
    author_id = auth.uid()
    or public.is_event_organizer(event_id, auth.uid())
  );

-- ── push targets: joined members, minus author / opt-outs / blocked ─────────
create or replace function public.event_comment_push_targets(p_comment_id uuid)
returns table (
  token text,
  platform text,
  notified_user uuid,
  commenter_label text,
  item_label text,
  snippet text,
  route text
)
language sql
security definer
set search_path = public
stable
as $$
  select dt.token, dt.platform, p.id,
         coalesce(a.display_name, a.username),
         coalesce(h.display_name, h.username),
         left(c.body, 120),
         '/events/' || e.id::text
    from public.event_comments c
    join public.gift_events e on e.id = c.event_id
    join public.profiles a on a.id = c.author_id
    join public.profiles h on h.id = e.honoree_id
    join public.gift_event_members m
      on m.event_id = e.id and m.status = 'joined' and m.user_id <> c.author_id
    join public.profiles p on p.id = m.user_id
    join public.device_tokens dt on dt.user_id = p.id
   where c.id = p_comment_id
     and p.social_notifications_enabled
     and not public.is_blocked_pair(c.author_id, p.id);
$$;

revoke execute on function public.event_comment_push_targets(uuid)
  from public, anon, authenticated;
grant execute on function public.event_comment_push_targets(uuid) to service_role;

-- Same best-effort ping as the other comment tables (kind = 'event').
create trigger event_comments_notify
  after insert on public.event_comments
  for each row execute function public.notify_comment_inserted();

create or replace function public.notify_comment_inserted()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  secret text;
begin
  begin
    select decrypted_secret into secret
      from vault.decrypted_secrets where name = 'birthday_cron_secret';
    if secret is null then
      return new;
    end if;
    perform net.http_post(
      url := 'https://fezdcmvhnuvvaivogwvf.supabase.co/functions/v1/notify-comment',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-cron-secret', secret
      ),
      body := jsonb_build_object(
        'kind', case tg_table_name
                  when 'gift_comments' then 'gift'
                  when 'event_comments' then 'event'
                  else 'post' end,
        'comment_id', new.id
      )
    );
  exception when others then
    raise warning 'notify_comment_inserted: % (comment %)', sqlerrm, new.id;
  end;
  return new;
end;
$$;
