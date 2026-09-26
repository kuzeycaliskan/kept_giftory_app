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
  String get onboardingBirthdayWhy =>
      'Arkadaşların gününü kaçırmasın — doğum gününden önce onlara hatırlatırız.';

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
  String get homeUpcomingSection => 'Yaklaşanlar';

  @override
  String get homeActivitySection => 'Aktivite';

  @override
  String get homeActivityError => 'Aktivite yüklenemedi';

  @override
  String get homeActivityEmptyNudge =>
      'Şimdilik sessiz — arkadaş ekledikçe burası hareketlenir.';

  @override
  String homeEventFriend(String name) {
    return '$name ile arkadaş oldunuz';
  }

  @override
  String homeEventGift(String name) {
    return '$name sana bir hediye kaydetti';
  }

  @override
  String homeEventExternalGift(String relation) {
    return '$relation hediye';
  }

  @override
  String get homeInviteCta => 'Davet et';

  @override
  String get pushPrimingTitle => 'Hiçbir hediye gününü kaçırma';

  @override
  String get pushPrimingBody =>
      'Bildirimleri aç, arkadaşlarının doğum günlerinden önce hatırlatalım.';

  @override
  String get pushPrimingEnable => 'Aç';

  @override
  String get pushPrimingLater => 'Sonra';

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
  String get logGiftLinkLabel => 'Link (isteğe bağlı)';

  @override
  String get logExternalTitle => 'Aldığın hediyeyi ekle';

  @override
  String get logExternalFromLabel => 'Kimden';

  @override
  String get logExternalFromRequired => 'Kimden olduğunu seç';

  @override
  String get logExternalCta => 'Aldığın bir hediyeyi ekle';

  @override
  String giftFromRelation(String relation) {
    return '$relation';
  }

  @override
  String get relationMother => 'Annemden';

  @override
  String get relationFather => 'Babamdan';

  @override
  String get relationSibling => 'Kardeşimden';

  @override
  String get relationPartner => 'Sevgilimden/Eşimden';

  @override
  String get relationRelative => 'Akrabamdan';

  @override
  String get relationFriend => 'Arkadaşımdan (Kept\'te değil)';

  @override
  String get relationCoworker => 'İş arkadaşımdan';

  @override
  String get relationOther => 'Başka birinden';

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
  String get linkPreviewRemove => 'Önizlemeyi kaldır';

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
  String get meSignOut => 'Çıkış yap';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAccountSection => 'Hesap';

  @override
  String get settingsDeleteAccount => 'Hesabı sil';

  @override
  String get deleteAccountConfirmTitle => 'Hesabın silinsin mi?';

  @override
  String get deleteAccountConfirmBody =>
      'Bu işlem kalıcıdır. Profilin, wishlist\'in, arkadaşların ve aldığın hediyeler silinir. Arkadaşlarına verdiğin hediyeler onların geçmişinde anonim olarak kalır.';

  @override
  String get deleteAccountConfirm => 'Kalıcı olarak sil';

  @override
  String get deleteAccountError => 'Hesabın silinemedi — lütfen tekrar dene.';

  @override
  String get settingsLegalSection => 'Yasal';

  @override
  String get legalPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get legalTermsOfUse => 'Kullanım Şartları';

  @override
  String get legalOpenError => 'Sayfa açılamadı.';

  @override
  String get errorSessionInvalid =>
      'Oturumun artık geçerli değil — lütfen tekrar giriş yap.';

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
  String get commonDone => 'Tamam';

  @override
  String get profileTabWishlist => 'Wishlist';

  @override
  String get profileTabHistory => 'Hediyeler';

  @override
  String get profileTabAbout => 'Hakkında';

  @override
  String profileFriendCount(int count) {
    return '$count arkadaş';
  }

  @override
  String get profileNotVisible => 'Bu profil görünür değil';

  @override
  String get profileAboutEmpty => 'Henüz bir şey yok';

  @override
  String get profileAboutBirthday => 'Doğum günü';

  @override
  String get profileAboutOccupation => 'Meslek';

  @override
  String get friendAdd => 'Arkadaş ekle';

  @override
  String get friendStatusFriends => 'Arkadaşsınız';

  @override
  String get inviteTitle => 'Arkadaşlarını davet et';

  @override
  String get inviteYourCode => 'Davet kodun';

  @override
  String get inviteShareButton => 'Kodu paylaş';

  @override
  String inviteShareMessage(String code) {
    return 'Kept\'e katıl! Davet kodum: $code';
  }

  @override
  String get inviteEnterTitle => 'Kodun mu var?';

  @override
  String get inviteCodeLabel => 'Davet kodu';

  @override
  String get inviteRedeemButton => 'Arkadaş ekle';

  @override
  String inviteRedeemSuccess(String name) {
    return '$name ile artık arkadaşsınız';
  }

  @override
  String get inviteInvalidCode => 'Kod işe yaramadı — kontrol edip tekrar dene';

  @override
  String get inviteError => 'Davet kodun yüklenemedi';

  @override
  String get activityTitle => 'Aktivite';

  @override
  String get activityTooltip => 'Aktivite';

  @override
  String get activityEmpty => 'Henüz bir şey yok';

  @override
  String get settingsPrivacySection => 'Mahremiyet';

  @override
  String get privacyTitle => 'Mahremiyet';

  @override
  String get privacyEntry => 'Profilimi kimler görebilir';

  @override
  String get privacyIntro =>
      'Profilinin her bölümünü kimlerin görebileceğini seç. Değişiklikler anında uygulanır.';

  @override
  String get privacyProfile => 'Profil';

  @override
  String get privacyProfileDesc => 'Adın, fotoğrafın ve hakkında bilgilerin';

  @override
  String get privacyWishlist => 'Wishlist';

  @override
  String get privacyWishlistDesc => 'Almak istediğin şeyler';

  @override
  String get privacyGiftHistory => 'Hediye geçmişi';

  @override
  String get privacyGiftHistoryDesc => 'Verdiğin ve aldığın hediyeler';

  @override
  String get visibilityPublic => 'Herkese açık';

  @override
  String get visibilityFriends => 'Arkadaşlar';

  @override
  String get visibilityPrivate => 'Kapalı';

  @override
  String get privacyUpdateError => 'Ayar kaydedilemedi — lütfen tekrar dene.';

  @override
  String get privacyCapNote =>
      'Profilin yalnızca arkadaşlarına görünürken diğer bölümler bundan daha açık olamaz — önce profilini Herkese açık yap.';

  @override
  String get searchTooltip => 'Kişi ara';

  @override
  String get searchHint => 'Kullanıcı adı veya isimle ara';

  @override
  String get searchClear => 'Aramayı temizle';

  @override
  String get searchPrompt => 'Aramak için en az 2 karakter yaz';

  @override
  String get searchEmpty =>
      'Kimse bulunamadı — yazımı kontrol et ya da davet et!';

  @override
  String get searchError => 'Arama başarısız — lütfen tekrar dene.';

  @override
  String get profilePrivateTitle => 'Bu profil gizli';

  @override
  String get profilePrivateBody =>
      'Profilini, wishlist\'ini ve hediye geçmişini görmek için arkadaş olarak ekle.';

  @override
  String get safetyMenuTooltip => 'Diğer seçenekler';

  @override
  String get blockAction => 'Engelle';

  @override
  String get blockConfirmTitle => 'Bu kullanıcı engellensin mi?';

  @override
  String get blockConfirmBody =>
      'Birbirinizi hiçbir yerde görmezsiniz — profil, arama veya istekler — ve mevcut arkadaşlık kaldırılır. Kendisine bildirim gitmez. Daha sonra Ayarlar\'dan engeli kaldırabilirsin.';

  @override
  String get blockSuccess => 'Kullanıcı engellendi.';

  @override
  String get blockedUsersTitle => 'Engellenen kullanıcılar';

  @override
  String get blockedUsersEmpty => 'Kimseyi engellemedin.';

  @override
  String get blockedUsersUnblock => 'Engeli kaldır';

  @override
  String get reportAction => 'Şikayet et';

  @override
  String get reportTitle => 'Bu kullanıcıyı şikayet et';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Taciz veya zorbalık';

  @override
  String get reportReasonInappropriate => 'Uygunsuz içerik';

  @override
  String get reportReasonOther => 'Başka bir şey';

  @override
  String get reportDetailsLabel => 'Ayrıntılar (isteğe bağlı)';

  @override
  String get reportSubmit => 'Şikayeti gönder';

  @override
  String get reportSuccess => 'Teşekkürler — bu şikayeti inceleyeceğiz.';

  @override
  String get settingsNotificationsSection => 'Bildirimler';

  @override
  String get notifBirthdayReminders => 'Doğum günü hatırlatmaları';

  @override
  String get notifBirthdayRemindersDesc =>
      'Bir arkadaşının doğum gününden birkaç gün önce bildirim al';

  @override
  String get editProfileTitle => 'Profili düzenle';

  @override
  String get editProfileUsernameLocked => 'Kullanıcı adı değiştirilemez.';

  @override
  String get editProfileBioLabel => 'Hakkında';

  @override
  String get editProfileSaved => 'Profil güncellendi.';

  @override
  String get avatarFromGallery => 'Galeriden seç';

  @override
  String get avatarFromCamera => 'Fotoğraf çek';

  @override
  String get avatarUpdated => 'Profil fotoğrafı güncellendi.';

  @override
  String get avatarCropTitle => 'Fotoğrafı ayarla';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get storiesYou => 'Sen';

  @override
  String get storiesAddHint => 'Bir an paylaş';

  @override
  String get storiesEmptyHint =>
      'Arkadaşlarının anları 24 saat boyunca burada görünür.';

  @override
  String get storiesError => 'Anlar yüklenemedi';

  @override
  String get composeTitle => 'Yeni an';

  @override
  String get composeCaptionHint => 'Bir şeyler yaz (isteğe bağlı)';

  @override
  String get composeShare => 'Paylaş';

  @override
  String get composeShared => 'Paylaşıldı. 24 saat sonra kaybolur.';

  @override
  String get composeFailed => 'Paylaşılamadı. Tekrar dene.';

  @override
  String get cameraUnavailable => 'Kamera açılamadı';

  @override
  String get storyMoreActions => 'Daha fazla';

  @override
  String get storyDelete => 'Anı sil';

  @override
  String get storyDeleteConfirmTitle => 'Bu an silinsin mi?';

  @override
  String get storyDeleteConfirmBody => 'Herkes için hemen kaybolur.';

  @override
  String get storyDeleted => 'An silindi';

  @override
  String get storyDeleteFailed => 'Silinemedi. Tekrar dene.';

  @override
  String get storyJustNow => 'Az önce';

  @override
  String storyMinutesAgo(int minutes) {
    return '$minutes dk';
  }

  @override
  String storyHoursAgo(int hours) {
    return '$hours sa';
  }

  @override
  String get storyImageError => 'Fotoğraf yüklenemedi';

  @override
  String homeUsernameCountdown(String username, String countdown) {
    return '@$username · $countdown';
  }

  @override
  String get giftDetailTitle => 'Hediye';

  @override
  String get giftDetailMissing => 'Bu hediye artık görüntülenemiyor';

  @override
  String get giftDetailNoPhotos => 'Henüz fotoğraf yok';

  @override
  String get giftPhotoAdd => 'Fotoğraf çek';

  @override
  String get giftPhotoCapHint => 'En fazla 3 fotoğraf';

  @override
  String get giftPhotoRemove => 'Fotoğrafı kaldır';

  @override
  String get giftPhotoRemoved => 'Fotoğraf kaldırıldı';

  @override
  String get giftPhotoRemoveFailed => 'Fotoğraf kaldırılamadı';

  @override
  String get giftPhotoAddFailed => 'Fotoğraf eklenemedi';

  @override
  String get giftPhotoAttachPartial =>
      'Kaydedildi ama bazı fotoğraflar eklenemedi.';

  @override
  String get giftDetailPhotosSection => 'Anılar';

  @override
  String get giftDetailNoteSection => 'Not';

  @override
  String get giftDetailLinkSection => 'Ürün linki';

  @override
  String get reactionHeart => 'Kalp';

  @override
  String get reactionCongrats => 'Tebrikler';

  @override
  String get reactionLike => 'Beğendim';

  @override
  String get reactionOk => 'Güzel';

  @override
  String get reactionWow => 'Vay';

  @override
  String get reactionsTitle => 'Tepkiler';

  @override
  String get reactionsEmpty => 'Henüz tepki yok';

  @override
  String get reactionFailed => 'Tepki verilemedi. Tekrar dene.';

  @override
  String homeEventFriendGift(String name, String giver) {
    return '$name, $giver tarafından bir hediye aldı';
  }

  @override
  String get homeSurpriseTeaserTitle => 'Sana sürpriz hazırlanıyor';

  @override
  String homeSurpriseTeaserOpens(String date) {
    return '$date günü açılıyor';
  }

  @override
  String get giftDetailReactionsSection => 'Tepkiler';

  @override
  String get reactionsWhoReacted => 'Kim tepki verdi';

  @override
  String get homeWishlistSeeAll => 'Tüm listeyi gör';

  @override
  String get homeWishlistEmptyInline => 'Henüz istek yok';

  @override
  String get homeWishlistToggle => 'İstek listesi';

  @override
  String get commentsTitle => 'Yorumlar';

  @override
  String get commentsWritePlaceholder => 'Yorum yaz…';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yorum',
      one: '1 yorum',
    );
    return '$_temp0';
  }

  @override
  String get commentsEmpty => 'Henüz yorum yok. Bir şeyler yaz.';

  @override
  String get commentsLoadError => 'Yorumlar yüklenemedi';

  @override
  String get commentsSend => 'Gönder';

  @override
  String get commentsSendFailed => 'Gönderilemedi. Tekrar dene.';

  @override
  String get commentsDelete => 'Yorumu sil';

  @override
  String get commentsDeleteFailed => 'Yorum silinemedi';

  @override
  String commentsDaysAgo(int days) {
    return '$days g';
  }

  @override
  String get notifSocial => 'Yorumlar ve sürprizler';

  @override
  String get notifSocialDesc =>
      'Hediyene ya da anına yorum gelince ve bir sürpriz açılınca';

  @override
  String homeEventFriendGiftExternal(String name) {
    return '$name bir hediye aldı';
  }

  @override
  String get homeLoggedToday => 'Bugün';

  @override
  String get homeLoggedYesterday => 'Dün';

  @override
  String homeLoggedDaysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String giftDetailGiftDate(String date) {
    return 'Hediye tarihi: $date';
  }

  @override
  String get imageEditRotate => 'Döndür';

  @override
  String get imageEditMirror => 'Aynala';

  @override
  String get giftsEventsTab => 'Event\'ler';

  @override
  String get eventsError => 'Event\'ler yüklenemedi';

  @override
  String get eventsEmpty => 'Henüz hediye event\'i yok';

  @override
  String get eventsEmptyHint =>
      'Doğum gününden önce arkadaşlarla birleş; doğum günü sahibi hiç görmez.';

  @override
  String get eventsCreateCta => 'Hediye event\'i aç';

  @override
  String get eventsOpenCta => 'Event aç';

  @override
  String get eventsGoCta => 'Event';

  @override
  String get eventsInvitesSection => 'Davetler';

  @override
  String get eventsMineSection => 'Event\'lerin';

  @override
  String eventsRowTitle(String name) {
    return '$name doğum günü';
  }

  @override
  String eventsRowSubtitle(String date, int count) {
    return '$date · $count kişi';
  }

  @override
  String eventsInviteTitle(String name) {
    return '$name için hediye event\'ine katılır mısın?';
  }

  @override
  String get eventsOrganizerBadge => 'Organizatör';

  @override
  String get eventsJoin => 'Katıl';

  @override
  String get eventsDecline => 'Reddet';

  @override
  String get eventsPickFriendTitle => 'Kimin doğum günü?';

  @override
  String get eventsPickFriendEmpty =>
      'Doğum günü tanımlı arkadaşın yok. Profillerine eklemelerini iste.';

  @override
  String get eventsCreateFailed => 'Event açılamadı';

  @override
  String get eventsDetailTitle => 'Hediye event\'i';

  @override
  String get eventsMissing => 'Bu event artık görüntülenemiyor';

  @override
  String eventsSecretNote(String name) {
    return '$name bu event\'i ve kimlerin olduğunu göremez.';
  }

  @override
  String get eventsOpenChat => 'Grup sohbetini aç';

  @override
  String get eventsSetChatLink => 'Grup sohbeti linki';

  @override
  String get eventsChatLinkHint => 'https://chat.whatsapp.com/…';

  @override
  String eventsMembersSection(int count) {
    return '$count üye';
  }

  @override
  String get eventsMemberInvited => 'Davet edildi';

  @override
  String get eventsInviteMore => 'Arkadaş davet et';

  @override
  String get eventsInvite => 'Davet et';

  @override
  String get eventsInviteNobody => 'Katılabilecek herkes zaten burada.';

  @override
  String get eventsLeave => 'Event\'ten ayrıl';

  @override
  String get eventsLeaveConfirmTitle => 'Bu event\'ten ayrılmak istiyor musun?';

  @override
  String get eventsLeaveConfirmBody => 'Sonra yeniden davet edilebilirsin.';

  @override
  String get eventsCancel => 'Event\'i iptal et';

  @override
  String get eventsCancelConfirmTitle => 'Bu event iptal edilsin mi?';

  @override
  String get eventsCancelConfirmBody =>
      'Herkes erişimini kaybeder. Geri alınamaz.';

  @override
  String get eventsBoardSection => 'Konuşma';

  @override
  String get claimsIdeasSection => 'Hediye fikirleri';

  @override
  String get claimsIdeasEmpty => 'İstek listesi şimdilik boş';

  @override
  String get claimsIdeasSeeAll => 'İstek listesini aç';

  @override
  String get claimsError => 'Rezervasyonlar yüklenemedi';

  @override
  String get claimSolo => 'Ben alıyorum';

  @override
  String get claimShared => 'Ortak alalım';

  @override
  String get claimMine => 'Bunu sen alıyorsun';

  @override
  String claimByOther(String name) {
    return '$name alıyor';
  }

  @override
  String get claimByFriend => 'Bir arkadaşın alıyor';

  @override
  String get claimRelease => 'Bırak';

  @override
  String claimSharedSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi',
      one: '1 kişi',
    );
    return 'Ortak hediye · $_temp0 · $total';
  }

  @override
  String claimSharedTarget(String total, String target) {
    return '$total / $target';
  }

  @override
  String get claimJoin => 'Katıl';

  @override
  String claimMyPledge(String amount) {
    return 'Katkın: $amount';
  }

  @override
  String get claimPledgeTitle => 'Katkın';

  @override
  String get claimPledgeHint => 'Tutar';

  @override
  String get claimPledgeInvalid => 'Sıfırdan büyük bir tutar gir';

  @override
  String get claimTargetHint => 'Ürün fiyatı (hedef)';

  @override
  String get claimSharedTitle => 'Ortak hediye başlat';

  @override
  String get claimSharedBody =>
      'Arkadaşlar ne kadar koyacağını yazar. Para Kept dışında el değiştirir. Ürün fiyatını girersen herkes ne kadar kaldığını görür.';

  @override
  String get claimMakeShared => 'Ortak hediyeye çevir';

  @override
  String get claimWithdraw => 'Katkımı geri çek';

  @override
  String get claimCancelShared => 'Ortak hediyeyi iptal et';

  @override
  String get claimParticipants => 'Katılanlar';

  @override
  String get claimRemovePledge => 'Çıkar';

  @override
  String get claimNoPledges => 'Henüz kimse katılmadı';

  @override
  String get claimTaken => 'Bunu başkası ayırmış';

  @override
  String get claimFailed => 'Kaydedilemedi. Tekrar dene.';

  @override
  String get claimOrganizer => 'Organizatör';

  @override
  String get linkPreviewUnavailable =>
      'Önizleme alınamadı; adı kendin yazabilirsin';

  @override
  String get claimMyShareOptional => 'Senin payın (isteğe bağlı)';

  @override
  String claimRemaining(String amount) {
    return 'Kalan $amount';
  }

  @override
  String get claimFunded => 'Tamamlandı';

  @override
  String claimProgressPercent(int percent) {
    return '%$percent';
  }

  @override
  String claimJoinHint(String remaining, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi',
      one: '1 kişi',
    );
    return 'Kalan $remaining · $_temp0';
  }

  @override
  String claimOverTarget(String amount) {
    return 'Fiyatın $amount üzerinde';
  }

  @override
  String claimOverTargetHint(String amount) {
    return 'Bu tutarla havuz fiyatı $amount aşar; gerçek fiyat yüksekse sorun değil.';
  }

  @override
  String get claimPoolFull => 'Havuz doldu';

  @override
  String get eventsForYouSection => 'Senin için';

  @override
  String get eventsHonoreeTitle => 'Arkadaşların senin için bir araya geldi';

  @override
  String get eventsHonoreeRowTitle => 'Doğum günün';

  @override
  String eventsRevealedOn(String date) {
    return '$date tarihinde açıklandı';
  }

  @override
  String get eventsRevealNow => 'Şimdi açıkla';

  @override
  String get eventsRevealConfirmTitle => 'Event şimdi açıklansın mı?';

  @override
  String eventsRevealConfirmBody(String name) {
    return '$name kimlerin olduğunu ve burada kaydedilen hediyeleri görür. Hediye teslim edildiyse yap.';
  }

  @override
  String get eventsGiftsSection => 'Hediyeler';

  @override
  String get eventsGiftsEmpty => 'Henüz burada kaydedilmiş hediye yok';

  @override
  String get eventsLogGift => 'Listede olmayan bir hediye kaydet';

  @override
  String get eventsThanksTitle => 'Teşekkür et';

  @override
  String get eventsThanksHint => 'Katılan herkese birkaç söz…';

  @override
  String get eventsThanksSend => 'Gönder';

  @override
  String get eventsThanksSent => 'Teşekkürün herkese ulaştı';

  @override
  String eventsThanksFrom(String name) {
    return '$name teşekkür etti';
  }

  @override
  String get homeRevealCardTitle => 'Arkadaşların senin için bir araya geldi';

  @override
  String get homeRevealCardBody => 'Kimler vardı gör, teşekkür et';

  @override
  String get eventsThanksEdit => 'Düzenle';

  @override
  String get claimSoloConfirmTitle => 'Bunu sen mi alıyorsun?';

  @override
  String get claimSoloConfirmBody =>
      'Senin adına ayrılır ve hediye kaydı ön dolu açılır. Sonra bırakabilirsin.';

  @override
  String get claimSoloConfirm => 'Evet, ben alıyorum';

  @override
  String get claimLogGift => 'Hediyeyi kaydet';

  @override
  String get claimOpenGift => 'Hediyeye git';

  @override
  String get claimMineLogged => 'Bunu sen alıyorsun · hediye kaydedildi';

  @override
  String get claimSharedLogged => 'Ortak hediye · hediye kaydedildi';

  @override
  String get claimReleaseGiftTitle => 'Bırakıp hediye kaydını silelim mi?';

  @override
  String get claimReleaseGiftBody =>
      'Hediye henüz açıklanmadı; kaydı rezervasyonla birlikte silinir.';

  @override
  String get claimReleaseRefused => 'Hediye verilmiş; artık bırakılamaz.';

  @override
  String get logGiftEventSurpriseNote =>
      'Event hediyesi: sürprizdir, event açıklanınca görünür';

  @override
  String giftGiverWithFriends(String name, int count) {
    return '$name ve $count arkadaşı';
  }

  @override
  String get giftContributorsSection => 'Ortak verenler';

  @override
  String get giftContributorFriend => 'Bir arkadaş';

  @override
  String get logGiftEventRevealRule => 'doğum günü + 1 gün';
}
