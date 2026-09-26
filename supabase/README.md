# Supabase — Kept

Database schema + Row Level Security for Kept, as versioned migrations.

## Migrations

| File | Contents |
|---|---|
| `migrations/20260904090000_init_schema.sql` | Enums, tables (`profiles`, `friendships`, `wishlist_items`, `gifts`), indexes, `updated_at` triggers (G-01) |
| `migrations/20260904090100_rls.sql` | Helper functions + RLS policies (default-deny, section visibility, surprise isolation) (G-03) |

> Not yet executed locally (no Postgres/Docker in the dev box) — validated on first
> apply. Reviewed for: recursive-RLS avoidance (helpers are `SECURITY DEFINER`),
> whole-row surprise isolation, and account-deletion FK semantics.

## How to apply

**Option A — Supabase CLI (recommended once a project exists):**
```bash
# one-time
brew install supabase/tap/supabase
supabase login
supabase link --project-ref <your-project-ref>
supabase db push          # applies migrations/ in order
```

**Option B — Dashboard:** paste each migration into the SQL Editor in filename order and run.

After applying, get the project URL + anon key from Project Settings → API and run the
app with them:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

## Data model (V1.0-a)

- **profiles** — one row per `auth.users`, created at onboarding (username is user-chosen,
  so not auto-created on signup). Per-section visibility columns: `profile_visibility`,
  `wishlist_visibility`, `gift_history_visibility` (`public` / `friends` / `private`).
- **friendships** — one row per unordered pair; `status` ∈ pending/accepted/declined.
- **wishlist_items** — owned by a profile.
- **gifts** — logged by the **giver**; `is_surprise` + `reveal_at` hide a surprise from the
  **recipient** until reveal. `giver_id ON DELETE SET NULL` preserves recipient history.

## Security model (RLS)

Default-deny everywhere. Visibility is centralized in helper functions:
`are_friends()`, `can_view_section()`, `can_view_wishlist()`, `can_view_gift_history()`
(all `SECURITY DEFINER` with a fixed `search_path`, so they read the graph/visibility
without recursive RLS and without being hijackable). RLS is the primary boundary; the app
layer defends in depth.

## RLS test matrix

> ✅ **Automated:** `tests/database/rls.test.sql` (pgTAP) covers this matrix — run
> `supabase test db` with the local stack up. 15 assertions, all green as of 2026-09-04.
> The table below remains as the human-readable spec.

Create 3 users: **A**, **B** (A↔B accepted friends), **C** (stranger). Then verify:

| # | Scenario | Expected |
|---|---|---|
| 1 | C reads A's profile where `profile_visibility='friends'` | ❌ not visible |
| 2 | C reads A's profile where `profile_visibility='public'` | ✅ visible |
| 3 | B reads A's wishlist where `wishlist_visibility='friends'` | ✅ visible |
| 4 | C reads A's wishlist (`friends`) | ❌ |
| 5 | A inserts a wishlist item with `owner_id = B` | ❌ (with_check) |
| 6 | B (giver) logs a **surprise** gift for A with `reveal_at` in the future | ✅ insert |
| 7 | A (recipient) lists their gifts before `reveal_at` | ❌ surprise row absent (incl. count) |
| 8 | A lists their gifts after `reveal_at` | ✅ surprise now visible |
| 9 | B (giver) or C-as-friend views A's history (`gift_history='friends'`) before reveal | ✅ surprise visible to non-recipient |
| 10 | A tries to update/delete a gift B logged | ❌ (only giver) |
| 11 | C sends friend request as `requester_id = A` | ❌ (must be self) |
| 12 | Only B (addressee) can accept A→B request | ✅ B accepts / ❌ A "accepts" |
| 13 | Delete B's account → A's gift from B remains with `giver_id = null` | ✅ history preserved |

> Automated in `tests/database/rls.test.sql`; keep the spec and the tests in sync when
> policies change.

## Birthday reminders (G-62)

- **Function:** `functions/birthday-reminders` — daily dispatch. Istanbul TZ,
  reminder at T-5 days (REMINDER_DAYS env), Feb-29 → Mar 1, suppressed when the
  friend already logged a gift this cycle (45d), idempotent via
  `birthday_reminder_log` (PK dedupe), stale FCM tokens auto-deleted.
