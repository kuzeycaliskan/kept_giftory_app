-- ============================================================================
-- G-34: personal invite codes + redemption.
--
-- Every profile gets a stable 8-char code. Redeeming a code creates an
-- ACCEPTED friendship immediately (both parties consented: one shared the
-- code, the other entered it). Redemption runs as SECURITY DEFINER because
-- the redeemer may not be allowed to see the inviter's profile row, and the
-- friendship insert intentionally bypasses the requester-must-be-self policy.
-- ============================================================================

alter table public.profiles
  add column invite_code text not null
    default upper(substr(md5(gen_random_uuid()::text), 1, 8));

create unique index profiles_invite_code_idx on public.profiles (invite_code);

create or replace function public.redeem_invite(code text)
returns table (inviter_id uuid, username text, display_name text)
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  inviter public.profiles%rowtype;
begin
  if caller is null then
    raise exception 'not_authenticated';
  end if;

  select * into inviter
  from public.profiles p
  where p.invite_code = upper(trim(code));

  if not found then
    raise exception 'invite_not_found';
  end if;

  if inviter.id = caller then
    raise exception 'invite_self';
  end if;

  -- Idempotent: an existing pair (any status) becomes an accepted friendship.
  insert into public.friendships (requester_id, addressee_id, status, responded_at)
  values (inviter.id, caller, 'accepted', now())
  on conflict ((least(requester_id, addressee_id)),
               (greatest(requester_id, addressee_id)))
  do update set status = 'accepted', responded_at = now();

  return query
    select inviter.id, inviter.username, inviter.display_name;
end;
$$;

grant execute on function public.redeem_invite(text) to authenticated;
