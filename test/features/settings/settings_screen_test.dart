import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:kept/features/auth/domain/auth_repository.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:kept/features/settings/presentation/settings_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  bool deleteCalled = false;
  bool signOutCalled = false;
  Result<void> deleteResult = const Success(null);

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalled = true;
    return deleteResult;
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCalled = true;
    return const Success(null);
  }

  @override
  String? get currentUserId => 'u1';

  @override
  Stream<String?> authStateChanges() => const Stream.empty();

  @override
  Future<Result<String>> signInWithApple() async => const Success('u1');

  @override
  Future<Result<String>> signInWithGoogle() async => const Success('u1');
}

class _FakeProfileRepository implements ProfileRepository {
  Profile me = const Profile(id: 'u1', username: 'you');
  final List<bool> reminderCalls = [];

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
  }) async => Success(me);

  @override
  Future<Result<Profile>> setBirthdayReminders({required bool enabled}) async {
    reminderCalls.add(enabled);
    me = me.copyWith(birthdayRemindersEnabled: enabled);
    return Success(me);
  }

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async =>
      const Success([]);

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async =>
      const Success(null);
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    _FakeAuthRepository repo, {
    _FakeProfileRepository? profiles,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          if (profiles != null)
            profileRepositoryProvider.overrideWithValue(profiles),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sign out calls the repository', (tester) async {
    final repo = _FakeAuthRepository();
    await pump(tester, repo);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(repo.signOutCalled, isTrue);
  });

  testWidgets('delete account requires confirmation', (tester) async {
    final repo = _FakeAuthRepository();
    await pump(tester, repo);
    await scrollTo(tester, 'Delete account');

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);

    // Cancel → no deletion.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.deleteCalled, isFalse);

    // Confirm → deletion runs.
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();
    expect(repo.deleteCalled, isTrue);
  });

  testWidgets('deletion failure shows an error', (tester) async {
    final repo = _FakeAuthRepository()
      ..deleteResult = const ResultFailure(UnknownFailure('nope'));
    await pump(tester, repo);
    await scrollTo(tester, 'Delete account');

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not delete'), findsOneWidget);
  });

  testWidgets('birthday reminders switch reflects and updates the profile', (
    tester,
  ) async {
    final profiles = _FakeProfileRepository();
    await pump(tester, _FakeAuthRepository(), profiles: profiles);

    final switchFinder = find.byType(SwitchListTile);
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(profiles.reminderCalls, [false]);
    expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
  });
}