- **Secrets (per env):** `CRON_SECRET`, `FCM_SERVICE_ACCOUNT` via
  `supabase secrets set`; cron secret also in Vault as `birthday_cron_secret`.
- **Schedule (cloud, one-time — done 2026-09-05):** pg_cron job
  `birthday-reminders-daily` at `0 6 * * *` UTC (=09:00 Istanbul) calling the
  function through pg_net with the Vault-held header secret.
- **Test:** `curl "$FN_URL?dry=1" -H "x-cron-secret: $SECRET"` → plan without
  sending. Wrong secret → 403.

## Ephemeral posts (G-201/202/203)

- **Table `posts`** (migration `20260916100000_posts.sql`): lifetime is
  server-owned (`set_post_lifetime` trigger forces created_at/expires_at =
  +24h), rows immutable, author-only delete. Visibility follows the author's
  **profile** visibility via `can_view_profile` (block-aware).
- **Bucket `posts` (private):** objects at `<uid>/post-<micros>.jpg`; the read
  policy joins the live post row, so an expired/hidden post's photo is not
  fetchable by path. 1 MB / image-jpeg caps server-side.
- **Purge:** `functions/purge-expired-posts` — media removed BEFORE rows,
  batches of 200, max 5 per tick, storage failure aborts with rows intact
  (retried next tick). `?dry=1` reports the due count. Same secret header as
  the reminders (`CRON_SECRET`). **Deploy with `--no-verify-jwt`** (cron
  carries no user JWT; the secret header is the auth) — the default
  verify-jwt deploy answers 404 to the cron call.
- **Schedule:** migration `20260916110000_purge_posts_cron.sql` creates the
  pg_cron job `purge-expired-posts-hourly` (`15 * * * *`, pg_net → function,
  secret read from Vault at run time). Cloud-only by construction: skipped
  where the Vault secret is absent (local stacks). Re-runnable.
- **Account deletion** removes the user's `avatars/<uid>` and `posts/<uid>`
  folders before the auth user (no FK cascade reaches Storage).
- pgTAP 49-62 cover lifetime forcing, visibility, immutability, storage
  read-through, expiry, and service_role purge grants.

## Gift photos (G-204, decided 2026-09-16)

- **Model:** the gift is the object; `gift_photos` rows hang off it (cap 3 via
  the definer trigger `enforce_gift_photo_cap`, per-gift lock). Either party
  (giver or recipient) adds; an uploader deletes only their own. Camera-only
  capture is a product rule enforced in the app, not the DB.
- **Visibility:** `gift_photos_select` defers to `gifts` RLS (subquery runs as
  the caller) — surprise photos stay hidden from the recipient until reveal,
  friend-history visibility carries over. The recipient can only attach once
  the gift is visible to them (same mechanism).
- **Bucket `gift-media` (private):** `<uploader uid>/<gift id>-<micros>.jpg`,
  1 MB / image-jpeg caps; object readable through a visible `gift_photos` row.
  Account deletion wipes `gift-media/<uid>/` with the other user folders.
- `gifts.image_url` dropped (unused since G-51).
- pgTAP 63-77. Note for new tests: on a full gift the cap trigger fires
  before the RLS check (23514 masks 42501) — assert RLS on an empty gift.

## Reactions on moments (G-206)

- `post_reactions` (PK post_id+user_id → one reaction per user, changed by
  upsert; `reaction_kind` enum heart/congrats/like/ok/wow). Select defers to
  `posts` RLS, so reactions vanish with the moment and are purged with it
  (cascade). Insert/update/delete: own rows only. pgTAP 78-87.

## Surprise teaser (G-210)

- `pending_surprise_teaser()` (definer): for the caller only, returns
  `has_pending` + `next_reveal_at`. The gift rows stay RLS-hidden from the
  recipient; this is the single deliberate exposure. pgTAP 90-92.
- Feed rule (client, `SupabaseHomeRepository.recentEvents`): friends' pending
  surprises are filtered out (`is_surprise=false OR reveal_at<=now`) so a
  surprise reaches the feed only once it opens.

## Reactions on gifts (G-210 slice 2)

