// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kept';

  @override
  String get signInTagline => 'Sahip oldukların, zevkin, eşyaların.';

  @override
  String get signInWithApple => 'Apple ile devam et';

  @override
  String get signInWithGoogle => 'Google ile devam et';

  @override
  String get signInDevMode => 'Dev modunda devam et (sadece debug)';

  @override
  String get errorSignInFailed => 'Giriş başarısız. Lütfen tekrar dene.';

  @override
  String get onboardingUsernameTitle => 'Kullanıcı adı seç';

  @override
  String get onboardingAboutTitle => 'Senin hakkında';

  @override
  String get usernameLabel => 'Kullanıcı adı';

  @override
  String usernameTooShort(int min) {
    return 'En az $min karakter';
  }

  @override
  String usernameTooLong(int max) {
    return 'En fazla $max karakter';
  }

  @override
  String get usernameInvalidCharacters => 'Sadece harf, rakam ve alt çizgi';

  @override
  String get usernameTaken => 'Bu kullanıcı adı alınmış';

  @override
  String get usernameCheckFailed => 'Uygunluk kontrol edilemedi — tekrar dene';

  @override
  String get nameOptionalLabel => 'İsim (isteğe bağlı)';

  @override
  String get birthdayRequiredLabel => 'Doğum günü (zorunlu)';

  @override
  String get continueLabel => 'Devam';

  @override
  String get finishLabel => 'Bitir';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get tabHome => 'Ana Sayfa';

  @override
  String get tabGifts => 'Hediyeler';

  @override
  String get tabAdd => 'Ekle';

  @override
  String get tabMe => 'Ben';

  @override
  String get quickAddLogGift => 'Hediye kaydet';

  @override
  String get quickAddLogGiftSubtitle => 'Bir arkadaşıma hediye aldım';

  @override
  String get quickAddWishlist => 'Wishlist\'e ekle';

  @override
  String get quickAddWishlistSubtitle => 'İstediğim bir şey';

  @override
  String get homeUpcomingSection => 'Yaklaşanlar';

  @override
  String get homeActivitySection => 'Aktivite';

  @override
  String get homeSampleBadge => 'örnek';

  @override
  String get homeNoUpcoming => 'Yaklaşan doğum günü yok';

  @override
  String get homeNoUpcomingHint =>
      'Arkadaş ekle, hiçbir hediye gününü kaçırma.';

  @override
  String get homeFindFriends => 'Arkadaş bul';

  @override
  String get homeCountdownToday => 'Bugün! 🎂';

  @override
  String get homeCountdownTomorrow => 'Yarın';

  @override
  String homeCountdownInDays(int days) {
    return '$days gün sonra';
  }

  @override
  String get homeGiftCta => 'Hediye';

  @override
  String get homeUpcomingError => 'Yaklaşan doğum günleri yüklenemedi';

  @override
  String get homeActivityError => 'Aktivite yüklenemedi';

  @override
  String get homeActivityEmpty => 'Henüz bir hareket yok';

  @override
  String homeUsernameCountdown(String username, String countdown) {
    return '@$username · $countdown';
  }

  @override
  String get sampleActivityFriends => 'Ali ile Zeynep arkadaş oldu';

  @override
  String get sampleActivityGift => 'Mert, Can\'a hediye kaydetti';

  @override
  String get sampleActivityBirthday => 'Selin\'in doğum günü yaklaşıyor';

  @override
  String get giftsTitle => 'Hediyeler';

  @override
  String get giftsGivenTab => 'Verdiklerim';

  @override
  String get giftsReceivedTab => 'Aldıklarım';

  @override
  String get giftsEmpty => 'Henüz hediye kaydı yok';

  @override
  String get giftsLogFirst => 'İlk hediyeni kaydet';

  @override
  String get giftsReceivedEmpty => 'Henüz kayıtlı hediye yok';

  @override
  String get giftsError => 'Hediyeler yüklenemedi';

  @override
  String get giftAnonymousGiver => 'Birisi';

  @override
  String get giftSurpriseBadge => 'Sürpriz';

  @override
  String get giftDeletedSnack => 'Hediye kaydı silindi';

  @override
  String get logGiftTitle => 'Hediye kaydet';

  @override
  String get logGiftRecipientLabel => 'Kime?';

  @override
  String get logGiftRecipientRequired => 'Alıcı seç';

  @override
  String get logGiftNoFriends =>
      'Önce arkadaş ekle — hediye bir arkadaş için kaydedilir.';

  @override
  String get logGiftItemLabel => 'Hediye';

  @override
  String get logGiftItemRequired => 'Hediye zorunlu';

  @override
  String get logGiftDateLabel => 'Tarih';

  @override
  String get logGiftSurprise => 'Sürpriz';

  @override
  String get logGiftSurpriseHint => 'Açığa çıkma tarihine kadar alıcıdan gizli';

  @override
  String get logGiftRevealDateLabel => 'Açığa çıkma tarihi';

  @override
  String get logGiftRevealDateRequired => 'Açığa çıkma tarihi seç';

  @override
  String get surpriseOffTitle => 'Sürpriz kapatılsın mı?';

  @override
  String get surpriseOffBody =>
      'Sürpriz kapalıyken alıcı bu hediyeyi geçmişinde hemen görebilir.';

  @override
  String get surpriseOffDontShowAgain => 'Bir daha gösterme';

  @override
  String get surpriseOffConfirm => 'Kapat';

  @override
  String get logGiftSavedSnack => 'Hediye kaydedildi';

  @override
  String friendGiftsTitle(String name) {
    return '$name · Hediye geçmişi';
  }

  @override
  String get friendGiftsEmpty => 'Henüz hediye geçmişi yok';

  @override
  String get giftHistoryTooltip => 'Hediye geçmişi';

  @override
  String get wishlistAddTitle => 'Wishlist\'e ekle';

  @override
  String get wishlistMineTitle => 'Wishlist\'im';

  @override
  String wishlistOfUser(String name) {
    return '$name · Wishlist';
  }

  @override
  String get wishlistEmptyMine => 'Wishlist\'in boş';

  @override
  String get wishlistEmptyMineHint =>
      'İstediğin şeyleri ekle — arkadaşların buradan seçer.';

  @override
  String get wishlistEmptyFriend => 'Henüz bir şey yok';

  @override
  String get wishlistError => 'Wishlist yüklenemedi';

  @override
  String get wishlistItemTitleLabel => 'Başlık';

  @override
  String get wishlistItemUrlLabel => 'Link (isteğe bağlı)';

  @override
  String get wishlistItemNoteLabel => 'Not (isteğe bağlı)';

  @override
  String get wishlistTitleRequired => 'Başlık zorunlu';

  @override
  String get wishlistAddedSnack => 'Wishlist\'ine eklendi';

  @override
  String get wishlistDeletedSnack => 'Wishlist\'inden çıkarıldı';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get meTitle => 'Ben';

  @override
  String get meProfileFallback => 'Profil';

  @override
  String get meProfileError => 'Profil yüklenemedi';

  @override
  String get meFriends => 'Arkadaşlar';

  @override
  String get meSettings => 'Ayarlar';

  @override
  String get meSettingsComingSoon => 'G-85 ile geliyor';

  @override
  String get friendsTitle => 'Arkadaşlar';

  @override
  String get friendsRequestsSection => 'İstekler';

  @override
  String get friendsEmpty => 'Henüz arkadaşın yok';

  @override
  String get friendsEmptyHint =>
      'Kept arkadaşlarla çalışır — başlamak için davet et.';

  @override
  String get friendsError => 'Arkadaşlar yüklenemedi';

  @override
  String get friendAccept => 'Kabul et';

  @override
  String get friendDecline => 'Reddet';

  @override
  String get friendCancelRequest => 'İsteği iptal et';

  @override
  String get friendRemove => 'Çıkar';

  @override
  String get friendPendingOutgoing => 'İstek gönderildi';

  @override
  String get friendRemoveConfirmTitle => 'Arkadaşlıktan çıkarılsın mı?';

  @override
  String friendRemoveConfirmBody(String name) {
    return '$name artık sadece-arkadaşlar bölümlerini göremeyecek.';
  }

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get activityTitle => 'Aktivite';

  @override
  String get activityTooltip => 'Aktivite';

  @override
  String get activityEmpty => 'Henüz bir şey yok';
}
