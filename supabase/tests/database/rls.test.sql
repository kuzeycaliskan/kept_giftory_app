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

select plan(117);

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

-- ── 16-17: pending does NOT unlock the full profile — card only ─────────────
-- Sending a request is unilateral; full details unlock on acceptance. The
-- request UI renders pending counterparts from profile_card.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000e'),
  0::bigint,
  '16: pending request does not expose the requester''s full profile'
);

select is(
  (select username from public.profile_card(
    '00000000-0000-0000-0000-00000000000e')),
  'erin',
  '17: addressee can still fetch the pending requester''s card'
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

-- ── 24-26: sections are capped by profile visibility ────────────────────────
-- alice: profile stays 'friends' but wishlist/history flip to 'public'.
-- A stranger must STILL see nothing (min(profile, section) rule); a friend
-- keeps access. State at this point: carol became alice's friend (test 13),
-- bob was deleted (test 14) — so the stranger here is dave.
update public.profiles
   set wishlist_visibility = 'public', gift_history_visibility = 'public'
 where id = '00000000-0000-0000-0000-00000000000a';

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select is(
  (select count(*) from public.wishlist_items
    where owner_id = '00000000-0000-0000-0000-00000000000a'),
  0::bigint,
  '24: public wishlist behind a friends-only profile stays hidden from strangers'
);

select is(
  (select count(*) from public.gifts
    where recipient_id = '00000000-0000-0000-0000-00000000000a'),
  0::bigint,
  '25: public gift history behind a friends-only profile stays hidden from strangers'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from public.wishlist_items
    where owner_id = '00000000-0000-0000-0000-00000000000a'),
  1::bigint,
  '26: friend still sees the wishlist under the visibility cap'
);

reset role;

-- ── 27-29: discoverability (G-32) — every profile searchable as a card ──────
-- dave is still a stranger to alice; alice's profile is friends-only, yet
-- search_profiles/profile_card must surface her minimal card. The full row
-- stays RLS-hidden (test 1 covers that).
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select is(
  (select count(*) from public.search_profiles('ali')
    where username = 'alice'),
  1::bigint,
  '27: stranger finds a friends-only profile in search (card only)'
);

select is(
  (select username from public.profile_card(
    '00000000-0000-0000-0000-00000000000a')),
  'alice',
  '28: stranger can fetch the minimal card of a friends-only profile'
);

select is(
  (select count(*) from public.search_profiles('a')),
  0::bigint,
  '29: sub-2-char queries return nothing (enumeration guard)'
);

reset role;

-- ── 30-31: decline deletes the row so the pair can re-request ───────────────
-- erin→alice is still pending (fixture). Alice (addressee) declines by
-- deleting under RLS; erin can then send a fresh request — the unique-pair
-- index no longer blocks it.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

delete from public.friendships
 where addressee_id = '00000000-0000-0000-0000-00000000000a'
   and requester_id = '00000000-0000-0000-0000-00000000000e'
   and status = 'pending';

reset role;
select is(
  (select count(*) from public.friendships
    where requester_id = '00000000-0000-0000-0000-00000000000e'
      and addressee_id = '00000000-0000-0000-0000-00000000000a'),
  0::bigint,
  '30: addressee can decline (delete) a pending request under RLS'
);

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000e","role":"authenticated"}';

select lives_ok(
  $$ insert into public.friendships (requester_id, addressee_id)
     values ('00000000-0000-0000-0000-00000000000e',
             '00000000-0000-0000-0000-00000000000a') $$,
  '31: the pair can re-request after a decline (no unique-pair block)'
);

reset role;

-- ── 32-38: block + report (G-72/G-73) ───────────────────────────────────────
-- carol and dave are friends (invite redemption, test 20). Dave blocks
-- carol: friendship severed, mutual invisibility (dave's profile is PUBLIC
-- yet carol loses it), no re-request, gone from search. Unblock restores
-- the public view. Reports: insert-only, no reading back.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select lives_ok(
  $$ select public.block_user('00000000-0000-0000-0000-00000000000c') $$,
  '32: blocking succeeds'
);

