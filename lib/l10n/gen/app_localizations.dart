import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get appTitle;

  /// No description provided for @signInTagline.
  ///
  /// In en, this message translates to:
  /// **'What you own, your taste, your things.'**
  String get signInTagline;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInDevMode.
  ///
  /// In en, this message translates to:
  /// **'Continue in dev mode (debug only)'**
  String get signInDevMode;

  /// No description provided for @errorSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get errorSignInFailed;

  /// No description provided for @onboardingUsernameTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get onboardingUsernameTitle;

  /// No description provided for @onboardingAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get onboardingAboutTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters'**
  String usernameTooShort(int min);

  /// No description provided for @usernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most {max} characters'**
  String usernameTooLong(int max);

  /// No description provided for @usernameInvalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers and underscore'**
  String get usernameInvalidCharacters;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That username is taken'**
  String get usernameTaken;

  /// No description provided for @usernameCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check availability — try again'**
  String get usernameCheckFailed;

  /// No description provided for @nameOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptionalLabel;

  /// No description provided for @birthdayRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthday (required)'**
  String get birthdayRequiredLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @finishLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishLabel;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get tabGifts;

  /// No description provided for @tabAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tabAdd;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @quickAddLogGift.
  ///
  /// In en, this message translates to:
  /// **'Log a gift'**
  String get quickAddLogGift;

  /// No description provided for @quickAddLogGiftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I bought a gift for a friend'**
  String get quickAddLogGiftSubtitle;

  /// No description provided for @quickAddWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get quickAddWishlist;

  /// No description provided for @quickAddWishlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something I want'**
  String get quickAddWishlistSubtitle;

  /// No description provided for @homeUpcomingSection.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get homeUpcomingSection;

  /// No description provided for @homeActivitySection.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get homeActivitySection;

  /// No description provided for @homeSampleBadge.
  ///
  /// In en, this message translates to:
  /// **'sample'**
  String get homeSampleBadge;

  /// No description provided for @homeNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming birthdays yet'**
  String get homeNoUpcoming;

  /// No description provided for @homeNoUpcomingHint.
  ///
  /// In en, this message translates to:
  /// **'Add friends so you never miss a gift day.'**
  String get homeNoUpcomingHint;

  /// No description provided for @homeFindFriends.
  ///
  /// In en, this message translates to:
  /// **'Find friends'**
  String get homeFindFriends;

  /// No description provided for @homeCountdownToday.
  ///
  /// In en, this message translates to:
  /// **'Today! 🎂'**
  String get homeCountdownToday;

  /// No description provided for @homeCountdownTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get homeCountdownTomorrow;

  /// No description provided for @homeCountdownInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String homeCountdownInDays(int days);

  /// No description provided for @homeGiftCta.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get homeGiftCta;

  /// No description provided for @homeUpcomingError.
  ///
  /// In en, this message translates to:
  /// **'Could not load upcoming birthdays'**
  String get homeUpcomingError;

  /// No description provided for @homeActivityError.
  ///
  /// In en, this message translates to:
  /// **'Could not load activity'**
  String get homeActivityError;

  /// No description provided for @homeActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing happening yet'**
  String get homeActivityEmpty;

  /// No description provided for @homeUsernameCountdown.
  ///
  /// In en, this message translates to:
  /// **'@{username} · {countdown}'**
  String homeUsernameCountdown(String username, String countdown);

  /// No description provided for @sampleActivityFriends.
  ///
  /// In en, this message translates to:
  /// **'Ali and Zeynep became friends'**
  String get sampleActivityFriends;

  /// No description provided for @sampleActivityGift.
  ///
  /// In en, this message translates to:
  /// **'Mert logged a gift for Can'**
  String get sampleActivityGift;

  /// No description provided for @sampleActivityBirthday.
  ///
  /// In en, this message translates to:
  /// **'Selin\'s birthday is coming up'**
  String get sampleActivityBirthday;

  /// No description provided for @giftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get giftsTitle;

  /// No description provided for @giftsGivenTab.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get giftsGivenTab;

  /// No description provided for @giftsReceivedTab.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get giftsReceivedTab;

  /// No description provided for @giftsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No gifts logged yet'**
  String get giftsEmpty;

  /// No description provided for @giftsLogFirst.
  ///
  /// In en, this message translates to:
  /// **'Log your first gift'**
  String get giftsLogFirst;

  /// No description provided for @giftsReceivedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No gifts received yet'**
  String get giftsReceivedEmpty;

  /// No description provided for @giftsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load gifts'**
  String get giftsError;

  /// No description provided for @giftAnonymousGiver.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get giftAnonymousGiver;

  /// No description provided for @giftSurpriseBadge.
  ///
  /// In en, this message translates to:
  /// **'Surprise'**
  String get giftSurpriseBadge;

  /// No description provided for @giftDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Gift removed'**
  String get giftDeletedSnack;

  /// No description provided for @logGiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a gift'**
  String get logGiftTitle;

  /// No description provided for @logGiftRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Who is it for?'**
  String get logGiftRecipientLabel;

  /// No description provided for @logGiftRecipientRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a recipient'**
  String get logGiftRecipientRequired;

  /// No description provided for @logGiftNoFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends first — gifts are logged for a friend.'**
  String get logGiftNoFriends;

  /// No description provided for @logGiftItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get logGiftItemLabel;

  /// No description provided for @logGiftItemRequired.
  ///
  /// In en, this message translates to:
  /// **'Gift is required'**
  String get logGiftItemRequired;

  /// No description provided for @logGiftDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get logGiftDateLabel;

  /// No description provided for @logGiftSurprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise'**
  String get logGiftSurprise;

  /// No description provided for @logGiftSurpriseHint.
  ///
  /// In en, this message translates to:
  /// **'Hidden from the recipient until the reveal date'**
  String get logGiftSurpriseHint;

  /// No description provided for @logGiftRevealDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Reveal date'**
  String get logGiftRevealDateLabel;

  /// No description provided for @logGiftRevealDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a reveal date'**
  String get logGiftRevealDateRequired;

  /// No description provided for @surpriseOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off surprise?'**
  String get surpriseOffTitle;

  /// No description provided for @surpriseOffBody.
  ///
  /// In en, this message translates to:
  /// **'Without surprise, the recipient can see this gift in their history immediately.'**
  String get surpriseOffBody;

  /// No description provided for @surpriseOffDontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this again'**
  String get surpriseOffDontShowAgain;

  /// No description provided for @surpriseOffConfirm.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get surpriseOffConfirm;

  /// No description provided for @logGiftSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Gift logged'**
  String get logGiftSavedSnack;

  /// No description provided for @friendGiftsTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · Gift history'**
  String friendGiftsTitle(String name);

  /// No description provided for @friendGiftsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No gift history yet'**
  String get friendGiftsEmpty;

  /// No description provided for @giftHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Gift history'**
  String get giftHistoryTooltip;

  /// No description provided for @wishlistAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get wishlistAddTitle;

  /// No description provided for @wishlistMineTitle.
  ///
  /// In en, this message translates to:
  /// **'My wishlist'**
  String get wishlistMineTitle;

  /// No description provided for @wishlistOfUser.
  ///
  /// In en, this message translates to:
  /// **'{name} · Wishlist'**
  String wishlistOfUser(String name);

  /// No description provided for @wishlistEmptyMine.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmptyMine;

  /// No description provided for @wishlistEmptyMineHint.
  ///
  /// In en, this message translates to:
  /// **'Add things you\'d love to receive — friends pick from here.'**
  String get wishlistEmptyMineHint;

  /// No description provided for @wishlistEmptyFriend.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get wishlistEmptyFriend;

  /// No description provided for @wishlistError.
  ///
  /// In en, this message translates to:
  /// **'Could not load wishlist'**
  String get wishlistError;

  /// No description provided for @wishlistItemTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get wishlistItemTitleLabel;

  /// No description provided for @wishlistItemUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Link (optional)'**
  String get wishlistItemUrlLabel;

  /// No description provided for @wishlistItemNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get wishlistItemNoteLabel;

  /// No description provided for @wishlistTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get wishlistTitleRequired;

  /// No description provided for @wishlistAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added to your wishlist'**
  String get wishlistAddedSnack;

  /// No description provided for @wishlistDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Removed from your wishlist'**
  String get wishlistDeletedSnack;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @meTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// No description provided for @meProfileFallback.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get meProfileFallback;

  /// No description provided for @meProfileError.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get meProfileError;

  /// No description provided for @meFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get meFriends;

  /// No description provided for @meSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettings;

  /// No description provided for @meSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming with G-85'**
  String get meSettingsComingSoon;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @friendsRequestsSection.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get friendsRequestsSection;

  /// No description provided for @friendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get friendsEmpty;

  /// No description provided for @friendsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Kept works with friends — invite yours to get started.'**
  String get friendsEmptyHint;

  /// No description provided for @friendsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load friends'**
  String get friendsError;

  /// No description provided for @friendAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendAccept;

  /// No description provided for @friendDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get friendDecline;

  /// No description provided for @friendCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get friendCancelRequest;

  /// No description provided for @friendRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get friendRemove;

  /// No description provided for @friendPendingOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get friendPendingOutgoing;

  /// No description provided for @friendRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove friend?'**
  String get friendRemoveConfirmTitle;

  /// No description provided for @friendRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer see your friends-only sections.'**
  String friendRemoveConfirmBody(String name);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTooltip;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get activityEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
