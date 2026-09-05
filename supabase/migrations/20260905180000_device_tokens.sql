-- ============================================================================
-- G-61: FCM device tokens.
-- One row per device token; a user can have many (multiple devices), a token
-- belongs to exactly one user (re-registering moves it). Owner-only via RLS —
-- push dispatch (G-62) reads with service role from an Edge Function.
-- ============================================================================

create table public.device_tokens (
  token       text primary key,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  platform    text not null check (platform in ('android', 'ios')),
  updated_at  timestamptz not null default now()
);

create index device_tokens_user_idx on public.device_tokens (user_id);

grant select, insert, update, delete on public.device_tokens to authenticated;

alter table public.device_tokens enable row level security;

create policy device_tokens_select on public.device_tokens
  for select to authenticated
  using (user_id = auth.uid());

create policy device_tokens_insert on public.device_tokens
  for insert to authenticated
  with check (user_id = auth.uid());

create policy device_tokens_update on public.device_tokens
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy device_tokens_delete on public.device_tokens
  for delete to authenticated
  using (user_id = auth.uid());