reset role;
select is(
  (select count(*) from public.friendships
    where least(requester_id, addressee_id) =
          least('00000000-0000-0000-0000-00000000000c'::uuid,
                '00000000-0000-0000-0000-00000000000d'::uuid)
      and greatest(requester_id, addressee_id) =
          greatest('00000000-0000-0000-0000-00000000000c'::uuid,
                   '00000000-0000-0000-0000-00000000000d'::uuid)),
  0::bigint,
  '33: blocking severs the existing friendship'
);

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000d'),
  0::bigint,
  '34: blocked user loses even a PUBLIC profile'
);

select is(
  (select count(*) from public.search_profiles('dave')),
  0::bigint,
  '35: blocked user cannot find the blocker in search'
);

select throws_ok(
  $$ insert into public.friendships (requester_id, addressee_id)
     values ('00000000-0000-0000-0000-00000000000c',
             '00000000-0000-0000-0000-00000000000d') $$,
  '42501',
  'new row violates row-level security policy for table "friendships"',
  '36: blocked pair cannot create a new friend request'
);

-- Reports: carol reports erin; the row is write-only for users.
select lives_ok(
  $$ insert into public.reports (reporter_id, reported_id, reason)
     values ('00000000-0000-0000-0000-00000000000c',
             '00000000-0000-0000-0000-00000000000e', 'spam') $$,
  '37: reporting a user succeeds'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

-- Unblock restores the public profile for the formerly blocked side.
select lives_ok(
  $$ select public.unblock_user('00000000-0000-0000-0000-00000000000c') $$,
  '38: unblocking succeeds'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from public.profiles
    where id = '00000000-0000-0000-0000-00000000000d'),
  1::bigint,
  '39: unblock restores visibility of the public profile'
);

reset role;

-- ── 40-41: notification prefs gate reminder dispatch (G-63) ─────────────────
-- alice + erin are friends again (test 31 re-request → accept it as alice),
-- erin has a birthday; alice's device token exists from test 22. Flipping
-- alice's pref off removes her from the dispatch targets.
update public.friendships set status = 'accepted'
 where requester_id = '00000000-0000-0000-0000-00000000000e'
   and addressee_id = '00000000-0000-0000-0000-00000000000a';
update public.profiles set birthday = date '1995-06-15'
 where id = '00000000-0000-0000-0000-00000000000e';

select is(
  (select count(*) from public.birthday_reminder_targets(
     '06-15', false, date '2026-06-15')
    where notified_user = '00000000-0000-0000-0000-00000000000a'),
  1::bigint,
  '40: reminders-enabled friend is a dispatch target'
);

update public.profiles set birthday_reminders_enabled = false
 where id = '00000000-0000-0000-0000-00000000000a';

select is(
  (select count(*) from public.birthday_reminder_targets(
     '06-15', false, date '2026-06-15')
    where notified_user = '00000000-0000-0000-0000-00000000000a'),
  0::bigint,
  '41: opting out removes the friend from dispatch targets'
);

-- ── 42-43: service_role can write the link-preview tables (G-211) ───────────
-- Regression for the 42501 cloud failure: RLS bypass ≠ table grants.
set local role service_role;

select lives_ok(
  $$ insert into public.link_previews (url_hash, url, title)
     values ('grant-test-hash', 'https://example.com/x', 'Grant test') $$,
  '42: service_role can insert link previews'
);

select lives_ok(
  $$ insert into public.link_preview_requests (user_id)
     values ('00000000-0000-0000-0000-00000000000a') $$,
  '43: service_role can insert link-preview rate rows'
);

reset role;

-- ── 44-48: external gifts (G-212) ───────────────────────────────────────────
-- alice logs a gift from her mother; bob was deleted long ago; carol is a
-- stranger to alice-history rules established earlier (friends again since
-- test 26 fixture state: carol IS alice's friend via redeem? no — carol
-- friended DAVE. carol-alice became friends at test 13). Use erin (friend
-- since test 40 setup) for visibility checks.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gifts (recipient_id, item, giver_relation, gift_date)
     values ('00000000-0000-0000-0000-00000000000a', 'El örgüsü atkı',
             'mother', date '2026-09-01') $$,
  '44: recipient can log an external gift for themselves'
);