- `gift_reactions` mirrors `post_reactions` (PK gift_id+user_id, select
  defers to `gifts` RLS — a pending surprise's reactions stay hidden from the
  recipient, history visibility carries over). Anyone who sees the gift may
  react, parties included.
- `profile_cards(uuid[])` (definer, block-aware): batch discovery cards so
  reactor identities resolve in one call regardless of profile visibility.
  pgTAP 93-98.

## Social push (G-210 slice 3)

- Kinds: **comments** (on my gifts/moments, and on threads I commented in),
  **"a gift was logged for you"** (plain member gifts, on insert → `notify-gift`;
  surprises wait for reveal, external gifts never push) and **"your surprise
  opened"**. Reactions never push (product decision).
- Preference: `profiles.social_notifications_enabled` (Settings →
  Notifications), filtered server-side in `comment_push_targets`; the
  surprise job marks opted-out gifts announced without sending.
- Spoiler guard: the recipient of a still-pending surprise is never a
  comment target for that gift.
- Wiring: DB trigger on both comment tables → pg_net → `notify-comment`
  (Vault secret; skipped locally). Hourly pg_cron `surprise-revealed-hourly`
  → `surprise-revealed` (`gifts.reveal_notified_at` = idempotency; already
  open surprises were backfilled as announced). Both functions and
  `birthday-reminders` share `_shared/fcm.ts` (token + send + stale cleanup)
  and `_shared/messages.ts` (copy; deno tests). **Deploy all three with
  `--no-verify-jwt`.** pgTAP 110-113.

## Hardening notes (review 2026-09-19)

- **Function privileges:** Supabase grants EXECUTE on new `public` functions
  to anon/authenticated by default. Service-only functions
  (`comment_push_targets`, `surprise_reveal_targets`, `birthday_reminder_targets`)
  must `revoke ... from public, anon, authenticated` explicitly — add the
  revoke in the same migration as the function. pgTAP 114 guards this.
- Blocked pairs are filtered on comments/reactions select policies (115).
- Comment pushes re-derive visibility per target (116-117).
- `notify_comment_inserted` wraps pg_net in an exception block: a lost push
  never fails the user's insert.

## Gift events (V3.0-a: G-301/G-302)

- Tables `gift_events` (honoree, creator, event_date, reveal_at, status,
  external_chat_url; one per honoree per birthday) and `gift_event_members`
  (organizer/member × invited/joined/declined).
- **The honoree never sees the event or its members** (select policies
  exclude them; they are never a member). Only members see it. Organizers
  update status/chat link; identity/date columns are frozen by trigger.
- RPCs (definer, authenticated): `create_gift_event(honoree)` — friend-only,
  next birthday, creates or joins the existing open one; `invite_to_gift_event`
  — joined members invite the honoree's friends (block-aware);
  `event_invitable_friends`; `gift_event_for_honoree` (Home row lookup).
- 14-day nudge: pg_cron `event-suggestion-daily` → `birthday-reminders?days=14&kind=event`
  (log PK gained `kind`). pgTAP 120-129.

## Wishlist claims + group gifts (V3.0-b: G-303/G-304)

- `wishlist_claims`: one row per wishlist item (`item_id` unique = the double-buy
  guard). `owner_id` is stamped by a definer trigger from the item; `kind` is
  `solo` or `shared`; `target_amount` only for pools. Guard triggers keep the
  identity columns immutable and forbid `shared → solo`.
- `claim_pledges`: `(claim_id, user_id)` unique, `amount > 0`; insert/update
  refused unless the claim is `shared` (trigger, 23514).
- **RLS is honoree-blind:** only friends of the owner who may view the list
  read/write claims (`owner_id <> auth.uid() and are_friends(...) and
  can_view_wishlist(...)`); pledges defer to the parent claim. The owner and
  strangers get empty results — no teaser, no counts. The claimer updates or
  deletes their claim; a pledge is deleted by its author or the claim's
  organiser. Identities resolve on the client through `profile_cards()`.
- Cascade: deleting the item, the claim, or either profile removes the rows;
  no anonymisation needed (nothing here is history worth keeping).
- pgTAP 137-147.

## Link-preview extractor (single source, 2026-09-21)

