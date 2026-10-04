-- In-app notification inbox (Kuzey, 5 Oct 2026): every push the server
-- sends is also written here, so the bell shows it whether or not the
-- device got the push. Service-role writes; users read, mark read and
-- clear their own. Rows older than 60 days are purged by the hourly job.
create table public.notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  kind        text not null,
  title       text not null,
  body        text not null,
  route       text,
  created_at  timestamptz not null default now(),
  read_at     timestamptz
);
create index notifications_user_idx on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;
grant select, update, delete on public.notifications to authenticated;
grant select, insert, delete on public.notifications to service_role;

create policy notifications_select on public.notifications
  for select to authenticated using (user_id = auth.uid());
create policy notifications_update on public.notifications
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notifications_delete on public.notifications
  for delete to authenticated using (user_id = auth.uid());

-- Users only flip read_at.
create or replace function public.guard_notification_update()
returns trigger
language plpgsql
as $$
begin
  new.user_id    := old.user_id;
  new.kind       := old.kind;
  new.title      := old.title;
  new.body       := old.body;
  new.route      := old.route;
  new.created_at := old.created_at;
  return new;
end;
$$;
create trigger notifications_guard_update
  before update on public.notifications
  for each row execute function public.guard_notification_update();