select throws_ok(
  $$ insert into public.gifts (recipient_id, item, giver_relation, gift_date,
                               is_surprise, reveal_at)
     values ('00000000-0000-0000-0000-00000000000a', 'X', 'father',
             date '2026-09-01', true, now() + interval '1 day') $$,
  '42501',
  'new row violates row-level security policy for table "gifts"',
  '45: external gifts cannot be surprises'
);

select throws_ok(
  $$ insert into public.gifts (recipient_id, item, giver_relation, gift_date)
     values ('00000000-0000-0000-0000-00000000000e', 'X', 'father',
             date '2026-09-01') $$,
  '42501',
  'new row violates row-level security policy for table "gifts"',
  '46: cannot log an external gift onto someone else''s history'
);

select lives_ok(
  $$ update public.gifts set item = 'El örgüsü atkı (kırmızı)'
     where recipient_id = '00000000-0000-0000-0000-00000000000a'
       and giver_relation = 'mother' $$,
  '47: recipient can edit their own external record'
);

reset role;
-- Both giver_id and giver_relation set must be impossible (CHECK).
select throws_ok(
  $$ insert into public.gifts (giver_id, recipient_id, item, giver_relation,
                               gift_date)
     values ('00000000-0000-0000-0000-00000000000e',
             '00000000-0000-0000-0000-00000000000a', 'X', 'mother',
             date '2026-09-01') $$,
  '23514',
  null,
  '48: a gift cannot have both a member giver and a relation'
);

-- ── 49-62: ephemeral posts (G-201/202/203) ─────────────────────────────────
-- Fresh actors so earlier fixture drift doesn't matter: hank (friends-only
-- profile) ↔ ivy accepted friends; dave (public profile, stranger to both).
reset role;
insert into auth.users (id, email)
values
  ('00000000-0000-0000-0000-000000000a11', 'hank@test.dev'),
  ('00000000-0000-0000-0000-000000000a12', 'ivy@test.dev');
insert into public.profiles (id, username, profile_visibility)
values
  ('00000000-0000-0000-0000-000000000a11', 'hank', 'friends'),
  ('00000000-0000-0000-0000-000000000a12', 'ivy',  'friends');
insert into public.friendships (requester_id, addressee_id, status)
values ('00000000-0000-0000-0000-000000000a11',
        '00000000-0000-0000-0000-000000000a12', 'accepted');

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a11","role":"authenticated"}';

select lives_ok(
  $$ insert into public.posts (id, author_id, media_path, caption, expires_at)
     values ('00000000-0000-0000-0000-000000000b01',
             '00000000-0000-0000-0000-000000000a11',
             '00000000-0000-0000-0000-000000000a11/post-1.jpg',
             'ilk an', now() + interval '30 days') $$,
  '49: author can create a post (client-sent expiry ignored, see 50)'
);

select is(
  (select expires_at - created_at from public.posts
    where id = '00000000-0000-0000-0000-000000000b01'),
  interval '24 hours',
  '50: lifetime is server-owned — exactly 24h regardless of client input'
);

insert into public.posts (id, author_id, media_path)
values ('00000000-0000-0000-0000-000000000b02',
        '00000000-0000-0000-0000-000000000a11',
        '00000000-0000-0000-0000-000000000a11/post-2.jpg');

select throws_ok(
  $$ insert into public.posts (author_id, media_path)
     values ('00000000-0000-0000-0000-000000000a11',
             '00000000-0000-0000-0000-000000000a12/stolen.jpg') $$,
  '23514',
  null,
  '51: a post cannot reference another user''s storage folder'
);

update public.posts set caption = 'hacked'
 where id = '00000000-0000-0000-0000-000000000b01';
select is(
  (select caption from public.posts
    where id = '00000000-0000-0000-0000-000000000b01'),
  'ilk an',
  '52: posts are immutable — update is a no-op even for the author'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}';

select is(
  (select count(*) from public.posts
    where author_id = '00000000-0000-0000-0000-000000000a11'),
  2::bigint,
  '53: friend sees a friends-only author''s live posts'
);

