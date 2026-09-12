import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/onboarding/presentation/onboarding_screen.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';

class _FakeProfileRepository implements ProfileRepository {
  const _FakeProfileRepository();

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async =>
      const Success(true);

  @override
  Future<Result<Profile?>> fetchMyProfile() async => const Success(null);

  @override
  Future<Result<Profile?>> fetchProfile(String profileId) async =>
      const Success(null);

  @override
  Future<Result<Profile>> createProfile({
    required String username,
    String? displayName,
    DateTime? birthday,
  }) async => Success(Profile(id: 'x', username: username));

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async =>
      Success(profile);

  @override
  Future<Result<Profile>> updateVisibility({
    Visibility? profile,
    Visibility? wishlist,
    Visibility? giftHistory,
  }) async => const Success(Profile(id: 'x', username: 'x'));

  @override
  Future<Result<Profile>> setBirthdayReminders({required bool enabled}) async =>
      const Success(Profile(id: 'x', username: 'x'));

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async =>
      const Success([]);

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async =>
      const Success(null);
}

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            const _FakeProfileRepository(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> goToStepTwo(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'kuzey');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('About you'), findsOneWidget);
  }

  testWidgets('valid free username advances to the about step', (tester) async {
    await pump(tester);
    await goToStepTwo(tester);

    // Birthday explains its value and Finish waits for it.
    expect(find.textContaining('we remind them'), findsOneWidget);
    final finish = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Finish'),
    );
    expect(finish.onPressed, isNull);
  });

  testWidgets('step two offers a way back to fix the username', (tester) async {
    await pump(tester);
    await goToStepTwo(tester);

    // Usernames are permanent after profile creation — the back arrow is
    // the last chance to fix a typo.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Choose a username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'kuzey'), findsOneWidget);
  });
}
