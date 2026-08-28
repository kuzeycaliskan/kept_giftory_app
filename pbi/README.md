# Giftory — Ürün Backlog (PBI) Index

> Kaynak vizyon: `../giftory_vision.md` · Kalite sözleşmesi: `../CLAUDE.md`
> Backend kararı: `../backend_research.md`
>
> Stack: Flutter + Supabase (Postgres/Auth/Storage/RLS/Realtime) + FCM + (ölçekte) Cloudflare R2.
> PBI ID formatı: `G-<epic><no>`. Öncelik: 🔴 zorunlu (MVP) · 🟡 önemli · 🟢 iyi olur.

## Hedeflenen 4 Version

| Version | Tema | Dosya | Detay seviyesi | Durum |
|---|---|---|---|---|
| **V1** | Çekirdek fayda + kimlik | [`v1.md`](v1.md) | Geliştirmeye hazır (user story + kabul + tech) | 📝 Planlandı |
| **V2** | Sosyal döngü (içerik motoru) | [`v2.md`](v2.md) | Kapsam listesi | 🔭 Kapsam |
| **V3** | Hediye event'i (koordinasyon + reveal) | [`v3.md`](v3.md) | Kapsam listesi | 🔭 Kapsam |
| **V4** | Ölçek & gelir | [`v4.md`](v4.md) | Kapsam listesi | 🔭 Kapsam |

> V2–V4 kapsam hâlindedir; sırası gelince V1 detayına (user story + kabul kriterleri +
> teknik not + DoD) açılacak. Yeni version dosyası eklenince bu tabloyu güncelle.

## Proje-geneli Kararlar

- ✅ Login: **Sosyal (Apple + Google)** — telefon OTP yok.
- ✅ State management: **Riverpod**.
- ✅ Backend: **Supabase** (bkz. `../backend_research.md`).
- ✅ Telefon numarası: login **sonrası** ayrı adımda alınır+doğrulanır (G-35), atlanabilir;
  rehber eşleştirmenin (G-33) önkoşulu.
- ✅ Sürpriz koruması: V1'de basit "sürpriz" flag'i (G-51); tam reveal makinesi V3.
- ✅ Navigasyon: bottom nav = **Home / Gifts / ➕ Add / Me**; Activity (🔔) Home app bar'ında.
  Friends + Wishlist, **Me (profil hub)** altında.
  V2: ➕→kamera, Home→feed+dashboard, Me'ye Envanter sekmesi; V3: Gifts→event hub.
- ✅ Home: üstte "Önemli/Yaklaşan" section + altta karışık aktivite panosu (G-82).
- ✅ Profil: header + sekmeli (Wishlist/Geçmiş/Hakkında), görünürlük-duyarlı (G-84).

## Açık Sorular (PBI'lar açılırken netleşecek)

- Rehber eşleştirmede KVKK aydınlatma metni + numara saklama (hash) politikası — hukuki teyit (G-33/G-35/G-74).
- Doğum günü yıl gizliliği (günü paylaş, yaşı gizle seçeneği) — ileride (G-13).

## PBI Yazım Standardı (CLAUDE.md §13)

Her PBI geliştirmeye açılırken içermeli: **Description/User story · Acceptance criteria
(happy + edge/empty/error) · Technical notes (veri modeli, RLS, bağımlılık, pattern) ·
Definition of Done**.