select throws_ok(
  $$ insert into public.posts (author_id, media_path)
     values ('00000000-0000-0000-0000-000000000a11',
             '00000000-0000-0000-0000-000000000a11/forged.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "posts"',
  '54: cannot post as someone else'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select is(
  (select count(*) from public.posts
    where author_id = '00000000-0000-0000-0000-000000000a11'),
  0::bigint,
  '55: stranger cannot see a friends-only author''s posts'
);

insert into public.posts (id, author_id, media_path)
values ('00000000-0000-0000-0000-000000000d01',
        '00000000-0000-0000-0000-00000000000d',
        '00000000-0000-0000-0000-00000000000d/post-1.jpg');

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a11","role":"authenticated"}';

select is(
  (select count(*) from public.posts
    where author_id = '00000000-0000-0000-0000-00000000000d'),
  1::bigint,
  '56: a public profile''s posts are visible to any signed-in user'
);

-- Storage objects follow the row: fixture the objects as owner, then read
-- through the authenticated policy.
reset role;
insert into storage.objects (bucket_id, name)
values
  ('posts', '00000000-0000-0000-0000-000000000a11/post-1.jpg'),
  ('posts', '00000000-0000-0000-0000-000000000a11/post-2.jpg');

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}';

select is(
  (select count(*) from storage.objects
    where bucket_id = 'posts'
      and name = '00000000-0000-0000-0000-000000000a11/post-1.jpg'),
  1::bigint,
  '57: friend can read the photo of a live post'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select is(
  (select count(*) from storage.objects
    where bucket_id = 'posts'
      and name = '00000000-0000-0000-0000-000000000a11/post-1.jpg'),
  0::bigint,
  '58: stranger cannot read the photo even knowing its path'
);

-- Expire post-1 (as owner, simulating time passing).
reset role;
update public.posts set expires_at = now() - interval '1 minute'
 where id = '00000000-0000-0000-0000-000000000b01';

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}';

select is(
  (select count(*) from public.posts
    where author_id = '00000000-0000-0000-0000-000000000a11'),
  1::bigint,
  '59: an expired post vanishes from the feed before any purge runs'
);

select is(
  (select count(*) from storage.objects
    where bucket_id = 'posts'
      and name = '00000000-0000-0000-0000-000000000a11/post-1.jpg'),
  0::bigint,
  '60: an expired post''s photo is unreadable by path'
);

-- Purge path (service_role): grants regression + row removal.
set local role service_role;

select is(
  (select count(*) from public.posts where expires_at <= now()),
  1::bigint,
  '61: service_role can enumerate expired posts for purging'
);

select lives_ok(
  $$ delete from public.posts where expires_at <= now() $$,
  '62: service_role can delete purged rows'
);

reset role;

-- ── 63-77: gift photos (G-204) ──────────────────────────────────────────────
-- erin (friend) gives alice a plain gift G1 and a pending surprise G2; carol
-- is alice's friend (history 'friends'); dave is a stranger to alice.
reset role;
update public.profiles
   set profile_visibility = 'friends', gift_history_visibility = 'friends'
 where id = '00000000-0000-0000-0000-00000000000a';
insert into public.gifts (id, giver_id, recipient_id, item, is_surprise, reveal_at)
values
  ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000e', '00000000-0000-0000-0000-00000000000a', 'Kupa', false, null),
  ('00000000-0000-0000-0000-000000000c02', '00000000-0000-0000-0000-00000000000e', '00000000-0000-0000-0000-00000000000a', 'Saat', true, now() + interval '10 days');

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000e","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000e', '00000000-0000-0000-0000-00000000000e/00000000-0000-0000-0000-000000000c01-1.jpg') $$,
  '63: giver can add a photo to a gift they logged'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000a/00000000-0000-0000-0000-000000000c01-1.jpg') $$,
  '64: recipient can add a photo to a gift they received'
);

select lives_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000a/00000000-0000-0000-0000-000000000c01-2.jpg') $$,
  '65: third photo still fits the cap'
);

select throws_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000a/00000000-0000-0000-0000-000000000c01-3.jpg') $$,
  '23514',
  null,
  '66: a fourth photo is rejected by the cap'
);

select throws_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c02', '00000000-0000-0000-0000-00000000000e', '00000000-0000-0000-0000-00000000000e/00000000-0000-0000-0000-000000000c02-x.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "gift_photos"',
  '67: uploader_id cannot be forged'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

