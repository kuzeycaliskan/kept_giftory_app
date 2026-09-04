1# Kept — Ürün Vizyon Dokümanı

> Bu doküman, `initial_idea.md` (ilk beyin fırtınası) üzerine yapılan
> stratejik tartışma sonrası ortaya çıkan **olgunlaşmış vizyonu** özetler.
> PBI'lar (version bazlı iş kalemleri) bu dokümandan türetilecektir.
>
> Durum: Vizyon ve teknik stack kararları netleşti (bkz. §8 ve `backend_research.md`).
> Version bazlı PBI'lar `pbi/` altında (V1 detaylı, V2–V4 kapsam).

---

## 1. Tek Cümlelik Vizyon

**Kept, insanların sahip oldukları eşyaları / zevklerini paylaştığı bir sosyal
ağdır; hediyeleşme ise bu ağa girişi sağlayan kancadır (wedge).**

Konumlandırma — boş bir alana oturuyor:

- Twitter → fikirlerini paylaşırsın
- Instagram → estetik anlarını paylaşırsın
- LinkedIn → işini/kariyerini paylaşırsın
- **Kept → neye sahip olduğunu, zevkini, eşyalarını paylaşırsın**

Kritik içgörü: "Envanterimi neden paylaşayım?" sorusunun cevabı hediyeleşmede gizli.
Envanteri paylaşmak burada **gösteriş değil, fonksiyoneldir** — "arkadaşlarım bana
daha iyi hediye alsın, aynısını iki kez almasın" diye. Fayda ve vitrin aynı anda.

İsim de bunu yakalıyor: **Kept = "sakladığın şeyler"** — sahip olduğun/tuttuğun eşyalar
ve hediye anıları.

---

## 2. Problem & Hedef Kullanıcı

**Ana problem:** "Arkadaşıma ne hediye alacağımı bilmiyorum ve daha önce ne aldığımızı
hatırlamıyorum." Yıllardır aynı grupta hediyeleşen insanlar için hediye bulmak yorucu,
tekrar riski yüksek, koordinasyon zayıf.

**Hedef kullanıcı:** Düzenli hediyeleşen yakın arkadaş grupları (önce Türkiye pazarı —
kültürel adaptasyon avantajı, güçlü yerel rakip yok).

---

## 3. İki Çekirdek Döngü (Mimarinin Temeli)

**Döngü 1 — Sosyal / Envanter (içerik motoru):**
Yeni bir şey aldın / hediye geldi → **anlık foto** (galeriden değil, o an, Snap/BeReal
otantikliği) → hem 24 saatlik feed postu olur, hem **kalıcı** olarak envanterine/rafına
düşer → arkadaşlar görür, reaksiyon verir, fikir alır → Döngü 2'yi besler.

**Döngü 2 — Hediye Event'i (koordinasyon + reveal):**
Doğum günü yaklaşır → event otomatik önerilir / manuel açılır → arkadaşlar event'e girer,
koordine olur (kim ne alıyor, rezervasyon, pahalıya ortak olma, grup chat) → hediyeler
alınır → **reveal günü** (deadline sonrası veya herkes onaylarsa) → sahibi kimin ne
aldığını görür, teşekkür eder, unboxing paylaşır → bu da Döngü 1'e içerik olur.

İki döngü birbirini besler.

---

## 4. Temel Özellikler

### 4.1 Profil
Doğum günü, yaş, cinsiyet, meslek, ilgi alanları, favori markalar, takım, hobiler,
**unique kullanıcı adı** (Instagram gibi). Bölüm bazında görünürlük (bkz. §5).

### 4.2 Envanter (Kişisel Eşyalar)
Kullanıcının sahip olduğu ürünler (telefon, laptop, konsol, kulaklık, saat...).
Kalıcı bir "vitrin/raf". Anlık foto çekimiyle beslenir. Görünürlüğü ayarlanabilir.

