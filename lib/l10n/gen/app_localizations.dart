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

  /// No description provided for @onboardingBirthdayWhy.
  ///
  /// In en, this message translates to:
  /// **'So friends never miss your day — we remind them before your birthday.'**
  String get onboardingBirthdayWhy;

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

  /// No description provided for @pushPrimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a gift day'**
  String get pushPrimingTitle;

  /// No description provided for @pushPrimingBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications and we\'ll remind you before friends\' birthdays.'**
  String get pushPrimingBody;

  /// No description provided for @pushPrimingEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get pushPrimingEnable;

  /// No description provided for @pushPrimingLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get pushPrimingLater;

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

  /// No description provided for @homeUsernameCountdown.
  ///
  /// In en, this message translates to:
  /// **'@{username} · {countdown}'**
  String homeUsernameCountdown(String username, String countdown);

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

  /// No description provided for @meSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get meSignOut;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This is permanent. Your profile, wishlist, friends and received gifts are deleted. Gifts you gave friends stay in their history, anonymized.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account — please try again.'**
  String get deleteAccountError;

  /// No description provided for @settingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegalSection;

  /// No description provided for @legalPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicy;

  /// No description provided for @legalTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get legalTermsOfUse;

  /// No description provided for @legalOpenError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the page.'**
  String get legalOpenError;

  /// No description provided for @errorSessionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Your session is no longer valid — please sign in again.'**
  String get errorSessionInvalid;

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

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @profileTabWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profileTabWishlist;

  /// No description provided for @profileTabHistory.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get profileTabHistory;

  /// No description provided for @profileTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileTabAbout;

  /// No description provided for @profileFriendCount.
  ///
  /// In en, this message translates to:
  /// **'{count} friends'**
  String profileFriendCount(int count);

  /// No description provided for @profileNotVisible.
  ///
  /// In en, this message translates to:
  /// **'This profile isn\'t visible'**
  String get profileNotVisible;

  /// No description provided for @profileAboutEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get profileAboutEmpty;

  /// No description provided for @profileAboutBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get profileAboutBirthday;

  /// No description provided for @profileAboutOccupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get profileAboutOccupation;

  /// No description provided for @friendAdd.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get friendAdd;

  /// No description provided for @friendStatusFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendStatusFriends;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteTitle;

  /// No description provided for @inviteYourCode.
  ///
  /// In en, this message translates to:
  /// **'Your invite code'**
  String get inviteYourCode;

  /// No description provided for @inviteShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get inviteShareButton;

  /// No description provided for @inviteShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join me on Kept! My invite code: {code}'**
  String inviteShareMessage(String code);

  /// No description provided for @inviteEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a code?'**
  String get inviteEnterTitle;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeLabel;

  /// No description provided for @inviteRedeemButton.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get inviteRedeemButton;

  /// No description provided for @inviteRedeemSuccess.
  ///
  /// In en, this message translates to:
  /// **'You\'re now friends with {name}'**
  String inviteRedeemSuccess(String name);

  /// No description provided for @inviteInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work — check it and try again'**
  String get inviteInvalidCode;

  /// No description provided for @inviteError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your invite code'**
  String get inviteError;

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

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacySection;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyEntry.
  ///
  /// In en, this message translates to:
  /// **'Who can see my profile'**
  String get privacyEntry;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose who can see each part of your profile. Changes apply immediately.'**
  String get privacyIntro;

  /// No description provided for @privacyProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get privacyProfile;

  /// No description provided for @privacyProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Your name, photo and about info'**
  String get privacyProfileDesc;

  /// No description provided for @privacyWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get privacyWishlist;

  /// No description provided for @privacyWishlistDesc.
  ///
  /// In en, this message translates to:
  /// **'Items you\'d love to receive'**
  String get privacyWishlistDesc;

  /// No description provided for @privacyGiftHistory.
  ///
  /// In en, this message translates to:
  /// **'Gift history'**
  String get privacyGiftHistory;

  /// No description provided for @privacyGiftHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Gifts you\'ve given and received'**
  String get privacyGiftHistoryDesc;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @visibilityFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get visibilityFriends;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get visibilityPrivate;

  /// No description provided for @privacyUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the setting — please try again.'**
  String get privacyUpdateError;

  /// No description provided for @privacyCapNote.
  ///
  /// In en, this message translates to:
  /// **'While your profile is visible to friends only, other sections can\'t be more open than that — set your profile to Public first.'**
  String get privacyCapNote;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get searchTooltip;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by username or name'**
  String get searchHint;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search'**
  String get searchPrompt;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one found — check the spelling or invite them!'**
  String get searchEmpty;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search failed — please try again.'**
  String get searchError;

  /// No description provided for @profilePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'This profile is private'**
  String get profilePrivateTitle;

  /// No description provided for @profilePrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Add them as a friend to see their profile, wishlist and gift history.'**
  String get profilePrivateBody;

  /// No description provided for @safetyMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get safetyMenuTooltip;

  /// No description provided for @blockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockAction;

  /// No description provided for @blockConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this user?'**
  String get blockConfirmTitle;

  /// No description provided for @blockConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see each other anywhere — profiles, search or requests — and any friendship is removed. They won\'t be notified. You can unblock them later in Settings.'**
  String get blockConfirmBody;

  /// No description provided for @blockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get blockSuccess;

  /// No description provided for @blockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get blockedUsersTitle;

  /// No description provided for @blockedUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get blockedUsersEmpty;

  /// No description provided for @blockedUsersUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get blockedUsersUnblock;

  /// No description provided for @reportAction.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportAction;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this user'**
  String get reportTitle;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;

  /// No description provided for @reportDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get reportDetailsLabel;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSubmit;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thanks — we\'ll review this report.'**
  String get reportSuccess;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSection;

  /// No description provided for @notifBirthdayReminders.
  ///
  /// In en, this message translates to:
  /// **'Birthday reminders'**
  String get notifBirthdayReminders;

  /// No description provided for @notifBirthdayRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified a few days before a friend\'s birthday'**
  String get notifBirthdayRemindersDesc;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileUsernameLocked.
  ///
  /// In en, this message translates to:
  /// **'Username can\'t be changed.'**
  String get editProfileUsernameLocked;

  /// No description provided for @editProfileBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBioLabel;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get editProfileSaved;
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
