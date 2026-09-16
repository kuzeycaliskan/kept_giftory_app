-- ============================================================================
-- Kept — Gift photos (G-204 as decided 2026-09-16: a gift is the object,
-- photos hang off it; up to 3 per gift; giver AND recipient may add).
--
--  * `gift_photos` rows are visible exactly when the gift row is: the select
--    policy defers to `gifts` RLS, so a surprise's photos stay hidden from
--    the recipient until reveal, and friend-history visibility carries over.
--  * Either party of the gift may add (the recipient only once they can see
--    it — RLS again); each uploader removes only their own photos.
--  * Cap of 3 is enforced in the database (definer trigger, per-gift lock).
--  * Media lives in the PRIVATE `gift-media` bucket at
--    '<uploader uid>/<gift id>-<micros>.jpg'; objects are readable through
--    a visible gift_photos row only.
--  * `gifts.image_url` (unused since G-51) is dropped: one source of truth.
-- ============================================================================

alter table public.gifts drop column if exists image_url;

create table public.gift_photos (
  id           uuid primary key default gen_random_uuid(),
  gift_id      uuid not null references public.gifts (id) on delete cascade,
  uploader_id  uuid not null references public.profiles (id) on delete cascade,
  media_path   text not null,
  created_at   timestamptz not null default now(),
  constraint gift_photos_media_in_own_folder
    check (split_part(media_path, '/', 1) = uploader_id::text)
);

create index gift_photos_gift_idx on public.gift_photos (gift_id, created_at);

comment on table public.gift_photos is
  'Up to 3 photos per gift (enforce_gift_photo_cap), added by giver or recipient. Visible iff the gift row is.';

-- ── cap: 3 per gift ─────────────────────────────────────────────────────────
-- SECURITY DEFINER so the per-gift lock and the count see every row
-- regardless of the caller''s RLS view (a recipient can''t lock the gift row
-- otherwise, and the cap must count the other party''s photos too).
create or replace function public.enforce_gift_photo_cap()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  photo_count integer;
begin
  perform 1 from public.gifts where id = new.gift_id for update;
  select count(*) into photo_count
    from public.gift_photos where gift_id = new.gift_id;
  if photo_count >= 3 then
    raise exception 'gift % already has 3 photos', new.gift_id
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

create trigger gift_photos_cap
  before insert on public.gift_photos
  for each row execute function public.enforce_gift_photo_cap();

-- ── grants + RLS ────────────────────────────────────────────────────────────
grant select, insert, delete on public.gift_photos to authenticated;
grant select, delete on public.gift_photos to service_role;

alter table public.gift_photos enable row level security;

-- Defers to gifts RLS: the subquery runs as the caller.
create policy gift_photos_select on public.gift_photos
  for select to authenticated
  using (exists (select 1 from public.gifts g where g.id = gift_id));

create policy gift_photos_insert on public.gift_photos
  for insert to authenticated
  with check (
    uploader_id = auth.uid()
    and exists (
      select 1 from public.gifts g
      where g.id = gift_id
        and (g.giver_id = auth.uid() or g.recipient_id = auth.uid())
    )
  );

create policy gift_photos_delete on public.gift_photos
  for delete to authenticated
  using (uploader_id = auth.uid());

-- ── storage: private `gift-media` bucket ────────────────────────────────────
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('gift-media', 'gift-media', false, 1048576, array['image/jpeg'])
on conflict (id) do nothing;

create policy gift_media_insert_own on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'gift-media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy gift_media_select_via_photo on storage.objects
  for select to authenticated
  using (
    bucket_id = 'gift-media'
    and exists (
      select 1 from public.gift_photos p
      where p.media_path = storage.objects.name
    )
  );

create policy gift_media_delete_own on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'gift-media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
