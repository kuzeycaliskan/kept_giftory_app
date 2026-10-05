import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/application/special_days_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:kept/features/profile/domain/special_day.dart';
import 'package:kept/features/profile/domain/special_days_repository.dart';
import 'package:kept/features/profile/presentation/edit_profile_screen.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({required this.me});

  Profile me;
  final List<Profile> saved = [];

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async {
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
  Future<Result<Profile>> setSocialNotifications({
    required bool enabled,
  }) async => Success(me);

  @override
  Future<Result<Profile>> updateAvatarPath(String path) async =>
      const Success(Profile(id: 'x', username: 'x'));

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

class _FakeSpecialDays implements SpecialDaysRepository {
  _FakeSpecialDays([List<SpecialDay> days = const []]) : days = [...days];

  List<SpecialDay> days;
  final calls = <String>[];

  @override
  Future<Result<List<SpecialDay>>> fetchMine() async => Success(days);

  @override
  Future<Result<SpecialDay>> add({
    required EventKind kind,
    required DateTime day,
    String? title,
  }) async {
    calls.add('add:${kind.wire}:${title ?? ''}');
    final d = SpecialDay(
      id: 'sd${days.length + 1}',
      userId: 'dev-me',
      kind: kind,
      day: day,
      title: title,
    );
    days = [...days, d];
    return Success(d);
  }

  @override
  Future<Result<void>> remove(String id) async {
    calls.add('remove:$id');
    days = days.where((d) => d.id != id).toList();
    return const Success(null);
  }
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    _FakeProfileRepository repository, {
    _FakeSpecialDays? specialDays,
  }) async {
    // Pushed as a real route so popping after save lands on a Scaffold that
    // can still host the confirmation snackbar.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          specialDaysRepositoryProvider.overrideWithValue(
            specialDays ?? _FakeSpecialDays(),
          ),
        ],
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

  testWidgets('username field is read-only with the support note', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(me: _me);
    await pump(tester, repository);

    final username = tester.widget<TextField>(
      find.widgetWithText(TextField, 'kuzey'),
    );
    expect(username.enabled, isFalse);
    expect(find.textContaining("Username can't be changed"), findsOneWidget);
  });

  testWidgets('special days (G-410b): listed, added and removed', (
    tester,
  ) async {
    final days = _FakeSpecialDays([
      SpecialDay(
        id: 'sd1',
        userId: 'dev-me',
        kind: EventKind.wedding,
        day: DateTime(2026, 12, 2),
      ),
    ]);
    await pump(tester, _FakeProfileRepository(me: _me), specialDays: days);

    await tester.scrollUntilVisible(
      find.text('Add a day'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Special days'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);
    expect(find.text('December 2, 2026'), findsOneWidget);

    // Announce a baby: occasion sheet (no birthday offered) → date → saved.
    await tester.ensureVisible(find.text('Add a day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a day'));
    await tester.pumpAndSettle();
    expect(find.text("What's coming up?"), findsOneWidget);
    // Only the form's own Birthday row — the sheet offers none.
    expect(find.text('Birthday'), findsOneWidget);
    expect(find.text('Retirement'), findsOneWidget);
    await tester.tap(find.text('New baby'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(days.calls, ['add:new_baby:']);
    expect(find.text('New baby'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove').first);
    await tester.pumpAndSettle();
    expect(days.calls.last, 'remove:sd1');
    expect(find.text('Wedding'), findsNothing);
  });
}
