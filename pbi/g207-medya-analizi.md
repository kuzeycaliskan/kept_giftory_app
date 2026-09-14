# G-207 Medya Altyapısı — Karar Analizi (Supabase Storage vs Cloudflare R2)

> Hazırlayan: Claude · 2026-09-14 · Karar Kuzey ile görüşmede verilecek.
> Bağlam: V2.0-b öncesi. Kullanım alanları: anlık foto (G-201, 24s ephemeral),
> envanter fotoğrafları (G-204, kalıcı), avatar (G-23 devri), link-preview
> thumbnail'leri (G-211, zaten Supabase bucket'ta).

## 1. Güncel fiyatlar (2026-09)

| Kalem | Supabase (Pro $25/ay içinde) | Cloudflare R2 |
|---|---|---|
| Depolama | 100 GB dahil, sonra ~$0.021/GB | 10 GB ücretsiz, sonra $0.015/GB |
| Egress (indirme) | 250 GB dahil; sonrası **cached $0.03/GB**, uncached $0.09/GB | **$0 — sonsuza dek** |
| İşlem ücreti | Yok | Class A $4.50/M, Class B $0.36/M (ihmal edilebilir) |
| CDN | Dahili (Smart CDN, görseller cache'lenir) | Cloudflare ağı (doğal) |

## 2. Kept'e özgü hacim projeksiyonu

Varsayımlar: foto = WebP ~250 KB (G-207 istemci sıkıştırma hedefi); anlık fotolar
24 saatte silinir (G-203) → feed depolaması sabit-küçük kalır; kalıcı yük envanter
(+avatar). Görüntülenme: foto başına ~20 arkadaş.

| Ölçek | Depolama (kalıcı) | Egress/ay | Supabase ek maliyet | R2 ek maliyet |
|---|---|---|---|---|
| **1k kullanıcı** (beta) | ~5 GB | ~45 GB | **$0** (kotalar içinde) | ~$0 |
| **10k kullanıcı** | ~50 GB | ~450 GB | **~$6/ay** (200 GB cached aşım) | ~$1/ay |
| **100k kullanıcı** | ~500 GB | ~4.5 TB | **~$135/ay** (cached varsayımıyla; kötü cache isabetinde $390'a kadar) | **~$15/ay** |

Kırılma noktası: maliyet farkı **~10k kullanıcıya kadar önemsiz** (<$10/ay);
50k+ civarında ayda yüzlerce dolara açılıyor. Zaten `backend_research.md` (satır 26)
100k senaryosunda R2'yi öngörmüştü — rakamlar o öngörüyü doğruluyor.

## 3. Maliyet dışı boyutlar

| Boyut | Supabase Storage | R2 |
|---|---|---|
| **Mahremiyet** (kritik!) | **Storage RLS**: friends-only medya, mevcut `can_view_*` zincirine bağlanır — sunucu tarafında gerçek yetki | Native RLS yok. Ya public bucket + tahmin-edilemez yol (**zayıf**: URL sızarsa herkes açar, arkadaşlıktan çıkarma erişimi kesmez) ya da imzalı URL üreten Worker/Edge Function katmanı (**ek altyapı**) |
| Entegrasyon eforu | ~0 — `supabase_flutter` SDK'da hazır; upload/download/signed URL tek satır | S3 SDK veya Worker; presigned URL akışı; ayrı credential yönetimi; ~2-4 günlük iş + test |
| Operasyon | Tek vendor, tek dashboard | İkinci vendor, ayrı faturalama/izleme |
| 24s silme (G-203) | `pg_cron` job'u Storage API ile siler — aynı ekosistem | Cron → Worker/S3 delete; orphan-reconciliation daha kritik (DB ile ayrı sistem) |
| Kilitlenme riski | Düşük: dosya yolları DB'de; taşıma = kopyalama job'u + URL helper'da prefix değişimi | — |

## 4. Önerim: **Şimdi Supabase Storage, tetikli R2 göçü**

1. **V2 medyası Supabase Storage'da başlar.** Gerekçe: bugünkü ölçekte maliyet farkı
   ~$0; buna karşılık friends-only mahremiyet **Storage RLS ile ilk günden doğru**
   kurulur (Kept'in DNA'sı, vision §5) ve entegrasyon eforu sıfıra yakın — kamera
   işine hemen başlarız.
2. **Soyutlama şart:** tüm erişim `MediaStore` interface'i + tek URL-helper
   üzerinden (CLAUDE.md repository deseninin medya karşılığı). DB'ye her zaman
   yalnız *yol* yazılır, tam URL asla. Böylece göç = kopyalama + helper değişimi.
3. **Göç tetiği (önceden tanımlı, tartışmasız):** aylık faturada storage+egress
   kalemi **$25'i aşarsa** VEYA **~25k aktif kullanıcıya** ulaşılırsa R2 göçü
   planlanır (o gün imzalı-URL Worker'ı da tasarlanır). Bu tetik `pbi/README.md`
   karar listesine işlenir.
4. Link-preview thumbnail'leri zaten bu desene uyuyor (bucket + yol); göç günü
   birlikte taşınır.

**Alternatifin savunusu (adil olmak için):** "Madem 100k'da göçeceğiz, baştan R2"
denebilir. Karşı argüman: o güne kadar aylar var, mahremiyet katmanını (imzalı URL
altyapısı) bugün kurmak kamera/feed'i haftalarca geciktirir ve o altyapı, ölçeğe
ulaşamazsak hiç gerekmeyecek bir yatırım. Erken aşamada hız + doğru mahremiyet >
ileride 1 haftalık göç işi.
