-- Avatar storage (G-23 handover / first MediaStore consumer, per the G-207
-- decision). Public-read: the discovery card (profile_card/search_profiles)
-- already exposes avatar_url to any signed-in user, so avatars are public
-- surface by design. Layout: '<uid>/avatar-<epoch>.jpg' — the timestamped
-- name gives free cache-busting; owners may only touch their own folder.

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

create policy avatars_insert_own on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy avatars_update_own on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy avatars_delete_own on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
