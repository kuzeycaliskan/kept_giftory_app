# CLAUDE.md — Kept Engineering Guide

> This file is the **quality contract** for Kept. It is loaded automatically every
> session so we never re-litigate standards. Treat every rule here as a default, not a
> suggestion. When a rule genuinely doesn't fit a situation, say so explicitly and
> propose the alternative — don't silently ignore it.
>
> **Non-negotiable expectation:** senior-level, production-grade code. No spaghetti, no
> "just make it work" hacks, no god-widgets, no business logic in the UI layer. This app
> is meant to scale and last. Build it like it matters.

---

## 1. Product Context (read the source docs, don't re-derive)

- `vision.md` — product vision, positioning, two core loops, roadmap.
- `pbi/` — version-based backlog: `README.md` (index + project-wide decisions),
  `v1.md` (detailed, dev-ready), `v2.md`/`v3.md`/`v4.md` (scoped).
- `backend_research.md` — cost-driven backend decision (→ Supabase).

Kept = a **personal-inventory social network** with **gifting as the wedge**.
Two loops: (1) social/inventory content, (2) gift-event coordination + reveal.
First market: Turkey. Founder is solo/low-budget — cost-awareness is a design input.

---

## 2. Tech Stack (locked)

| Layer | Choice |
|---|---|
| Client | **Flutter** (iOS + Android) |
| State mgmt | **Riverpod** (with `riverpod_generator` / code-gen) |
| Backend | **Supabase** (Postgres, Auth, Storage, RLS, Realtime) |
| Auth | Social — **Apple + Google** (no phone OTP at login) |
| Push | **FCM** (Android) + **APNs** (iOS) via Supabase Edge Functions + `pg_cron` |
| Media at scale | **Cloudflare R2** (zero egress); client-side WebP compression (~250 KB) |
| Routing | **go_router** (typed routes) |
| Immutability/models | **freezed** + **json_serializable** |
| Lint | **very_good_analysis** (or `flutter_lints` at minimum), zero-warning policy |

Keep dependencies few and well-maintained. Vet each package (maintenance, popularity,
null-safety, license) before adding. Pin versions. Prefer the platform/first-party
solution over a fragile third-party one.

---

## 3. Architecture — Feature-First + Layered (Clean-ish)

Organize by **feature**, and within each feature by **layer**. Dependencies point
inward only: `presentation → application → domain ← data`. The domain layer knows
nothing about Flutter, Supabase, or JSON.

```
lib/
  core/                     # cross-cutting: theme, router, errors, result, extensions, env
  features/
    auth/
      data/                 # repositories impl, data sources, DTOs (Supabase-aware)
      domain/               # entities (freezed), value objects, repository interfaces
      application/          # Riverpod notifiers/providers, use-cases, app state
      presentation/         # screens, widgets (dumb, declarative)
    profile/
    friends/
    wishlist/
    gifts/
    notifications/
    ...
  shared/                   # reusable widgets & UI kit used across features
main.dart
```

**Rules:**
- **UI never touches Supabase directly.** All data access goes through a repository
  interface defined in `domain`, implemented in `data`. This preserves our escape hatch
  (Supabase Cloud → self-host → own VPS) and keeps UI testable.
- Widgets are **dumb**: they render state and emit events. No I/O, no business rules,
  no direct provider mutation of unrelated state.
- Business logic lives in `application` (Riverpod notifiers / use-cases) and `domain`.
- Map Supabase DTOs → domain entities at the data-layer boundary. Never leak DTOs upward.

---

## 4. State Management (Riverpod)

- Use **code-gen** (`@riverpod`) for providers; avoid legacy global `StateProvider`
  sprawl. One notifier per unit of state with a clear responsibility.
- Expose async state as **`AsyncValue`**; handle `loading / data / error` in the UI
  exhaustively — no unhandled error/loading states.
- Keep providers small and composable. No god-provider holding half the app.
- Dispose/autoDispose by default; keep-alive only with justification.
- Never do side effects in `build`. Side effects go in notifier methods triggered by
  user intent.

---

## 5. Error Handling

- Model expected failures as **typed results** — return `Result<T>` / `Either<Failure, T>`
  from repositories, don't throw for control flow. Reserve exceptions for truly
  exceptional/programmer errors.
- Define a `Failure` hierarchy (network, auth, permission, validation, unknown).
- **No silent catches.** Every `catch` either handles meaningfully, maps to a `Failure`,
  or rethrows. Log with context; never swallow.
- User-facing errors are localized, human, and actionable — never raw exception strings.

---

## 6. Security & Privacy (this is core, not an afterthought)

- **RLS is the primary authorization boundary.** Every table default-denies; access is
  granted by explicit policies (`auth.uid()`, friendship checks, visibility columns).
  Never rely on the client to enforce visibility.
- **Layer defense:** RLS + application-layer checks. Never treat the client as trusted.
- **No secrets in the repo.** Use env config (`--dart-define` / env files gitignored).
  Only the Supabase anon key ships in the client (that's expected — it's RLS-gated).
  Service-role keys live only in Edge Functions / server, never in the app.