- `supabase/functions/link-preview/extractor.js` is the ONE place that knows
  how a shop page exposes title / image / price / site (og tags, JSON-LD,
  itemprop, Amazon's price-to-pay block). Plain script, returns JSON.
- Two hosts run it unchanged: the Edge Function over deno-dom
  (`extract.ts`, text import) for pages the server may fetch, and the app's
  hidden WebView (`WebviewOgFetcher`, the file is bundled as a Flutter asset).
  The WebView loads script-free first (Amazon's full page crashed an
  emulator renderer — Android kills the app with it) and retries with
  scripts only when no title came back.
- `fixtures/*.html` are trimmed real pages per shop; `extractor_test.ts`
  runs the extractor over them. Add a fixture whenever a shop breaks.
- Adjust share links (ty.gl, app.hb.biz → *.adj.st) are unwrapped to the
  web fallback on both hosts (`unwrapTrackingLink`, `tracking_link.dart`).
- Price refresh cadence: `price_checked_at`, daily without a price, monthly
  with one; the server claims the slot, clients only ask (≤3 per list load,
  once per link per session). A refresh never replaces a stored image.

## Event reveal + thanks (V3.0-c: G-306/G-307)

- State machine: `open → revealed` when `reveal_at` passes (cron
  `event-reveal-hourly` → Edge Function `event-reveal` → `event_reveal_targets()`
  flips due events, opens linked surprises via `open_event_gifts`, returns the
  honoree's devices; `mark_event_reveal_notified` stamps them) or early via
  `reveal_gift_event(event)` (organizer only; pings `event-reveal` through
  pg_net so the push lands within seconds). `cancelled` stays terminal.
- Honoree-blind while open (unchanged). Revealed: the honoree reads the event
  and its members; the notes board and the wishlist claims stay hidden from
  the honoree for good. The honoree's only write is one `thanks_note` on a
  revealed event (guard trigger: everything else of that update is dropped,
  organizers cannot touch the note). `gift_events_thanks_notify` → Edge
  Function `notify-event-thanks` → `event_thanks_targets()` → members' push.
- `gifts.event_id`: a joined member logs a gift for the honoree against the
  event (`guard_gift_event_link`, 23514 otherwise); such surprises are
  excluded from `surprise_reveal_targets` (the event push announces them).
- Guard bypass for the machine: `set_config('kept.reveal','on',true)` inside
  the definer RPCs; clients can never set `revealed`.
- Deploy both functions with `--no-verify-jwt` (cron/trigger auth is the
  X-Cron-Secret header). pgTAP 151-163.

## Reservation → gift (G-309)

- `wishlist_claims.gift_id` links a claim to the gift record its claimer
  logged; `attach_claim_gift(claim, gift)` (definer) sets it, snapshots a
  pool's pledgers into `gift_contributors`, and hooks the gift onto the
  honoree's event when the claimer is a joined member.
- `gift_contributors` rows are readable wherever the gift is (policy defers
  to gifts); `gifts_select` admits contributors via the definer helper
  `is_gift_contributor` (no policy recursion).
- Rules in triggers: event gifts are surprises and, while the event is open,
  never open before it (`guard_gift_event_link` lifts the date); a pool with
  a gift is closed to pledge changes; releasing a claim refuses when its gift
  is already visible to the recipient, otherwise the AFTER-delete trigger
  removes the gift record (cascade of the FK set-null would collide with a
  BEFORE delete). pgTAP 167-174.

## Event deletion (26 Sep 2026)

- The organizer deletes an **open** event (`gift_events_delete` policy);
  revealed events are the honoree's memory and cannot be deleted. Members,
  invitations and notes cascade; `gifts.event_id` is set null; reservations
  are untouched. The one-per-birthday rule is a partial unique index that
  ignores `cancelled` rows (the old soft-cancel no longer blocks a new event).
- `event_delete_cleanup` (BEFORE delete, definer) removes group-gift records
  logged before their pool reached its price (unrevealed only; the pool's
  `gift_id` clears and it reopens), captures the joined members' ids and
  pings `notify-event-deleted`, which pushes them via the service-only
  `push_targets_for_users`. pgTAP 176-182.
