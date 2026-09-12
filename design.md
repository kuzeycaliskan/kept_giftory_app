# Kept Design Language v1

> Bağlayıcı sözleşme (CLAUDE.md §9'dan referanslı). Her ekran ve her yeni bileşen bu
> kurallara uyar. Ad-hoc renk/boyut/köşe yarıçapı YASAK — her şey `core/theme/`
> token'larından ve component theme'lerden gelir. Bir kural işine gelmiyorsa kuralı
> değiştir (bu dosya + tema birlikte), ekranda istisna açma.

## 1. Kimlik

Sade, içerik-önde, Instagram/Twitter ayarında bir görsel dil. Uygulama nötr; **renk =
anlam**. Süsleme yok, gradyan yok, gölge minimum.

- **Zemin nötrdür:** beyaz/siyaha-yakın yüzeyler, gri tonları. Material'ın lila tonal
  yıkaması kullanılmaz.
- **Mor (#6C4DF6) tek marka vurgusudur** ve cimridir: primary buton, aktif durum
  (sekme/nav), seçim, link. Büyük yüzeyler asla mora boyanmaz.
- **Kırmızı yalnız yıkıcıdır:** engelle, sil, kaldır. Başka hiçbir şey kırmızı olamaz.
- Karanlık mod birinci sınıftır: her iki temada da test etmeden ekran bitmiş sayılmaz.

## 2. Token'lar (`core/theme/kept_tokens.dart`)

| Token | Değer | Kullanım |
|---|---|---|
| `KeptSpacing` | 4·8·12·16·24·32 | Tüm padding/gap bu ölçekten. Ara değer yok. |
| `KeptRadius.control` | 12 | Input, küçük kontrol |
| `KeptRadius.card` | 16 | Kart, liste konteyneri |
| `KeptRadius.sheet` | 24 | Bottom sheet üst köşeleri |
| `KeptRadius.pill` | 999 | Buton ve chip'ler (hap biçimi) |

Renk rolleri `ColorScheme` üzerinden okunur (`colorScheme.primary`, `.error`,
`.onSurfaceVariant`...). Hex değer **sadece** `app_theme.dart` içinde yazılır.

## 3. Tipografi

Sistem fontu (SF / Roboto). Hiyerarşi boyut değil **ağırlıkla** kurulur:
başlıklar w700, vurgu w600, gövde w400. Ekranlar `textTheme` rollerinden okur;
ekranda `fontSize:` yazmak yasak (tema zaten ölçekliyor).

**Rol tablosu — tutarlılık buradan denetlenir:**

| Yüzey | Rol / boyut |
|---|---|
| App bar başlığı | 20 w700 (temada sabit) |
| Ekran içi isim / büyük başlık | `titleLarge` (22) |
| Bölüm başlığı | `titleMedium` w700 |
| Liste bölüm etiketi | `titleSmall` |
| Liste satır başlığı | ListTile varsayılanı (`bodyLarge`) |
| Gövde / açıklama | `bodyMedium` |
| Yardımcı / ikincil | `bodySmall` + `onSurfaceVariant` |
| Buton & sekme etiketi | 14 w600 (temada sabit) |

⚠️ **Component theme tuzağı:** `ThemeData()`'nın ham `textTheme`'i build öncesi
geometri içermez (boyutlar null). Component theme'lerde stil `base.textTheme`'den
TÜRETİLMEZ — açık `fontSize` yazılır. (App bar başlığının 14'e düşmesi bu tuzaktan
çıktı; regresyon testi `test/core/theme/app_theme_test.dart`.)

## 4. Bileşen kuralları

- **Bağlam menüsü = alttan action sheet** (`showKeptActionSheet`). `PopupMenuButton`
  kullanmak yasak. Satırlar ikonlu; yıkıcı satır kırmızı; iptal ayrı buton.
- **Bottom sheet:** üstte drag handle, `KeptRadius.sheet` köşe.
- **Butonlar:** hap biçimli. Hiyerarşi: `FilledButton` (birincil, ekranda en fazla 1) >
  `FilledButton.tonal` (ikincil) > `OutlinedButton`/`TextButton` (üçüncül). Yıkıcı
  onay butonu kırmızı `FilledButton`.
- **App bar düz:** yüzey renginde, gölgesiz, scroll'da renk değiştirmez.
- **Listeler:** kart yığını değil; düz satırlar + hairline ayraç. Kart yalnız
  "öne çıkan tekil içerik" için (Home doğum günü kartı gibi) ve düz (gölgesiz,
  ince çerçeveli).
- **Input'lar:** dolgulu (subtle gri), `KeptRadius.control`, çerçevesiz; odakta mor
  hairline.
- **Snackbar:** yüzen, `KeptRadius.control`.
- **Boş durumlar:** ikon + tek cümle + (varsa) tek CTA. Vaaz yok.
- **Avatar:** daire, baş harf fallback'i `primaryContainer` zemin + `primary` metin.

## 5. Taşma (overflow) — sıfır tolerans

**Hiçbir koşulda RenderFlex overflow (sarı-siyah şerit) veya kırpılmış metin
kabul edilmez.** Her ekran, uzun içerikle ve büyük yazı ölçeğiyle ayakta kalacak
şekilde tasarlanır:

- `Row` içindeki her `Text` ya `Expanded`/`Flexible` içindedir ya da sabit-genişlik
  garantilidir. Çıplak `Text` + `Row` kombinasyonu yazılmaz.
- Kullanıcı üretimi metin (isim, kullanıcı adı, başlık, not) tek satırlıksa
  `maxLines: 1 + TextOverflow.ellipsis`; çok satırlıksa `maxLines` sınırlı.
  App bar başlıkları her zaman tek satır + ellipsis.
- Sabit yükseklik verilen kutulara metin konmaz; içerik `ListView`/`SingleChildScrollView`
  ile kaydırılabilir olur (küçük ekran + klavye senaryosu dahil).
- Test/geliştirmede uzun isim ("Wolfeschlegelsteinhausenbergerdorff") ve
  `textScaleFactor 1.3+` ile en az bir kez bakılır.

## 6. Hareket

Varsayılan Material geçişleri; süre eklenmez, custom animasyon V1'de yok.
Yükleme: ortalanmış `CircularProgressIndicator` (tema rengi), skeleton V2.

## 7. Yapılmayacaklar

- `Colors.xxx` doğrudan kullanımı (`Colors.transparent` hariç) — rol tabanlı oku.
- Ekran içinde `TextStyle(fontSize: ...)`, ad-hoc `BorderRadius`, `elevation`.
- `PopupMenuButton`, varsayılan `showDatePicker` (KeptDatePicker var), emoji ikon.
- Bir bileşeni iki ekranda kopyalamak — üçüncü kullanım `shared/widgets/`'a taşınır.
