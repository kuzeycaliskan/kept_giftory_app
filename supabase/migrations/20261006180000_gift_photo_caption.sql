-- G-308 follow-up: each gift photo may carry its own short note (shown
-- under the photo on the gift; also the story caption when the recipient
-- shares the unboxing). Same cap as a moment caption.
alter table public.gift_photos
  add column caption text,
  add constraint gift_photos_caption_len
    check (caption is null or char_length(caption) between 1 and 140);
