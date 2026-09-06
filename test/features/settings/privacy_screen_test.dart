import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:kept/features/settings/presentation/privacy_screen.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({required this.me, this.failUpdates = false});

  Profile me;
  final bool failUpdates;

  /// (section-field, value) pairs recorded per updateVisibility call.
  final List<Map<String, Visibility?>> updates = [];

  @override
  Future<Result<Profile?>> fetchMyProfile() async => Success(me);

  @override
  Future<Result<Profile?>> fetchProfile(String profileId) async => Success(me);

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async =>
      const Success(true);

  @override
  Future<Result<Profile>> createProfile({
    required String username,
    String? displayName,
    DateTime? birthday,
  }) async => Success(me);

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async =>
      Success(profile);

  @override
  Future<Result<Profile>> updateVisibility({
    Visibility? profile,
    Visibility? wishlist,
    Visibility? giftHistory,
  }) async {
    updates.add({
      'profile': profile,
      'wishlist': wishlist,
      'giftHistory': giftHistory,
    });
    if (failUpdates) {
      return const ResultFailure(NetworkFailure('offline'));
    }
    me = me.copyWith(
      profileVisibility: profile ?? me.profileVisibility,
      wishlistVisibility: wishlist ?? me.wishlistVisibility,
      giftHistoryVisibility: giftHistory ?? me.giftHistoryVisibility,
    );
    return Success(me);
  }

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async =>
      const Success([]);

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async =>
      const Success(null);
}

const _me = Profile(id: 'me', username: 'you');

/// Fully open profile — sections aren't capped, all segments tappable.
const _openMe = Profile(
  id: 'me',
  username: 'you',
  profileVisibility: Visibility.public,
);

void main() {
  Future<void> pump(
    WidgetTester tester,
    _FakeProfileRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PrivacyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all three sections with current values', (tester) async {
    await pump(tester, _FakeProfileRepository(me: _me));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.text('Gift history'), findsOneWidget);
    // Profile row has no "Private" option; the two content rows do.
    expect(find.text('Private'), findsNWidgets(2));
    expect(find.text('Public'), findsNWidgets(3));
    expect(find.text('Friends'), findsNWidgets(3));
  });

  testWidgets('changing wishlist visibility hits only that section', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(me: _openMe);
    await pump(tester, repository);

    // Middle row's "Public" segment (rows are ordered profile/wishlist/gifts).
    await tester.tap(find.text('Public').at(1));
    await tester.pumpAndSettle();

    expect(repository.updates, hasLength(1));
    expect(repository.updates.single['wishlist'], Visibility.public);
    expect(repository.updates.single['profile'], isNull);
    expect(repository.updates.single['giftHistory'], isNull);
  });

  testWidgets('a failed update surfaces the error snackbar', (tester) async {
    final repository = _FakeProfileRepository(me: _me, failUpdates: true);
    await pump(tester, repository);

    await tester.tap(find.text('Public').first);
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't save the setting — please try again."),
      findsOneWidget,
    );
  });

  testWidgets(
    'friends-only profile caps sections: Public disabled, cap note shown',
    (tester) async {
      // Stored wishlist 'public' under a friends-only profile must display as
      // the effective 'friends' and refuse new Public selections.
      final repository = _FakeProfileRepository(
        me: _me.copyWith(wishlistVisibility: Visibility.public),
      );
      await pump(tester, repository);

      // Cap note is visible.
      expect(find.textContaining('set your profile to Public'), findsOneWidget);

      // Tapping the wishlist row's Public segment does nothing (disabled).
      await tester.tap(find.text('Public').at(1), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(repository.updates, isEmpty);
    },
  );
}