### 4.3 Wishlist (İstek Listesi)
Kullanıcının istediği ürünler. Arkadaşları doğrudan buradan seçip alabilir → yanlış
hediye riski düşer. (Ürün girişi: ilk sürümde serbest metin / link; ileride katalog +
affiliate link.)

### 4.4 Hediye Geçmişi
Alınan hediyelerin kaydı. **Veri girişini alan kişi yapar.** Sürpriz korunur çünkü sahibi
event'teki hediyeleri ancak **reveal gününde** (deadline sonrası ertesi gün) veya
katılımcılar onaylarsa görebilir. Görünürlüğü ayrı toggle ile kapatılabilir.

### 4.5 Hediye Event'i
- Doğum gününe X gün kala arkadaşlara "event başlatalım mı?" bildirimi (**otomatik öneri**)
  **veya** istenildiği an **manuel** başlatma.
- Event içinde: katılımcılar, hediye rezervasyonu ("bunu ben alıyorum"), pahalı hediyeye
  **ortak girme** + ortak grup chat, koordinasyon.
- **Sürpriz mantığı:** Sahibi, kendi event'indeki rezervasyonları/hediyeleri reveal
  gününe kadar göremez.
- Not: WhatsApp'ın rastgele kişilerle programatik grup açan public API'si **yoktur** →
  grup chat **uygulama içinde** olacak (ilk idea dokümanındaki WP grup fikri geçersiz).

### 4.6 Feed (Ephemeral)
Arkadaşların anlık paylaşımlarının aktığı akış. Post **24 saatte kaybolur** (Snap/BeReal
otantikliği, "kaçırdıysan kaçırdın" merakı). Ama paylaşılan eşya kullanıcının kalıcı
envanterinde kalır. → **Feed geçici, envanter kalıcı.**

---

## 5. Mahremiyet Modeli (Ürünün DNA'sı)

Instagram-vari **esnek, bölüm bazında** görünürlük. Her bölüm ayrı ayarlanır:

| Bölüm            | Örnek görünürlük seçenekleri     |
|------------------|----------------------------------|
| Profil (genel)   | Herkese açık / Sadece arkadaşlar |
| Envanter         | Açık / Arkadaşlar / Kapalı       |
| Hediye geçmişi   | Açık / Arkadaşlar / Kapalı       |
| Wishlist         | Açık / Arkadaşlar                |
| Özel notlar      | Sadece bana                      |

Örnek: bir kullanıcı profilini herkese açar, envanterini gösterir ama hediye geçmişini
kapatır. Bu granülerlik zorunlu — envanter paylaşımı hassas (hırsızlık/servet sinyali).

> Teknik not: Bu granüler mahremiyet, backend seçiminde belirleyici. Postgres tabanlı
> Row-Level Security (RLS) bu tür kurallar için doğal; NoSQL güvenlik kuralları
> bakımı zorlaştırır. (Araştırma sonucunu bekle.)

---

## 6. Cold-Start & Büyüme

Sosyal app'in en ölümcül riski: tek başına açınca boş network. Çözüm — hibrit:

1. **Rehber eşleştirme** (izinle): telefondaki kişilerden app'te olanları öner.
2. **Davet linki / QR:** app'te olmayanlara.
3. **Unique kullanıcı adıyla arama:** Instagram gibi, isteyen kullanıcı adından bulur.

Retention motoru: **doğum günü hatırlatma push'ları** (event otomatik önerisiyle bağlı).

---

## 7. Monetizasyon (Mimaride kanca, uygulama sonraya)

Karar: MVP'de gelir yok — **önce problem/retention doğrula**. Ama veri modelini şu üç
kaynağı *sonradan sancısız* ekleyecek şekilde kur (kancaları bırak):

- **Affiliate:** wishlist/envanter ürünlerine satın alma linki → komisyon (en doğal).
- **Reklam:** feed/keşfet slotları.
- **Premium abonelik:** sınırsız envanter, analytics, temalar vb.