- **PII discipline:** phone numbers stored **hashed** (matching only), never shown in
  profiles, never logged. Follow KVKK/GDPR: consent flows, data deletion (G-71),
  clear privacy/legal texts (G-74).
- Validate and sanitize all user input. Rate-limit sensitive actions server-side.
- Account deletion must actually delete/anonymize data + media (App Store requirement).

---

## 7. Code Style & Naming

- Follow **Effective Dart**. `dart format` is law (CI enforces). Zero analyzer warnings.
- Names: `UpperCamelCase` types, `lowerCamelCase` members, `snake_case` files, folders
  by feature. Descriptive over clever. No abbreviations that aren't domain-standard.
- No magic numbers/strings — extract to named constants / theme / config.
- Prefer `const` constructors everywhere possible (perf + intent).
- Small functions, single responsibility. If a widget's `build` scrolls off-screen,
  extract sub-widgets (not helper methods returning widgets).
- Comments explain **why**, not **what**. Match the surrounding code's density and idiom.

---

## 8. Testing

- **Unit tests** for domain logic and repositories (mock the Supabase data source).
- **Widget tests** for non-trivial UI and state transitions (loading/error/empty/data).
- **Integration/golden tests** for critical flows as they stabilize (auth, gift logging).
- Test behavior, not implementation. Arrange-Act-Assert. Descriptive test names.
- A PBI is not "done" without tests for its core logic. Bug fixes ship with a regression
  test that fails before the fix.

---

## 9. UI/UX Quality

- Design the full screen set for V1 **before** building (open/splash, home, menus,
  profile, wishlist, gift history, settings) — we'll detail these together in the V1
  PBIs. Every screen has explicit **loading / empty / error / success** states.
- **Empty states drive action** (a social app is empty at first — guide to invite).
- Build **i18n-ready from day one** (`intl`/ARB), even though TR ships first. No
  hardcoded user-facing strings in widgets.
- Accessibility: semantic labels, ≥48dp tap targets, sufficient contrast, respect text
  scaling. Don't ship inaccessible screens.
- Consistent design system: centralized theme, spacing scale, typography, components in
  `shared/`. No ad-hoc colors/sizes.

---

## 10. Performance

- Compress images client-side before upload (WebP, ~250 KB target).
- Paginate lists; never load unbounded collections. Cache thoughtfully.
- Minimize rebuilds (`const`, selective `ref.watch`, granular providers).
- Auto-delete ephemeral media (24h) via `pg_cron` + storage cleanup to control cost.
- Subscribe to Realtime only when needed (active event chat), not app-wide.

---

## 11. Backend / Supabase Conventions

- Schema changes go through **versioned migrations** (checked into the repo). No manual
  console edits to prod schema.
- Every table: RLS enabled, policies written and tested alongside the migration.
- Prefer SQL views / `fan-out-on-read` for feeds over write-amplifying fan-out.
- Edge Functions for privileged/server logic (push dispatch, scheduled jobs).
- Separate **dev / prod** environments and config.

---

## 12. Git & Workflow

- Branch per PBI: `feat/G-41-wishlist-add`, `fix/...`, `chore/...`.
- **Conventional Commits** (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`). Small,
  focused, reviewable commits. Imperative mood.
- Keep the tree green: `dart analyze` + `dart format --set-exit-if-changed` + tests
  must pass before merge. (Wire CI to enforce once repo is initialized.)
- No commented-out code, no dead code, no `TODO` without an owner/context.
- Note: this workspace is not yet a git repo — initialize it before real dev starts.

---

## 13. PBI Writing Standard

Every PBI (as we open it for development) must include:
1. **Description / User story** — "As a <role>, I want <capability> so that <value>."
2. **Acceptance criteria** — concrete, testable, covering happy path + edge/empty/error.
3. **Technical notes** — data model touchpoints, RLS impact, dependencies, patterns to use.
4. **Definition of Done** — implemented + tested + lint-clean + reviewed + states handled
   (loading/empty/error) + docs/strings localized.

Keep the same rigor for UI PBIs (screens) when we detail them in V1.

---

## 14. How To Work With Me On This Project

- Prefer editing/extending existing structure over rewriting. Read before you change.
- When a task is ambiguous, ask; when a sensible default exists, take it and say so.
- Surface trade-offs briefly with a recommendation — don't dump exhaustive option lists.
- Report outcomes honestly: if tests fail, say so; if something is skipped, say so.
- Optimize for the senior-engineer bar on every change. Quality over speed.

### Reviews: report signal, not noise

When I ask you to review/inspect something (docs, code, a change), and there are **no
real problems**, just say **"no problems"** (kısaca: sorun yok) and stop. Do **not**
manufacture findings, invent nitpicks, or surface hypothetical "extra" work to look
thorough. Only raise something when it's a genuine problem or a real open question that
needs my decision. Don't drown me in details — give me the signal, not a wall of
optional extras. If everything's fine, that's a complete and acceptable answer.
