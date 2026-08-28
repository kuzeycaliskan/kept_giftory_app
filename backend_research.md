# Kept — Backend / BaaS Seçimi: Maliyet-Öncelikli Karşılaştırma Raporu

> **Hazırlanma tarihi:** 2026-08-28
> **Uygulama:** Kept — Flutter (iOS + Android), kişisel envanter odaklı **sosyal ağ + hediyeleşme** uygulaması.
> **Öncelik #1:** Minimum maliyet. Erken aşama (0–1000 kullanıcı) ve büyüme (10k, 100k) için gerçek rakamlar.
> **Not:** Tüm fiyat/limit iddiaları resmi kaynaklardan 2026-08-28 tarihinde doğrulanmıştır. Maliyet tahminleri, belirtilen kullanım varsayımlarına dayalı **mühendislik projeksiyonlarıdır** — birim fiyatlar kaynaklıdır, toplamlar sizin gerçek metriklerinize göre değişir. Fiyatlar hızla değiştiği için kritik kararlardan önce canlı fiyat sayfalarını teyit edin.

---

## 1. Yönetici Özeti + Net Öneri

### Kısa cevap: **Supabase (Free → Pro)**

Kept'in veri modeli **ilişkisel-ağırlıklıdır**: arkadaş grafiği (social graph), bölüm-bazlı granüler mahremiyet (public/friends/private), event üyelikleri + durum makinesi, hediye geçmişi. Bu tam olarak Postgres'in ve Postgres RLS'in (Row Level Security) güçlü olduğu yerdir. Aynı zamanda Supabase'in fiyatlandırması **kaynak-bazlıdır** (compute + storage + bandwidth), **işlem-bazlı değildir** — bu, sosyal/feed uygulamalarının Firebase'de düştüğü "her okuma/yazma para" tuzağından sizi korur.

**Neden Firebase değil (maliyet önceliğiyle):** Firebase Firestore **işlem başına** faturalar ($0.06/100k okuma, **$0.18/100k yazma**). Sosyal grafik + feed + fan-out (bir gönderiyi N takipçiye yazmak = N yazma) bu modelde kontrolsüz büyür. Orta yoğunlukta bile 100k kullanıcıda **~$1.700–2.200/ay**, agresif feed'de **$10k/ay**'ı aşabilir. Ayrıca 2026-02-03'ten itibaren **Cloud Storage artık ücretsiz Spark planında YOK** — fotoğraf storage için Blaze (kredi kartı) zorunlu.

