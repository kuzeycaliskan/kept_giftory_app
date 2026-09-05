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