-- Uses G2 (no photos yet): on a full gift the cap trigger fires before the
-- policy check and would mask the RLS rejection with 23514.
select throws_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c02', '00000000-0000-0000-0000-00000000000d', '00000000-0000-0000-0000-00000000000d/00000000-0000-0000-0000-000000000c02-1.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "gift_photos"',
  '68: a stranger cannot attach photos to someone else''s gift'
);

select is(
  (select count(*) from public.gift_photos where gift_id = '00000000-0000-0000-0000-000000000c01'),
  0::bigint,
  '69: stranger sees no photos of a friends-only history'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from public.gift_photos where gift_id = '00000000-0000-0000-0000-000000000c01'),
  3::bigint,
  '70: friend sees the photos through history visibility'
);

-- Surprise isolation carries over to photos.
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000e","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c02', '00000000-0000-0000-0000-00000000000e', '00000000-0000-0000-0000-00000000000e/00000000-0000-0000-0000-000000000c02-1.jpg') $$,
  '71: giver can photograph a pending surprise'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is(
  (select count(*) from public.gift_photos where gift_id = '00000000-0000-0000-0000-000000000c02'),
  0::bigint,
  '72: recipient cannot see photos of an unrevealed surprise'
);

select throws_ok(
  $$ insert into public.gift_photos (gift_id, uploader_id, media_path)
     values ('00000000-0000-0000-0000-000000000c02', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000a/00000000-0000-0000-0000-000000000c02-1.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "gift_photos"',
  '73: recipient cannot attach photos to an unrevealed surprise'
);

delete from public.gift_photos
 where gift_id = '00000000-0000-0000-0000-000000000c01' and uploader_id = '00000000-0000-0000-0000-00000000000e';
select is(
  (select count(*) from public.gift_photos
    where gift_id = '00000000-0000-0000-0000-000000000c01' and uploader_id = '00000000-0000-0000-0000-00000000000e'),
  1::bigint,
  '74: a party cannot delete the other party''s photo'
);

-- Storage objects follow the row.
reset role;
insert into storage.objects (bucket_id, name)
values ('gift-media', '00000000-0000-0000-0000-00000000000e/00000000-0000-0000-0000-000000000c01-1.jpg');

set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select count(*) from storage.objects
    where bucket_id = 'gift-media' and name = '00000000-0000-0000-0000-00000000000e/00000000-0000-0000-0000-000000000c01-1.jpg'),
  1::bigint,
  '75: friend can read a visible gift photo object'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select is(
  (select count(*) from storage.objects
    where bucket_id = 'gift-media' and name = '00000000-0000-0000-0000-00000000000e/00000000-0000-0000-0000-000000000c01-1.jpg'),
  0::bigint,
  '76: stranger cannot read the object by path'
);

set local role service_role;
select lives_ok(
  $$ select count(*) from public.gift_photos $$,
  '77: service_role can enumerate gift photos (account deletion)'
);
reset role;

-- ── 78-87: reactions on moments (G-206) ─────────────────────────────────────
-- Live posts from 49-62: hank's b02 (hank friends-only; ivy is his friend),
-- dave's d01 (public). dave is a stranger to hank.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}';

