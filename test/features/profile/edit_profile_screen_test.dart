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
import 'package:kept/features/profile/presentation/edit_profile_screen.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({required this.me, this.usernameTaken = false});

  Profile me;
  final bool usernameTaken;
  final List<Profile> saved = [];

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async {
    if (usernameTaken && profile.username != me.username) {
      return const ResultFailure(ValidationFailure('Username taken'));
    }
    saved.add(profile);
    me = profile;
    return Success(profile);
  }

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
  Future<Result<Profile>> updateVisibility({
    Visibility? profile,
    Visibility? wishlist,
    Visibility? giftHistory,
  }) async => Success(me);

  @override
  Future<Result<Profile>> setBirthdayReminders({required bool enabled}) async =>
      Success(me);

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async =>
      const Success([]);

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async =>
      const Success(null);
}

final _me = Profile(
  id: 'me',
  username: 'kuzey',
  displayName: 'Kuzey',
  birthday: DateTime(1998, 5, 5),
  occupation: 'Engineer',
);

void main() {
  Future<void> pump(
    WidgetTester tester,
    _FakeProfileRepository repository,
  ) async {
    // Pushed as a real route so popping after save lands on a Scaffold that
    // can still host the confirmation snackbar.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('form is prefilled from the profile', (tester) async {
    await pump(tester, _FakeProfileRepository(me: _me));

    expect(find.widgetWithText(TextField, 'kuzey'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Kuzey'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Engineer'), findsOneWidget);
    expect(find.textContaining('May 5, 1998'), findsOneWidget);
  });

  testWidgets('saving trims fields, persists and pops with a snackbar', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(me: _me);
    await pump(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextField, 'Engineer'),
      '  Designer  ',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.occupation, 'Designer');
    expect(find.text('Profile updated.'), findsOneWidget);
  });

  testWidgets('invalid username shows a field error and never saves', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(me: _me);
    await pump(tester, repository);

    await tester.enterText(find.widgetWithText(TextField, 'kuzey'), 'a!');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.saved, isEmpty);
    // 'a!' fails the length rule first (min 3).
    expect(find.text('At least 3 characters'), findsOneWidget);
  });

  testWidgets('taken username maps to the field error', (tester) async {
    final repository = _FakeProfileRepository(me: _me, usernameTaken: true);
    await pump(tester, repository);

    await tester.enterText(find.widgetWithText(TextField, 'kuzey'), 'zeynep');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.saved, isEmpty);
    expect(find.text('That username is taken'), findsOneWidget);
  });
}
