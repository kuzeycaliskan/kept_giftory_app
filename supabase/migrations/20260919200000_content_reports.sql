-- G-209: reports extend from profiles to content (moments, gifts, comments).
-- `reported_id` stays the accountable person (the content's author/owner)
-- so moderation keeps working per user; `target_type` + `target_id` say
-- what exactly was reported. Dedup moves from "one per pair" to "one per
-- reporter per target" (a user may report a person AND one of their posts).

create type public.report_target as enum (
  'profile', 'post', 'gift', 'post_comment', 'gift_comment'
);

alter table public.reports
  add column target_type public.report_target not null default 'profile',
  add column target_id   uuid;

update public.reports set target_id = reported_id where target_id is null;
alter table public.reports alter column target_id set not null;

-- Profile reports may omit target_id (older clients): it is the profile.
create or replace function public.default_report_target()
returns trigger
language plpgsql
as $$
begin
  if new.target_id is null and new.target_type = 'profile' then
    new.target_id := new.reported_id;
  end if;
  return new;
end;
$$;

create trigger reports_default_target
  before insert on public.reports
  for each row execute function public.default_report_target();

alter table public.reports drop constraint reports_unique_pair;
alter table public.reports
  add constraint reports_unique_target unique (reporter_id, target_type, target_id);

-- A profile report must point at the profile itself.
alter table public.reports
  add constraint reports_profile_target
  check (target_type <> 'profile' or target_id = reported_id);