**Neden PocketBase / kendi VPS değil (şimdilik):** Dolar maliyeti en düşük yol budur (100k kullanıcıda bile **<$75/ay** mümkün), ama tüm DevOps yükünü tek kişiye yıkar (yedekleme, güvenlik yaması, upgrade migrasyonları, HA yok, gece 3'te sunucu düşerse "siz"). PocketBase ayrıca hâlâ **v1.0 değil** (v0.40.1) ve yazarı resmi olarak "production-critical uygulamalar için önerilmez" diyor. Solo, düşük bütçeli bir kurucu için bu **para değil zaman riski**dir.

### Önerilen yol haritası (maliyet-optimize)

| Aşama | Öneri | Tahmini aylık maliyet |
|---|---|---|
| **0–1.000 kullanıcı** | Supabase **Free** plan (fotoğrafları sıkıştırıp <1GB'da tutarsanız) veya **Pro $25** (rahatlık + proje uyku sorunu yok) | **$0 – $25** |
| **~10.000 kullanıcı** | Supabase **Pro** + küçük overage | **~$35 – $90** |
| **~100.000 kullanıcı** | Supabase **Pro** (compute + egress ağırlıklı) — o noktada **büyük tasarruf için fotoğrafları Cloudflare R2'ye (sıfır egress) taşıyın** | **~$300 – $600** (R2 ile egress'i kırarak daha da düşük) |

**Tek cümlelik gerekçe:** Supabase, Kept'in ilişkisel doğasına ve granüler mahremiyet ihtiyacına en iyi uyan, maliyeti **öngörülebilir ve düz** olan, vendor lock-in'i düşük (saf Postgres, istediğinizde `pg_dump` ile taşınabilir), Flutter SDK'sı olgun ve gerekirse **ücretsiz self-host**'a kaçış kapısı olan seçenektir.

---

## 2. Karşılaştırma Tablosu

### 2.1 Ücretsiz (Free) Tier Limitleri

| Kaynak | **Firebase (Spark)** | **Supabase (Free)** | **Appwrite Cloud (Free)** | **PocketBase** (self-host) | **Kendi VPS + Postgres** |
|---|---|---|---|---|---|
| DB boyutu | 1 GiB (Firestore) | **500 MB** | reads 500K/ay, writes 250K/ay | Disk kadar (SQLite) | Disk kadar |
| Storage | **Yok (2026-02'den Blaze şart)** | 1 GB | 2 GB | Disk kadar | Disk kadar |
| Bandwidth/egress | 10 GiB/ay (Firestore) | 5 GB (+5 GB cached) | 5 GB/ay | VPS trafiği (Hetzner 20 TB!) | VPS trafiği |
| Auth MAU | **50.000** | **50.000** | **75.000** | Sınırsız (kendi sunucun) | Sınırsız |
| Okuma/yazma | 50K okuma + 20K yazma **/gün** | İşlem limiti yok (compute-bound) | 500K okuma + 250K yazma /ay | İşlem limiti yok | İşlem limiti yok |
| Realtime | RTDB: 100 eşzamanlı bağlantı | **200 eşzamanlı**, 2M mesaj/ay | 250 eşzamanlı, 2M mesaj/ay | ~10K SSE bağlantı (2vCPU/4GB) | Kendiniz |
| Function çağrısı | 2M/ay | 500K Edge Fn/ay | 750K/ay | — (Go hook) | — |
| **Push (FCM)** | **Ücretsiz/sınırsız** | Yok → FCM gerekir | Messaging var (FCM/APNs kullanır) | Yok → FCM gerekir | Yok → FCM gerekir |
| Proje uyku | Yok | **7 gün inaktivite → durur** | 1 hafta inaktivite → durur | Yok | Yok |
| Proje sayısı | Sınırsız (kota içinde) | 2 aktif proje | 2 proje | Sınırsız | Sınırsız |

### 2.2 Ölçek Bazlı Tahmini Aylık Maliyet (USD)

> Varsayımlar seçenekler arasında farklıdır (Firebase işlem-bazlı, diğerleri kaynak-bazlı). Detay ve aritmetik her seçeneğin bölümünde. **Fotoğraf yoğunluğu en büyük değişkendir.**

| Ölçek | **Firebase** | **Supabase** | **Appwrite Cloud** | **PocketBase (VPS)** | **Kendi VPS + Postgres + R2** |
|---|---|---|---|---|---|
| **~1.000 kullanıcı** | ~$15–20 | **$0–25** | $25 | **~$6–7** | **~$6–7** |
| **~10.000 kullanıcı** | ~$150–200 | **~$35–90** | ~$40–55 | **~$11–14** | **~$11–14** |
| **~100.000 kullanıcı** | **~$1.700–2.200** (feed'de $10k+) | ~$300–600 | ~$580 | **~$35–75** | **~$35–75** |

**Kritik gözlem:** Firebase'in eğrisi işlem hacmiyle **dikey** yükselir; Supabase/Appwrite **kaynakla düz** yükselir; self-host **neredeyse yatay** kalır (ama DevOps zamanı maliyeti gizlidir).

---

## 3. Her Seçenek İçin Artı / Eksi

### 3.1 Firebase (Firestore + Auth + Storage + Functions + FCM)

**Artılar**
- FCM **ücretsiz ve sınırsız** (her iki planda, mesaj başı ücret yok) — push için endüstri standardı.
- FlutterFire olgun, Google-bakımlı, birinci sınıf (`cloud_firestore` ~v6.x, `firebase_auth` ~v6.x, `flutterfire configure` CLI).
- Gerçek zamanlı listener'lar (`onSnapshot`), offline persistence "kutudan çıkar çıkmaz" çalışır.
- Auth 50k MAU'ya kadar ücretsiz; sosyal/telefon/anonim login hazır.

**Eksiler**
- **İşlem-bazlı fatura sosyal grafik için tuzak.** Yazma $0.18/100k (okumanın 3 katı). Fan-out-on-write modelde bir gönderi N takipçiye = N yazma. 100k kullanıcıda ~$1.700–2.200/ay, agresif feed'de $10k+/ay.
- **2026-02-03'ten beri Cloud Storage ücretsiz Spark'ta YOK** — fotoğraf için Blaze (kredi kartı) zorunlu. Kaynak: firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024
- Realtime listener'lar ayrıca ücretlendirilmez ama **her teslim edilen doküman = 1 okuma**; çok güncellenen listener'lar okuma maliyetini katlar.
- **Yüksek vendor lock-in:** proprietary veri modeli, SQL yok, self-host yok, security rules + listener'lar taşınamaz. Çıkış tek yönlü export.
- Granüler mahremiyet **Firestore Security Rules** ile — güçlü ama ilişkisel/graph sorgular (friends-of, cross-collection) zahmetli ve denormalizasyona zorlar.

### 3.2 Supabase (Postgres + Auth + Storage + RLS + Realtime + FCM)

**Artılar**
- **Kaynak-bazlı fatura** (compute + storage + egress + MAU), işlem-bazlı değil → sosyal/feed workload'u için **öngörülebilir, düz maliyet**.
- **Postgres RLS** granüler mahremiyet için sınıfının en iyisi: politikalar SQL WHERE-filtresi olarak her sorguya otomatik enjekte edilir, default-deny. `auth.uid()` / `auth.jwt()` yardımcıları. Postgres 9.5'ten (2015) beri production-hardened.
- **İlişkisel/graph için ideal**: gerçek SQL, JOIN, foreign key. Arkadaş grafiği, event üyeliği, durum makinesi doğal modellenir.
- Realtime 3 primitif: **Postgres Changes** (DB değişikliği aboneliği), **Broadcast** (efemeral mesaj), **Presence** (online/typing durumu) — event chat'e uygun.
- **Düşük lock-in:** saf Postgres, `pg_dump` ile her yere taşınır; tüm stack açık kaynak, self-host edilebilir.
- Flutter SDK olgun (`supabase_flutter` ~v2.17, 6 platform, Auth/DB/Realtime/Storage/Edge Functions).
- Free tier cömert: **50k MAU, 200 realtime bağlantı, 2M realtime mesaj, 500K Edge Fn**.

**Eksiler**
- Free plan **7 gün inaktivite sonrası projeyi durdurur** (erken/demo aşamada dikkat — Pro'da yok).
- Free DB **sadece 500 MB**, storage 1 GB → fotoğraf yoğunluğu hızla Pro'ya iter.
- **Push yok** → FCM/APNs kendiniz kurmalısınız (device token'ı Postgres'te → DB trigger/`pg_net` → Edge Function → FCM HTTP v1).
- RLS **kolon-bazlı gizleme yapmaz** (satır-bazlı); yanlış yapılandırma gerçek risk (bir 2025 analizinde test edilen AI-üretimi uygulamaların %10,3'ü eksik RLS'ten veri sızdırmış) → RLS'i uygulama-katmanı kontrolüyle **katmanlayın**, tek savunma yapmayın.
- Ölçekte egress + compute maliyeti domine eder (100k'da ~$600+); R2'ye offload ile kırılabilir.

### 3.3 Appwrite (Cloud / Self-host)

**Artılar**
- **Dahili Messaging servisi**: push (FCM/APNs), email, SMS — Supabase/PocketBase'in aksine push için ekstra kod daha az (yine FCM credential'ı siz sağlarsınız).
- Grant-bazlı, default-deny, additive izin sistemi: tablo + satır/doküman seviyesinde. Roller: `Role.any()`, `Role.users()`, `Role.user(id)`, `Role.team(id)`, `Role.label()`.
- Mahremiyet modeli temiz map olur: Public=`Role.any()`, Friends=`Role.team("FRIENDS_TEAM")`, Private=`Role.user("OWNER")`.
- **BSD-3 lisanslı, self-host edilebilir**; Cloud↔self-host aynı API → yön değiştirmek kolay. Dahili Migrations aracı (Firebase/Supabase/Nhost'tan import da eder).
- Flutter SDK olgun (`appwrite` ~v20.x, 6 platform, first-class Dart).
- Free tier cömert: **75k MAU**, 750K execution, 250 realtime bağlantı.

**Eksiler**
- **Fiyatlandırma geçiş halinde / tutarsız (BÜYÜK UYARI):** Canlı sayfa "Pro from $25/mo, sınırsız üye, 2TB bandwidth" derken; blog yazıları "$15/üye/ay, 300GB" ve silinmiş görünen "Scale $685/ay" diyor. **Bütçelemeden önce konsoldan teyit edin.**
- Veri modeli **doküman-tabanlı** (2025-26'da "TablesDB" olarak ilişkisel görünümlü yeniden markalandı) ama **gerçek ilişkisel SQL motoru değil** — ağır social-graph + karmaşık JOIN güçlü yanı değil.
- "Friends as teams" modeli büyük karşılıklı-takip grafiklerinde yönetim yükü getirir (team üyelik overhead'i).
- Self-host için üretim donanım öneri/container listesi net belgelenmemiş (min. 1 core/2GB "başlamak için", production için değil).

### 3.4 PocketBase (self-host, tek Go binary)

**Artılar**
- **Ultra düşük dolar maliyeti:** yazılım $0 (MIT), sadece VPS ~**€4,49–6/ay** (Hetzner). Tek binary, harici bağımlılık yok.
- Yazarın kendi benchmark'ı: **2vCPU/4GB'lık ucuz Hetzner'da 10.000+ eşzamanlı realtime bağlantı**.
- API Rules güçlü: `listRule/viewRule/create/update/deleteRule` filtre-ifadeleri; **kurallar aynı zamanda satır filtresi** (görmemesi gereken satırları sessizce eler). Cross-collection join (`@collection.*`) ile friends-only ifade edilebilir.
- Dahili: SQLite + realtime (SSE) + auth + file storage + admin panel; TLS otomatik (Let's Encrypt); yedekleme API'si dahili.
- Resmi Dart SDK olgun (`pocketbase` ~v0.25, 6 platform).
- Kurulum çok kolay (binary + domain = 1 saatte ayakta).

**Eksiler**
- **Hâlâ v1.0 DEĞİL (v0.40.1).** Resmi doküman: *"production-critical uygulamalar için önerilmez, ara sıra changelog okuyup manuel migrasyon yapmaya razı değilseniz."* → **en önemli caveat.**
- **Sadece dikey ölçekleme (tek sunucu).** SQLite tek-yazar; sharding/multi-node HA yok. Yazma-yoğunlukta `SQLITE_BUSY`. 100k kullanıcıda mimari çıkmaz olabilir.
- **Push yok** → FCM/APNs kendiniz. SSE arka planda/kapalı uygulamaya bildirim gönderemez → "arkadaşın hediye gönderdi" bildirimi için FCM şart.
- Sosyal-graph için kanonik örnek yok; karmaşık (friends-of-friends, simetrik friendship) durumlar sizin mühendislik riskiniz, çoğu zaman özel Go hook gerektirir.
- Tüm DevOps yükü sizde (yedek off-site, upgrade migrasyonları, uptime, HA yok).

### 3.5 Kendi VPS + Postgres (ve self-host Supabase varyantı)

**Artılar**
- **En düşük dolar maliyeti, en yüksek kontrol.** Postgres'i API ile aynı kutuda çalıştırınca DB marjinal maliyeti $0. Hetzner ~€5,49–15,99/ay, **20 TB dahili trafik** (fotoğraf için harika).
- **Fotoğrafları Cloudflare R2**'de tutunca **egress $0 (sonsuza dek ücretsiz)** — sosyal fotoğraf uygulamasının en büyük maliyet kalemi (egress) sıfırlanır. 10 GB depolama ücretsiz, sonra $0.015/GB.
- Saf Postgres = sıfır lock-in, tam RLS gücü. Self-host Supabase ile aynı DX'i ~VPS ücretine alabilirsiniz ($0 lisans).
- FCM (ücretsiz) her senaryoda push'u çözer.

**Eksiler**
- **DevOps yükü tamamen sizde:** güvenlik yaması (~1–3 sa/ay), yedekleme + restore testi (kurulum 4–8 sa, ~1 sa/ay), upgrade migrasyonları (major başına yarım-tam gün), monitoring, **HA/failover YOK** — kutu düşerse siz. Gerçekçi steady-state **~4–10 sa/ay + üst sınırsız incident zamanı**.
- Self-host Supabase: yönetilen yedek/PITR yok, branching/multi-project yok (staging = 2. tam stack), config dosya-bazlı, auth email için kendi SMTP'niz.
- 100k'da muhtemelen DB'yi ayrı kutuya + 2. app node'a ayırmak gerekir.

---

## 4. "Bu Uygulamaya Özel" Değerlendirme

Kept'in 4 zorlu gereksinimi ve seçeneklerin uyumu:

### (a) Granüler Mahremiyet — public/friends/private, bölüm-bazlı (profil/envanter/hediye geçmişi ayrı)
- **Supabase (RLS): EN İYİ.** Her bölüm için tabloya politika; `visibility='public' OR owner=auth.uid() OR EXISTS(SELECT 1 FROM friendships WHERE ...)` gibi ifadeler doğal. Bölüm-bazlı ayrı görünürlük = ayrı tablolar/kolonlar + ayrı politikalar. Postgres JOIN ile friends kontrolü verimli.
- **Appwrite:** İyi — Public/Friends(team)/Private rolleriyle map olur ama "friends = team" büyük grafiklerde hantal.
- **PocketBase:** İfade edilebilir (`@collection` join) ama kanonik örnek yok, karmaşıklık sizin riskiniz.
- **Firebase:** Security Rules güçlü ama ilişkisel friends-kontrolü için veri denormalizasyonu ve ek okuma maliyeti getirir.

### (b) Social Graph (arkadaş grafiği)
- **Postgres tabanlılar (Supabase / kendi VPS): EN İYİ** — foreign key + JOIN + recursive CTE (friends-of-friends) native.
- **Firebase / Appwrite / PocketBase:** graph sorguları ya denormalizasyon ya çoklu okuma ya özel kod gerektirir. Firebase'de fan-out yazma maliyeti tuzağı burada devreye girer.

### (c) Efemeral Feed (24 saatte kaybolan post, Snap/BeReal tarzı)
- **Tüm seçeneklerde çözülebilir**; anahtar **maliyet-minimize silme**:
  - Postgres tabanlı: `expires_at` kolonu + RLS'te `expires_at > now()` filtresi (görünmez yapar) + `pg_cron` (Supabase'de mevcut) ile gece toplu DELETE + **R2/Storage'dan fotoğrafı da sil** (storage maliyetini biriktirmemek kritik).
  - Firebase: TTL policy (Firestore native TTL) + Storage lifecycle rule; ama **her silme = yazma maliyeti** (20K/gün ücretsiz sonra $0.02/100k).
- **Öneri:** Efemeral fotoğrafları ana storage'dan **ayrı bir bucket/prefix**'te tutup lifecycle/cron ile agresif otomatik sil.

### (d) Push (doğum günü hatırlatma — retention için kritik) + Event Chat Realtime
- **Push:** **Hiçbir BaaS bunu tek başına çözmez** — arka planda/kapalı uygulamaya bildirim için **FCM (Android) + APNs (iOS) her durumda gerekir.** Firebase'de yerleşik ve ücretsiz; Appwrite'ta Messaging sarmalar (yine FCM); Supabase/PocketBase/VPS'te kendiniz kurarsınız (device token → cron/trigger → Edge Function/hook → FCM HTTP v1). Doğum günü hatırlatması = zamanlanmış iş (Supabase `pg_cron` + Edge Function; kendi VPS'te cron).
- **Event chat:** Supabase Realtime (Broadcast/Presence), Appwrite Realtime, PocketBase SSE hepsi yeterli. Supabase Broadcast + Presence (typing/online) event chat için en zengin.

**Sonuç:** Kept'in dört gereksinimini bir arada en temiz karşılayan **Supabase**'dir (RLS + gerçek ilişkisel + `pg_cron` + Realtime), tek eksiği push için FCM entegrasyonu — ki bu **her seçenekte zorunlu**.

---

## 5. Maliyeti Minimumda Tutmak İçin Somut Mimari Öneriler

1. **Fotoğrafları istemcide sıkıştırın** (WebP/AVIF, ~250 KB hedef). Storage GB ve egress GB doğrudan buna bağlı; sosyal uygulamada **egress + storage en büyük maliyet kalemi**. Flutter'da `flutter_image_compress` gibi paketlerle upload öncesi küçültün.

2. **Efemeral (24s) fotoğrafları otomatik silin.** `expires_at` kolonu + RLS filtresiyle görünmez yapın; `pg_cron` (Supabase) veya cron ile gece hem DB satırını hem storage objesini silin. Biriken efemeral medya = gereksiz storage faturası.

3. **Ölçekte fotoğrafları Cloudflare R2'ye taşıyın (SIFIR egress).** BaaS storage egress'i pahalıdır (S3-tarzı ~$0.09/GB). R2 **egress ücretsiz + $0.015/GB storage + 10 GB ücretsiz**. 100k kullanıcıda günde 200 GB indirme = ~6 TB/ay → S3'te ~$540 egress; R2'de **$0**. Supabase/kendi VPS ile R2 kombinasyonu maliyeti dramatik kırar.

4. **Firestore'un fan-out tuzağından kaçının.** Sosyal grafik + feed'de işlem-bazlı fatura patlar. Postgres tabanlı (Supabase) kalın; feed'i JOIN/view ile "fan-out-on-read" yapın, "fan-out-on-write" ile N takipçiye N yazma yapmayın.

5. **Push'u zamanlanmış toplu işle çözün.** Doğum günü hatırlatmalarını gerçek zamanlı değil, günlük `pg_cron`/cron job + FCM HTTP v1 batch ile gönderin (FCM ücretsiz). Device token'ları DB'de tutun.

6. **Free tier'da kalma taktikleri (0–1k):**
   - Supabase Free: DB'yi <500 MB tutun (metadata + ilişkiler DB'de, medya storage/R2'de — DB'ye asla binary koymayın), fotoğrafları R2'ye alarak 1 GB storage limitini aşmayın.
   - **Proje uyku sorunu:** Free plan 7 gün inaktivitede durur — demo/erken aşamada basit bir cron ping ile canlı tutun, ya da erken $25 Pro'ya geçin (uyku yok).
   - MAU limitleri cömert (Supabase 50k, Appwrite 75k) — auth maliyeti 10k'ya kadar $0.

7. **Realtime'ı seçici kullanın.** Sadece aktif event chat açıkken abone olun; feed'i realtime yerine pull/refresh yapın. Realtime mesaj/bağlantı overage'ı ölçekte birikir.

8. **Compute'u kademeli büyütün.** Supabase'de Micro ($10 kredi Pro'ya dahil) ile başlayın; performans darboğazı görene kadar büyütmeyin. Overage'lar (DB/storage/egress GB) küçük; asıl kalem compute + egress.

9. **Kaçış kapısını açık tutun (lock-in azalt).** Uygulamada bir repository/abstraction katmanı kullanın; Postgres tabanlı kalırsanız Supabase Cloud → self-host Supabase → kendi VPS geçişi `pg_dump` ile kolaydır. Maliyet baskısı artarsa **aynı kodla** self-host'a inip maliyeti VPS ücretine (~€8–16/ay) çekebilirsiniz.

---

## 6. Kaynak Linkleri (her fiyat/limit iddiası için — erişim: 2026-08-28)

### Firebase
- Firestore fiyat/limit: https://firebase.google.com/docs/firestore/pricing
- Firestore fatura örneği (birim fiyatlar): https://firebase.google.com/docs/firestore/billing-example
- Genel fiyatlandırma (FCM "No-cost", Auth MAU): https://firebase.google.com/pricing
- Cloud Functions fiyat: https://cloud.google.com/functions/pricing-1stgen
- Identity Platform (Auth) fiyat: https://cloud.google.com/identity-platform/pricing
- **Storage değişikliği (2026-02'den Blaze şart):** https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024
- FlutterFire kurulum: https://firebase.google.com/docs/flutter/setup
- FCM Flutter: https://firebase.google.com/docs/cloud-messaging/flutter/get-started

### Supabase
- Fiyatlandırma (tüm limitler + overage): https://supabase.com/pricing
- Compute/disk instance'ları: https://supabase.com/docs/guides/platform/compute-and-disk
- Realtime: https://supabase.com/docs/guides/realtime
- RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- RLS yeterli mi (güvenlik analizi): https://axonbuild.com/blog/is-supabase-rls-enough/
- Flutter SDK: https://pub.dev/packages/supabase_flutter · https://github.com/supabase/supabase-flutter

### Appwrite
- Fiyatlandırma (canlı — otoritatif): https://appwrite.io/pricing
- Pro duyuru blog (çelişkili $15/üye — teyit gerekir): https://appwrite.io/blog/post/announcing-appwrite-pro
- İzinler: https://appwrite.io/docs/products/databases/permissions · https://appwrite.io/docs/advanced/platform/permissions
- Messaging (push/FCM/APNs): https://appwrite.io/docs/products/messaging
- Self-host: https://appwrite.io/docs/advanced/self-hosting
- Migrations: https://appwrite.io/docs/advanced/migrations/cloud
- Flutter SDK: https://pub.dev/packages/appwrite · https://github.com/appwrite/sdk-for-flutter

### PocketBase
- Docs (v1.0 değil uyarısı): https://pocketbase.io/docs/
- FAQ (vertical-only, 10k realtime benchmark): https://pocketbase.io/faq/
- Lisans (MIT): https://github.com/pocketbase/pocketbase/blob/master/LICENSE.md
- Releases (v0.40.1): https://github.com/pocketbase/pocketbase/releases
- API Rules & Filters: https://pocketbase.io/docs/api-rules-and-filters/
- Realtime (SSE): https://pocketbase.io/docs/api-realtime/
- Production'a geçiş: https://pocketbase.io/docs/going-to-production/
- Dart SDK: https://pub.dev/packages/pocketbase · https://github.com/pocketbase/dart-sdk

### VPS / Storage / Self-host
- **Cloudflare R2 (sıfır egress) — resmi:** https://developers.cloudflare.com/r2/pricing/
- Backblaze B2: https://www.backblaze.com/cloud-storage/pricing
- DigitalOcean Droplets: https://www.digitalocean.com/pricing/droplets
- **Hetzner fiyat ayarı (Haziran 2026, resmi):** https://docs.hetzner.com/general/infrastructure-and-availability/price-adjustment/
- Hetzner Object Storage: https://www.hetzner.com/storage/object-storage/
- Hetzner Cloud: https://www.hetzner.com/cloud/
- FCM ücretsiz (resmi): https://firebase.google.com/pricing · https://firebase.google.com/docs/cloud-messaging

---

## Ek: Doğrulama Notları ve Uyarılar

- **Firebase Cloud Storage:** 2026-02-03'ten itibaren ücretsiz Spark planında YOK — fotoğraf için Blaze zorunlu. (Kaynak: resmi storage FAQ.)
- **Appwrite fiyatlandırması geçiş halinde:** canlı sayfa ($25/2TB) ile bloglar ($15/üye/300GB, Scale $685) çelişiyor — **konsoldan teyit edin.**
- **PocketBase v0.40.1**, hâlâ v1.0 değil; yazar production-critical için önermiyor.
- **Hetzner isimlendirme:** Resmi Haziran-2026 ayarı CX23/CX33/CX43'ü €5,49/€8,49/€15,99 olarak veriyor; CX22/CX32/CX42 fiyatları ikincil kaynaktan — konsoldan teyit edin.
- **Supabase compute dolar rakamları** (Small–16XL) docs'tan yuvarlanmış; canlı hesaplayıcıdan teyit edin. Tier yapısı güvenilir.
- **Tüm ölçek maliyet tahminleri**, belirtilen kullanım varsayımlarına dayalı mühendislik projeksiyonlarıdır (fotoğraf/kullanıcı ve görsel boyutu en hassas değişken); yalnızca **birim fiyatlar** resmi kaynaklıdır. Gerçek ürün metriklerinizle yeniden hesaplayın.