"Başta çalışsın yeter, para modelini sonra entegre et" — doğru yaklaşım.

---

## 8. Teknik Stack (KİLİTLENDİ)

Maliyet-öncelikli derin araştırma sonucu (bkz. `backend_research.md`, 2026-08-28):

- **Mobil:** Flutter (iOS + Android). Kurucunun önceki app deneyimi (BiloFlu Pişti)
  bu yönde.
- **Backend:** **Supabase** (Postgres + Auth + Storage + RLS + Realtime).
  - Gerekçe: ilişkisel model (arkadaş grafiği + event durum makinesi) + granüler
    mahremiyetin Postgres RLS'e birebir oturması + **kaynak-bazlı (işlem-bazlı değil)**
    öngörülebilir maliyet + düşük lock-in (saf Postgres, `pg_dump` ile taşınır).
  - Maliyet: 0–1k kullanıcı **$0–25/ay**, ~10k **$35–90/ay**, ~100k **$300–600/ay**.
- **Push:** **FCM** (Android) + APNs (iOS) — her backend'de zorunlu. Supabase'de
  device token → DB trigger/`pg_cron` → Edge Function → FCM HTTP v1. Doğum günü
  hatırlatması = zamanlanmış `pg_cron` job + FCM batch.
- **Medya:** İstemcide sıkıştırma (WebP ~250KB). Ölçekte fotoğrafları **Cloudflare R2**'ye
  taşı (egress $0). Ephemeral fotoları `pg_cron` ile otomatik sil.
- **Mahremiyet:** Postgres **RLS** politikaları (default-deny) + uygulama katmanı
  kontrolüyle katmanla (RLS tek savunma olmasın).
- **Kaçış kapısı:** Maliyet baskısında aynı kodla self-host Supabase / kendi VPS'e
  (~€8–16/ay) inilebilir. Repository/abstraction katmanı kullan.

---

## 9. Version Yol Haritası (Revize)

### V1 — Çekirdek fayda + kimlik
- Auth + unique kullanıcı adı
- Profil (temel bilgiler + bölüm bazlı görünürlük iskeleti)
- Wishlist
- Hediye geçmişi (alan kişi girer)
- Rehber eşleştirme + davet + kullanıcı adıyla arama
- Doğum günü + hatırlatma push

### V2 — Sosyal döngü
- Anlık foto çekimi (Snap tarzı) + 24s ephemeral feed
- Envanter (kalıcı raf)
- Reaksiyonlar
- Granüler mahremiyet ayarlarının tamamı

### V3 — Hediye Event'i
- Event (otomatik öneri + manuel), rezervasyon, sürpriz/reveal mantığı
- Uygulama içi grup chat, pahalı hediyeye ortak girme

### V4 — Ölçek & gelir
- Affiliate / reklam / premium entegrasyonu
- Ürün kataloğu / arama
- (İleride) marka iş birlikleri, şirket hesapları

---

## 10. Açık Riskler & İzlenecekler

- **Cold-start:** İlk grup kurulmazsa app boş kalır → rehber eşleştirme ve davet
  döngüsü V1'de sağlam olmalı.
- **Envanter paylaşım motivasyonu:** İnsanlar eşyalarını neden göstersin? Wedge
  (hediye faydası) + mahremiyet kontrolü bunu çözmeli; erken kullanıcılarda test et.
- **Sürpriz vs. şeffaflık:** Reveal zamanlama mantığı doğru kurulmazsa ya sürpriz
  bozulur ya koordinasyon çalışmaz.
- **Maliyet:** Ephemeral fotolar storage'ı şişirebilir → auto-delete + sıkıştırma.
- **Takipçi ≠ Kullanıcı:** Önceki reklam deneyimi (5000+ erişim, düşük dönüşüm) →
  organik/viral döngüye yaslanmak, ödemeli büyümeye değil.
