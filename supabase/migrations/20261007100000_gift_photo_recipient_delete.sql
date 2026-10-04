-- Who may remove a gift photo: its uploader, and the gift's recipient for
-- any photo on their gift (the record sits in their history; what shows
-- there is theirs to curate). The giver cannot touch the recipient's
-- photos. The storage object follows through the purge queue
-- (gift_photos_enqueue_purge), so the recipient never needs delete rights
-- on the giver's folder.
drop policy gift_photos_delete on public.gift_photos;
create policy gift_photos_delete on public.gift_photos
  for delete to authenticated
  using (
    uploader_id = auth.uid()
    or exists (
      select 1 from public.gifts g
       where g.id = gift_id and g.recipient_id = auth.uid()
    )
  );