select lives_ok(
  $$ insert into public.post_reactions (post_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000b02', '00000000-0000-0000-0000-000000000a12', 'heart') $$,
  '78: friend can react to a visible moment'
);

select throws_ok(
  $$ insert into public.post_reactions (post_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-000000000a11', 'like') $$,
  '42501',
  'new row violates row-level security policy for table "post_reactions"',
  '79: user_id cannot be forged'
);

select throws_ok(
  $$ insert into public.post_reactions (post_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000b02', '00000000-0000-0000-0000-000000000a12', 'wow') $$,
  '23505',
  null,
  '80: one reaction per user per moment (change = update)'
);

update public.post_reactions set kind = 'wow'
 where post_id = '00000000-0000-0000-0000-000000000b02' and user_id = '00000000-0000-0000-0000-000000000a12';
select is(
  (select kind::text from public.post_reactions
    where post_id = '00000000-0000-0000-0000-000000000b02' and user_id = '00000000-0000-0000-0000-000000000a12'),
  'wow',
  '81: a user can change their reaction kind'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select throws_ok(
  $$ insert into public.post_reactions (post_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000b02', '00000000-0000-0000-0000-00000000000d', 'heart') $$,
  '42501',
  'new row violates row-level security policy for table "post_reactions"',
  '82: stranger cannot react to a friends-only moment'
);

select is(
  (select count(*) from public.post_reactions where post_id = '00000000-0000-0000-0000-000000000b02'),
  0::bigint,
  '83: stranger cannot see reactions on a hidden moment'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a11","role":"authenticated"}';

select is(
  (select count(*) from public.post_reactions where post_id = '00000000-0000-0000-0000-000000000b02'),
  1::bigint,
  '84: author sees who reacted to their moment'
);

select lives_ok(
  $$ insert into public.post_reactions (post_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-000000000a11', 'congrats') $$,
  '85: anyone can react to a public profile''s moment'
);

update public.post_reactions set kind = 'heart'
 where post_id = '00000000-0000-0000-0000-000000000b02' and user_id = '00000000-0000-0000-0000-000000000a12';
select is(
  (select kind::text from public.post_reactions
    where post_id = '00000000-0000-0000-0000-000000000b02' and user_id = '00000000-0000-0000-0000-000000000a12'),
  'wow',
  '86: author cannot alter someone else''s reaction'
);

-- Expire hank's moment: its reactions disappear with it.
reset role;
update public.posts set expires_at = now() - interval '1 minute'
 where id = '00000000-0000-0000-0000-000000000b02';
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}';
select is(
  (select count(*) from public.post_reactions where post_id = '00000000-0000-0000-0000-000000000b02'),
  0::bigint,
  '87: reactions vanish with the expired moment'
);
reset role;

-- ── 88-89: reactor identity is always shown to whoever sees the moment ──────
-- ivy (friends-only profile, stranger to dave) reacts to dave's public
-- moment; dave still gets her name through post_reaction_cards.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}';
insert into public.post_reactions (post_id, user_id, kind)
values ('00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-000000000a12', 'like');

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';
select is(
  (select username from public.post_reaction_cards(array['00000000-0000-0000-0000-000000000d01'::uuid])
    where user_id = '00000000-0000-0000-0000-000000000a12'),
  'ivy',
  '88: author sees a private-profile reactor''s name'
);

select is(
  (select count(*) from public.post_reaction_cards(array['00000000-0000-0000-0000-000000000b02'::uuid])),
  0::bigint,
  '89: reaction cards of a hidden/expired moment stay hidden'
);
reset role;

-- ── 90-92: surprise teaser (G-210) ──────────────────────────────────────────
-- erin's pending surprise for alice (G2 from 63-77, reveal +10 days): alice
-- learns "something is coming, opens on <date>" and nothing more.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is(
  (select has_pending from public.pending_surprise_teaser()),
  true,
  '90: recipient learns a surprise is pending'
);

select ok(
  (select next_reveal_at > now() + interval '9 days'
     from public.pending_surprise_teaser()),
  '91: teaser carries the earliest reveal time'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is(
  (select has_pending from public.pending_surprise_teaser()),
  false,
  '92: teaser is strictly the caller''s own'
);
reset role;

-- ── 93-98: reactions on gifts ───────────────────────────────────────────────
-- G1 (erin→alice, plain) is visible to carol (alice's friend); G2 is a
-- pending surprise, hidden from alice; dave is a stranger to alice.
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gift_reactions (gift_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000c', 'congrats') $$,
  '93: a friend who sees the gift can react to it'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gift_reactions (gift_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000a', 'heart') $$,
  '94: the recipient can react to their own gift'
);

select throws_ok(
  $$ insert into public.gift_reactions (gift_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000c02', '00000000-0000-0000-0000-00000000000a', 'wow') $$,
  '42501',
  'new row violates row-level security policy for table "gift_reactions"',
  '95: recipient cannot react to an unrevealed surprise'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select throws_ok(
  $$ insert into public.gift_reactions (gift_id, user_id, kind)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000d', 'like') $$,
  '42501',
  'new row violates row-level security policy for table "gift_reactions"',
  '96: a stranger cannot react to a friends-only history'
);

select is(
  (select count(*) from public.gift_reactions where gift_id = '00000000-0000-0000-0000-000000000c01'),
  0::bigint,
  '97: reactions are as hidden as the gift'
);

-- Identity batch: dave (stranger) still gets ivy's (friends-only) card.
select is(
  (select username from public.profile_cards(array['00000000-0000-0000-0000-000000000a12'::uuid])),
  'ivy',
  '98: profile_cards resolves a private profile''s discovery card'
);
reset role;

-- ── 99-106: comments ────────────────────────────────────────────────────────
-- G1 erin→alice (carol = alice's friend, dave stranger); G2 pending surprise.
-- d01 = dave's live public moment (hank reacts earlier; ivy comments here).
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select lives_ok(
  $$ insert into public.gift_comments (id, gift_id, author_id, body)
     values ('00000000-0000-0000-0000-000000000e01', '00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000c', 'Harika seçim!') $$,
  '99: a friend who sees the gift can comment'
);

select throws_ok(
  $$ insert into public.gift_comments (gift_id, author_id, body)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000a', 'forged') $$,
  '42501',
  'new row violates row-level security policy for table "gift_comments"',
  '100: author_id cannot be forged'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';

select throws_ok(
  $$ insert into public.gift_comments (gift_id, author_id, body)
     values ('00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000d', 'nope') $$,
  '42501',
  'new row violates row-level security policy for table "gift_comments"',
  '101: a stranger cannot comment on a friends-only history'
);

select is(
  (select count(*) from public.gift_comments where gift_id = '00000000-0000-0000-0000-000000000c01'),
  0::bigint,
  '102: comments are as hidden as the gift'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select throws_ok(
  $$ insert into public.gift_comments (gift_id, author_id, body)
     values ('00000000-0000-0000-0000-000000000c02', '00000000-0000-0000-0000-00000000000a', 'what is it?') $$,
  '42501',
  'new row violates row-level security policy for table "gift_comments"',
  '103: recipient cannot comment on an unrevealed surprise'
);

-- Recipient (a party) may remove a friend's comment on their own gift.
delete from public.gift_comments where id = '00000000-0000-0000-0000-000000000e01';
select is(
  (select count(*) from public.gift_comments where gift_id = '00000000-0000-0000-0000-000000000c01'),
  0::bigint,
  '104: a gift party can remove a comment on their gift'
);

-- Moments: ivy comments on dave's public moment; hank cannot delete it.
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}';
insert into public.post_comments (id, post_id, author_id, body)
values ('00000000-0000-0000-0000-000000000e02', '00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-000000000a12', 'nice');

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a11","role":"authenticated"}';
delete from public.post_comments where id = '00000000-0000-0000-0000-000000000e02';
select is(
  (select count(*) from public.post_comments where id = '00000000-0000-0000-0000-000000000e02'),
  1::bigint,
  '105: a bystander cannot delete someone else''s comment'
);

set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}';
delete from public.post_comments where id = '00000000-0000-0000-0000-000000000e02';
select is(
  (select count(*) from public.post_comments where id = '00000000-0000-0000-0000-000000000e02'),
  0::bigint,
  '106: the moment''s author can remove a comment on it'
);
reset role;

-- ── 107-109: content reports (G-209) ────────────────────────────────────────
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select lives_ok(
  $$ insert into public.reports (reporter_id, reported_id, reason, target_type, target_id)
     values ('00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-00000000000d', 'spam', 'post', '00000000-0000-0000-0000-000000000d01') $$,
  '107: a moment can be reported (owner stays accountable)'
);

select throws_ok(
  $$ insert into public.reports (reporter_id, reported_id, reason, target_type, target_id)
     values ('00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-00000000000d', 'other', 'post', '00000000-0000-0000-0000-000000000d01') $$,
  '23505',
  null,
  '108: the same target is reported once per reporter'
);

select throws_ok(
  $$ insert into public.reports (reporter_id, reported_id, reason, target_type, target_id)
     values ('00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-00000000000d', 'spam', 'profile', '00000000-0000-0000-0000-000000000d01') $$,
  '23514',
  null,
  '109: a profile report must target the profile itself'
);
reset role;

-- ── 110-113: social push targets ────────────────────────────────────────────
-- carol comments on G1 (erin→alice); alice has a device token (test 22).
reset role;
insert into public.gift_comments (id, gift_id, author_id, body)
values ('00000000-0000-0000-0000-000000000e09', '00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000c', 'Bayıldım');

select is(
  (select count(*) from public.comment_push_targets('gift', '00000000-0000-0000-0000-000000000e09')
    where notified_user = '00000000-0000-0000-0000-00000000000a'),
  1::bigint,
  '110: the recipient is a push target for a comment on their gift'
);

select is(
  (select count(*) from public.comment_push_targets('gift', '00000000-0000-0000-0000-000000000e09')
    where notified_user = '00000000-0000-0000-0000-00000000000c'),
  0::bigint,
  '111: the commenter is never their own target'
);

update public.profiles set social_notifications_enabled = false
 where id = '00000000-0000-0000-0000-00000000000a';
select is(
  (select count(*) from public.comment_push_targets('gift', '00000000-0000-0000-0000-000000000e09')
    where notified_user = '00000000-0000-0000-0000-00000000000a'),
  0::bigint,
  '112: opting out removes the recipient from comment targets'
);
update public.profiles set social_notifications_enabled = true
 where id = '00000000-0000-0000-0000-00000000000a';

-- G2 (pending surprise) is not due; once its reveal time passes it is.
select is(
  (select count(*) from public.surprise_reveal_targets()
    where gift_id = '00000000-0000-0000-0000-000000000c02'),
  0::bigint,
  '113a: a pending surprise is not announced'
) where false; -- placeholder keeps numbering readable
update public.gifts set reveal_at = now() - interval '1 minute'
 where id = '00000000-0000-0000-0000-000000000c02';
select ok(
  exists (select 1 from public.surprise_reveal_targets()
           where gift_id = '00000000-0000-0000-0000-000000000c02' and recipient_id = '00000000-0000-0000-0000-00000000000a'),
  '113: a surprise past its reveal time is a reveal target'
);

-- ── 114-117: social hardening ───────────────────────────────────────────────
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a11","role":"authenticated"}';

select throws_ok(
  $$ select * from public.surprise_reveal_targets() $$,
  '42501',
  null,
  '114: push-target functions are not callable by users (device tokens)'
);

-- ivy comments on dave's public moment; hank blocks ivy → the comment is
-- gone for hank even though both still see the moment.
reset role;
insert into public.post_comments (id, post_id, author_id, body)
values ('00000000-0000-0000-0000-000000000e10', '00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-000000000a12', 'selam');
set local role authenticated;
set local "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a11","role":"authenticated"}';
select public.block_user('00000000-0000-0000-0000-000000000a12');
select is(
  (select count(*) from public.post_comments where id = '00000000-0000-0000-0000-000000000e10'),
  0::bigint,
  '115: a blocked user''s comment is hidden on a shared moment'
);
select public.unblock_user('00000000-0000-0000-0000-000000000a12');

-- Comment targets require current visibility: carol (device below) is a
-- target while she is alice's friend, not after the friendship ends.
reset role;
insert into public.device_tokens (token, user_id, platform)
values ('tok-carol', '00000000-0000-0000-0000-00000000000c', 'android');
insert into public.gift_comments (id, gift_id, author_id, body)
values ('00000000-0000-0000-0000-000000000e11', '00000000-0000-0000-0000-000000000c01', '00000000-0000-0000-0000-00000000000e', 'Sevindim');

select is(
  (select count(*) from public.comment_push_targets('gift', '00000000-0000-0000-0000-000000000e11')
    where notified_user = '00000000-0000-0000-0000-00000000000c'),
  1::bigint,
  '116: an earlier commenter who still sees the gift is a target'
);

delete from public.friendships
 where (requester_id = '00000000-0000-0000-0000-00000000000c' and addressee_id = '00000000-0000-0000-0000-00000000000a')
    or (requester_id = '00000000-0000-0000-0000-00000000000a' and addressee_id = '00000000-0000-0000-0000-00000000000c');
select is(
  (select count(*) from public.comment_push_targets('gift', '00000000-0000-0000-0000-000000000e11')
    where notified_user = '00000000-0000-0000-0000-00000000000c'),
  0::bigint,
  '117: once the gift is hidden from them, no more comment pushes'
);

select * from finish();
rollback;
