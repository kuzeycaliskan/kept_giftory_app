-- ============================================================================
-- RLS security tests (pgTAP) — automates the matrix in supabase/README.md.
-- Run: supabase test db   (local stack must be up)
--
-- Actors: alice (sections 'friends'), bob (alice's friend), carol (stranger),
--         dave (public profile).
-- Setup runs as postgres (table owner → bypasses RLS); each assertion switches
-- to the authenticated role with a JWT claim, exactly like PostgREST does.
-- ============================================================================
begin;

create extension if not exists pgtap with schema extensions;

select plan(23);

-- ── Fixtures (as table owner; RLS not applied) ──────────────────────────────
insert into auth.users (id, email)
values
  ('00000000-0000-0000-0000-00000000000a', 'alice@test.dev'),
  ('00000000-0000-0000-0000-00000000000b', 'bob@test.dev'),
  ('00000000-0000-0000-0000-00000000000c', 'carol@test.dev'),
  ('00000000-0000-0000-0000-00000000000d', 'dave@test.dev'),
  ('00000000-0000-0000-0000-00000000000e', 'erin@test.dev');

insert into public.profiles (id, username, profile_visibility, wishlist_visibility, gift_history_visibility)
values
  ('00000000-0000-0000-0000-00000000000a', 'alice', 'friends', 'friends', 'friends'),
  ('00000000-0000-0000-0000-00000000000b', 'bob',   'friends', 'friends', 'friends'),
  ('00000000-0000-0000-0000-00000000000c', 'carol', 'friends', 'friends', 'friends'),
  ('00000000-0000-0000-0000-00000000000d', 'dave',  'public',  'friends', 'friends'),
  ('00000000-0000-0000-0000-00000000000e', 'erin',  'friends', 'friends', 'friends');

insert into public.friendships (requester_id, addressee_id, status)
values
  ('00000000-0000-0000-0000-00000000000a',
   '00000000-0000-0000-0000-00000000000b', 'accepted'),
  -- pending request erin → alice (for tests 16-17)
  ('00000000-0000-0000-0000-00000000000e',
   '00000000-0000-0000-0000-00000000000a', 'pending');

insert into public.wishlist_items (owner_id, title)
values ('00000000-0000-0000-0000-00000000000a', 'Kindle');

-- A non-surprise gift bob→alice (baseline history row).
insert into public.gifts (giver_id, recipient_id, item)
values ('00000000-0000-0000-0000-00000000000b',
        '00000000-0000-0000-0000-00000000000a', 'AirPods');

-- ── 1-2: profile visibility ─────────────────────────────────────────────────
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000a'),
  0::bigint,
  '1: stranger cannot see a friends-only profile'
);

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000d'),
  1::bigint,
  '2: anyone can see a public profile'
);

-- ── 3-4: wishlist visibility ────────────────────────────────────────────────
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';

select is(
  (select count(*) from public.wishlist_items
    where owner_id = '00000000-0000-0000-0000-00000000000a'),
  1::bigint,
  '3: friend sees a friends-only wishlist'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from public.wishlist_items
    where owner_id = '00000000-0000-0000-0000-00000000000a'),
  0::bigint,
  '4: stranger cannot see a friends-only wishlist'
);

-- ── 5: cannot write as someone else ─────────────────────────────────────────
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select throws_ok(
  $$ insert into public.wishlist_items (owner_id, title)
     values ('00000000-0000-0000-0000-00000000000b', 'sneaky') $$,
  '42501',
  'new row violates row-level security policy for table "wishlist_items"',
  '5: cannot insert a wishlist item for another user'
);

-- ── 6: giver logs a surprise gift ───────────────────────────────────────────
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gifts (giver_id, recipient_id, item, is_surprise, reveal_at)
     values ('00000000-0000-0000-0000-00000000000b',
             '00000000-0000-0000-0000-00000000000a',
             'Secret watch', true, now() + interval '7 days') $$,
  '6: giver can log a surprise gift'
);

-- ── 7: surprise hidden from recipient (whole row, count included) ───────────
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is(
  (select count(*) from public.gifts
    where recipient_id = '00000000-0000-0000-0000-00000000000a'),
  1::bigint,
  '7: recipient sees only the non-surprise gift before reveal'
);

-- ── 8: giver still sees both rows ───────────────────────────────────────────
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';

select is(
  (select count(*) from public.gifts
    where giver_id = '00000000-0000-0000-0000-00000000000b'),
  2::bigint,
  '8: giver sees surprise + non-surprise gifts he logged'
);

-- ── 9: after reveal_at passes, recipient sees it ────────────────────────────
reset role;
update public.gifts set reveal_at = now() - interval '1 day'
  where is_surprise;

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is(
  (select count(*) from public.gifts
    where recipient_id = '00000000-0000-0000-0000-00000000000a'),
  2::bigint,
  '9: recipient sees the surprise after reveal_at'
);

