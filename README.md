# Giftory

**A personal-inventory social network — with gifting as the wedge.**

Twitter = your ideas · Instagram = your moments · LinkedIn = your work ·
**Giftory = what you own, your taste, your things.** Sharing your inventory isn't
bragging here — it's functional: so friends gift you better and never buy a duplicate.

## Status

📝 Planning / pre-development. Docs are complete; app scaffolding is next.

## Tech Stack

Flutter (iOS + Android) · Supabase (Postgres/Auth/Storage/RLS/Realtime) · FCM (push) ·
Cloudflare R2 (media at scale) · Riverpod · go_router.

## Documentation

| Doc | What |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Engineering guide & quality contract (senior-level standards) |
| [`giftory_vision.md`](giftory_vision.md) | Product vision, positioning, two core loops, roadmap |
| [`backend_research.md`](backend_research.md) | Cost-driven backend decision (→ Supabase) |
| [`pbi/`](pbi/) | Version-based backlog — `README.md` (index) + `v1`–`v4` |

## Roadmap

- **V1** — Core value + identity (wishlist, gift history, birthday reminders, cold-start)
- **V2** — Social loop (instant photo, ephemeral feed, persistent inventory)
- **V3** — Gift events (coordination, surprise/reveal, group chat)
- **V4** — Scale & revenue (affiliate, ads, premium)

See [`pbi/README.md`](pbi/README.md) for the full backlog.
