# Kept — Ürün Backlog (PBI) Index

> Kaynak vizyon: `../vision.md` · Kalite sözleşmesi: `../CLAUDE.md`
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
- ✅ Sürpriz koruması: V1'de "sürpriz" flag'i + **reveal_at** kuralı — atanmazsa varsayılan
  alıcının bir sonraki doğum günü +1 gün, o tarihte otomatik görünür (G-51); tam makine V3.
- ✅ Navigasyon: bottom nav = **Home / Gifts / ➕ Add / Me**; Activity (🔔) Home app bar'ında.
  Friends + Wishlist, **Me (profil hub)** altında.
  V2: ➕→kamera, Home→feed+dashboard, Me'ye Envanter sekmesi; V3: Gifts→event hub.
- ✅ Home (V1): üst "Önemli/Yaklaşan" GERÇEK veri; alt "Aktivite" panosu **scaffold+mock**,
  gerçek veri V2'de (G-82). Boş-panel sorununu önler.
- ✅ Profil: header + sekmeli (Wishlist/Geçmiş/Hakkında), görünürlük-duyarlı (G-84).
- ✅ Sıra (1.0-a): `G-01 → G-03(baseline friends-only RLS) → G-31 → G-41/42/51/52` — arkadaş
  görüntüleme PBI'larından önce RLS boundary'si (inceleme bulgusu B1).
- ✅ Büyüme (V1): **davet linki (G-34) birincil** cold-start döngüsü; rehber eşleştirme (G-33)
  ikincil, altyapısı "önce-tasarla" (aşağıda).
- ✅ Auth: **native `signInWithIdToken`** (Apple raw-nonce + Google client-ID matrisi), web-redirect değil (G-11).

## Açık Sorular / Önce-Tasarla (PBI'lar açılırken netleşecek)

- **⚠️ Rehber eşleştirme + telefon doğrulama altyapısı (G-33/G-35) — önce-tasarla:** veri modeli
  (numara nerede/ne kadar saklanır), **E.164 + keyed HMAC** (düz hash değil), server-side
  eşleştirme + rate-limit, **SMS/OTP sağlayıcı seçimi** (Twilio/MessageBird vb. + maliyet),
  HMAC anahtar yönetimi. Build'den önce tasarlanmalı.
- Free-tier 7-gün duraklaması push retention'ı durdurur → lansmandan önce **Supabase Pro** (G-62).
- KVKK aydınlatma metni (G-33/G-35/G-74) — hukuki teyit.
- Doğum günü yıl gizliliği (günü paylaş, yaşı gizle) — ileride (G-13).
- Sürpriz kaydın *varlığı/sayısı* da alıcıya gizli mi? → evet (count sızıntısına karşı, G-51).

## PBI Yazım Standardı (CLAUDE.md §13)

Her PBI geliştirmeye açılırken içermeli: **Description/User story · Acceptance criteria
(happy + edge/empty/error) · Technical notes (veri modeli, RLS, bağımlılık, pattern) ·
Definition of Done**.
