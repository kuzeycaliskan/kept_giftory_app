-- The honoree may edit their thank-you (Kuzey, 25 Sep 2026). thanks_at
-- stays the first write; the members' push fires only on that first write
-- (notify_event_thanks already checks old.thanks_note is null).
create or replace function public.guard_gift_event_update()
returns trigger
language plpgsql
as $$
declare
  by_machine boolean := coalesce(current_setting('kept.reveal', true), '') = 'on';
begin
  new.honoree_id := old.honoree_id;
  new.creator_id := old.creator_id;
  new.event_date := old.event_date;
  new.reveal_at  := old.reveal_at;
  new.created_at := old.created_at;
  if not by_machine then
    new.revealed_at        := old.revealed_at;
    new.reveal_notified_at := old.reveal_notified_at;
    if new.status = 'revealed' and old.status <> 'revealed' then
      new.status := old.status;
    end if;
  end if;
  if auth.uid() = old.honoree_id then
    new.status            := old.status;
    new.external_chat_url := old.external_chat_url;
    if new.thanks_note is null then
      -- The note can be rewritten, not withdrawn.
      new.thanks_note := old.thanks_note;
      new.thanks_at   := old.thanks_at;
    elsif old.thanks_note is null then
      new.thanks_at := now();
    else
      new.thanks_at := old.thanks_at;
    end if;
  else
    new.thanks_note := old.thanks_note;
    new.thanks_at   := old.thanks_at;
  end if;
  return new;
end;
$$;
