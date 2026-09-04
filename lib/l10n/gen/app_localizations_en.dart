// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kept';

  @override
  String get signInTagline => 'What you own, your taste, your things.';

  @override
  String get signInWithApple => 'Continue with Apple';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInDevMode => 'Continue in dev mode (debug only)';

  @override
  String get errorSignInFailed => 'Sign-in failed. Please try again.';

  @override
  String get onboardingUsernameTitle => 'Choose a username';

  @override
  String get onboardingAboutTitle => 'About you';

  @override
  String get usernameLabel => 'Username';

  @override
  String usernameTooShort(int min) {
    return 'At least $min characters';
  }

  @override
  String usernameTooLong(int max) {
    return 'At most $max characters';
  }

  @override
  String get usernameInvalidCharacters =>
      'Only letters, numbers and underscore';

  @override
  String get usernameTaken => 'That username is taken';

  @override
  String get usernameCheckFailed => 'Could not check availability — try again';

  @override
  String get nameOptionalLabel => 'Name (optional)';

  @override
  String get birthdayRequiredLabel => 'Birthday (required)';

  @override
  String get continueLabel => 'Continue';

  @override
  String get finishLabel => 'Finish';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabGifts => 'Gifts';

  @override
  String get tabAdd => 'Add';

  @override
  String get tabMe => 'Me';

  @override
  String get quickAddLogGift => 'Log a gift';

  @override
  String get quickAddLogGiftSubtitle => 'I bought a gift for a friend';

  @override
  String get quickAddWishlist => 'Add to wishlist';

  @override
  String get quickAddWishlistSubtitle => 'Something I want';

  @override
  String get homeUpcomingSection => 'Upcoming';

  @override
  String get homeActivitySection => 'Activity';

  @override
  String get homeSampleBadge => 'sample';

  @override
  String get homeNoUpcoming => 'No upcoming birthdays yet';

  @override
  String get homeNoUpcomingHint => 'Add friends so you never miss a gift day.';

  @override
  String get homeFindFriends => 'Find friends';

  @override
  String get homeCountdownToday => 'Today! 🎂';

  @override
  String get homeCountdownTomorrow => 'Tomorrow';

  @override
  String homeCountdownInDays(int days) {
    return 'In $days days';
  }

  @override
  String get homeGiftCta => 'Gift';

  @override
  String get homeUpcomingError => 'Could not load upcoming birthdays';

  @override
  String get homeActivityError => 'Could not load activity';

  @override
  String get homeActivityEmpty => 'Nothing happening yet';

  @override
  String homeUsernameCountdown(String username, String countdown) {
    return '@$username · $countdown';
  }

  @override
  String get sampleActivityFriends => 'Ali and Zeynep became friends';

  @override
  String get sampleActivityGift => 'Mert logged a gift for Can';

  @override
  String get sampleActivityBirthday => 'Selin\'s birthday is coming up';

  @override
  String get giftsTitle => 'Gifts';

  @override
  String get giftsEmpty => 'No gifts logged yet';

  @override
  String get giftsLogFirst => 'Log your first gift';

  @override
  String get logGiftTitle => 'Log a gift';

  @override
  String get logGiftComingSoon => 'Gift logging arrives with G-51';

  @override
  String get wishlistAddTitle => 'Add to wishlist';

  @override
  String get wishlistMineTitle => 'My wishlist';

  @override
  String wishlistOfUser(String name) {
    return '$name · Wishlist';
  }

  @override
  String get wishlistEmptyMine => 'Your wishlist is empty';

  @override
  String get wishlistEmptyMineHint =>
      'Add things you\'d love to receive — friends pick from here.';

  @override
  String get wishlistEmptyFriend => 'Nothing here yet';

  @override
  String get wishlistError => 'Could not load wishlist';

  @override
  String get wishlistItemTitleLabel => 'Title';

  @override
  String get wishlistItemUrlLabel => 'Link (optional)';

  @override
  String get wishlistItemNoteLabel => 'Note (optional)';

  @override
  String get wishlistTitleRequired => 'Title is required';

  @override
  String get wishlistAddedSnack => 'Added to your wishlist';

  @override
  String get wishlistDeletedSnack => 'Removed from your wishlist';

  @override
  String get commonSave => 'Save';

  @override
  String get meTitle => 'Me';

  @override
  String get meProfileFallback => 'Profile';

  @override
  String get meProfileError => 'Could not load profile';

  @override
  String get meFriends => 'Friends';

  @override
  String get meSettings => 'Settings';

  @override
  String get meSettingsComingSoon => 'Coming with G-85';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsRequestsSection => 'Requests';

  @override
  String get friendsEmpty => 'No friends yet';

  @override
  String get friendsEmptyHint =>
      'Kept works with friends — invite yours to get started.';

  @override
  String get friendsError => 'Could not load friends';

  @override
  String get friendAccept => 'Accept';

  @override
  String get friendDecline => 'Decline';

  @override
  String get friendCancelRequest => 'Cancel request';

  @override
  String get friendRemove => 'Remove';

  @override
  String get friendPendingOutgoing => 'Request sent';

  @override
  String get friendRemoveConfirmTitle => 'Remove friend?';

  @override
  String friendRemoveConfirmBody(String name) {
    return '$name will no longer see your friends-only sections.';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityTooltip => 'Activity';

  @override
  String get activityEmpty => 'Nothing here yet';
}