-- ── 10: only the giver can modify a gift ────────────────────────────────────
-- The attempt silently matches 0 rows under RLS; verify nothing changed.
update public.gifts set item = 'hacked'
 where giver_id = '00000000-0000-0000-0000-00000000000b';

select is(
  (select count(*) from public.gifts where item = 'hacked'),
  0::bigint,
  '10: recipient cannot update gifts logged by the giver'
);

-- ── 11: cannot send a friend request as someone else ────────────────────────
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select throws_ok(
  $$ insert into public.friendships (requester_id, addressee_id)
     values ('00000000-0000-0000-0000-00000000000a',
             '00000000-0000-0000-0000-00000000000c') $$,
  '42501',
  'new row violates row-level security policy for table "friendships"',
  '11: cannot create a friend request on behalf of another user'
);

-- ── 12-13: only the addressee can accept ────────────────────────────────────
reset role;
insert into public.friendships (requester_id, addressee_id, status)
values ('00000000-0000-0000-0000-00000000000a',
        '00000000-0000-0000-0000-00000000000c', 'pending');

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

-- Requester's accept attempt matches 0 rows under RLS.
update public.friendships set status = 'accepted'
 where requester_id = '00000000-0000-0000-0000-00000000000a'
   and addressee_id = '00000000-0000-0000-0000-00000000000c';

reset role;
select is(
  (select status from public.friendships
    where requester_id = '00000000-0000-0000-0000-00000000000a'
      and addressee_id = '00000000-0000-0000-0000-00000000000c'),
  'pending'::public.friendship_status,
  '12: requester cannot accept their own request'
);

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

update public.friendships set status = 'accepted', responded_at = now()
 where addressee_id = '00000000-0000-0000-0000-00000000000c'
   and status = 'pending';

reset role;
select is(
  (select status from public.friendships
    where requester_id = '00000000-0000-0000-0000-00000000000a'
      and addressee_id = '00000000-0000-0000-0000-00000000000c'),
  'accepted'::public.friendship_status,
  '13: addressee can accept the request'
);

-- ── 14-15: account deletion semantics ───────────────────────────────────────
reset role;
delete from auth.users where id = '00000000-0000-0000-0000-00000000000b';

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000b'),
  0::bigint,
  '14: deleting the auth user cascades to the profile'
);

select is(
  (select count(*) from public.gifts
    where recipient_id = '00000000-0000-0000-0000-00000000000a'
      and giver_id is null),
  2::bigint,
  '15: recipient history survives giver deletion (giver anonymized)'
);

-- ── 16-17: pending-request parties can see each other's profile (G-31) ──────
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000e'),
  1::bigint,
  '16: addressee can see the pending requester''s friends-only profile'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000e","role":"authenticated"}';

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000a'),
  1::bigint,
  '17: requester can see the pending addressee''s friends-only profile'
);

reset role;

-- ── 18: usernames are case-insensitively unique (G-12) ──────────────────────
insert into auth.users (id, email)
values ('00000000-0000-0000-0000-0000000000f0', 'frank@test.dev');

select throws_ok(
  $$ insert into public.profiles (id, username)
     values ('00000000-0000-0000-0000-0000000000f0', 'ALICE') $$,
  '23505',
  null,
  '18: username uniqueness is case-insensitive (ALICE vs alice)'
);

-- ── 19-21: invite redemption (G-34) ─────────────────────────────────────────
update public.profiles
   set invite_code = 'DAVECODE'
 where id = '00000000-0000-0000-0000-00000000000d';

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select lives_ok(
  $$ select * from public.redeem_invite('davecode') $$,
  '19: redeeming a valid code (case-insensitive) succeeds'
);

reset role;
select is(
  (select status from public.friendships
    where least(requester_id, addressee_id) =
          least('00000000-0000-0000-0000-00000000000c'::uuid,
                '00000000-0000-0000-0000-00000000000d'::uuid)
      and greatest(requester_id, addressee_id) =
          greatest('00000000-0000-0000-0000-00000000000c'::uuid,
                   '00000000-0000-0000-0000-00000000000d'::uuid)),
  'accepted'::public.friendship_status,
  '20: redemption creates an accepted friendship'
);

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select throws_ok(
  $$ select * from public.redeem_invite('DAVECODE') $$,
  'P0001',
  'invite_self',
  '21: redeeming your own code fails'
);

reset role;

-- ── 22-23: device tokens are owner-only (G-61) ──────────────────────────────
insert into public.device_tokens (token, user_id, platform)
values ('tok-alice-1', '00000000-0000-0000-0000-00000000000a', 'android');

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is(
  (select count(*) from public.device_tokens),
  1::bigint,
  '22: owner sees their own device token'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from public.device_tokens),
  0::bigint,
  '23: other users cannot see the token'
);

reset role;

select * from finish();
rollback;
