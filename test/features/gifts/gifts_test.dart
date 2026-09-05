import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';
import 'package:kept/features/gifts/domain/reveal_math.dart';
import 'package:kept/features/gifts/presentation/gifts_screen.dart';
import 'package:kept/features/gifts/presentation/log_gift_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeGiftRepository implements GiftRepository {
  _FakeGiftRepository({List<GiftEntry>? given, List<GiftEntry>? received})
      : given = given ?? [],
        received = received ?? [];

  final List<GiftEntry> given;
  final List<GiftEntry> received;

  @override
  Future<Result<List<GiftEntry>>> fetchGiven() async => Success(given);

  @override
  Future<Result<List<GiftEntry>>> fetchReceived() async => Success(received);

  @override
  Future<Result<List<GiftEntry>>> fetchFor(String profileId) async =>
      const Success([]);

  @override
  Future<Result<GiftEntry>> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
  }) async {
    final entry = GiftEntry(
      id: 'new-${given.length}',
      item: item,
      giftDate: giftDate,
      isSurprise: isSurprise,
      revealAt: revealAt,
      counterpartId: recipientId,
      counterpartLabel: 'Ali',
    );
    given.add(entry);
    return Success(entry);
  }

  @override
  Future<Result<void>> delete(String giftId) async {
    given.removeWhere((g) => g.id == giftId);
    return const Success(null);
  }
}

class _FakeFriendshipRepository implements FriendshipRepository {
  const _FakeFriendshipRepository(this.entries);

  final List<FriendEntry> entries;

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => Success(entries);

  @override
  Future<Result<void>> accept(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> decline(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> remove(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> sendRequest(String profileId) async =>
      const Success(null);
}

const _aliFriend = FriendEntry(
  friendshipId: 'f1',
  profileId: 'ali',
  username: 'ali',
  displayName: 'Ali',
  status: FriendshipStatus.accepted,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('defaultRevealAt', () {
    test('is next birthday + 1 day', () {
      final reveal =
          defaultRevealAt(DateTime(1995, 9, 10), DateTime(2026, 9, 4));
      expect(reveal, DateTime(2026, 9, 11));
    });

    test('falls back to +30 days without a birthday', () {
      final reveal = defaultRevealAt(null, DateTime(2026, 9, 4));
      expect(reveal, DateTime(2026, 10, 4));
    });
  });

  Future<void> pump(
    WidgetTester tester, {
    required _FakeGiftRepository gifts,
    List<FriendEntry> friends = const [_aliFriend],
    String initial = '/gifts',
  }) async {
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(path: '/gifts', builder: (_, __) => const GiftsScreen()),
        GoRoute(
          path: '/gifts/log',
          builder: (_, __) => const LogGiftScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          giftRepositoryProvider.overrideWithValue(gifts),
          friendshipRepositoryProvider
              .overrideWithValue(_FakeFriendshipRepository(friends)),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty given tab drives logging', (tester) async {
    await pump(tester, gifts: _FakeGiftRepository());

    expect(find.text('No gifts logged yet'), findsOneWidget);
    expect(find.text('Log your first gift'), findsOneWidget);
  });

  testWidgets(
      'log form: surprise on by default, requires recipient/item/reveal date',
      (tester) async {
    await pump(tester, gifts: _FakeGiftRepository(), initial: '/gifts/log');

    final surprise = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(surprise.value, isTrue);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a recipient'), findsOneWidget);
    expect(find.text('Gift is required'), findsOneWidget);
    expect(find.text('Pick a reveal date'), findsOneWidget);
  });

  testWidgets('logging a surprise gift with a reveal date pops back',
      (tester) async {
    final repo = _FakeGiftRepository();
    await pump(tester, gifts: repo);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Who is it for?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ali').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Gift'), 'Kindle');

    // Pick the suggested reveal date from the wheel-picker sheet.
    await tester.tap(find.text('Reveal date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.given, hasLength(1));
    expect(repo.given.single.isSurprise, isTrue);
    expect(repo.given.single.revealAt, isNotNull);
    expect(find.text('Kindle'), findsOneWidget);
  });

  testWidgets('turning surprise off asks for confirmation', (tester) async {
    await pump(tester, gifts: _FakeGiftRepository(), initial: '/gifts/log');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Turn off surprise?'), findsOneWidget);

    // Cancel keeps surprise on.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    // Confirm turns it off.
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });

  testWidgets('"don\'t show again" skips the confirmation next time',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      {'hide_surprise_off_warning': true},
    );
    await pump(tester, gifts: _FakeGiftRepository(), initial: '/gifts/log');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Turn off surprise?'), findsNothing);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });

  testWidgets('surprise gifts carry a badge on the given tab',
      (tester) async {
    await pump(
      tester,
      gifts: _FakeGiftRepository(
        given: [
          GiftEntry(
            id: 'g1',
            item: 'Secret watch',
            giftDate: DateTime(2026, 9),
            isSurprise: true,
            revealAt: DateTime.now().add(const Duration(days: 5)),
            counterpartLabel: 'Zeynep',
          ),
        ],
      ),
    );

    expect(find.text('Secret watch'), findsOneWidget);
    expect(find.text('Surprise'), findsOneWidget);
  });

  testWidgets('swiping a given gift left deletes it', (tester) async {
    final repo = _FakeGiftRepository(
      given: [
        GiftEntry(
          id: 'g1',
          item: 'AirPods',
          giftDate: DateTime(2026, 8, 15),
          isSurprise: false,
          counterpartLabel: 'Ali',
        ),
      ],
    );
    await pump(tester, gifts: repo);

    await tester.drag(find.text('AirPods'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(repo.given, isEmpty);
    expect(find.text('No gifts logged yet'), findsOneWidget);
  });

  testWidgets('received tab shows anonymized giver fallback', (tester) async {
    await pump(
      tester,
      gifts: _FakeGiftRepository(
        received: [
          GiftEntry(
            id: 'r1',
            item: 'Board game',
            giftDate: DateTime(2026, 7),
            isSurprise: false,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Received'));
    await tester.pumpAndSettle();

    expect(find.text('Board game'), findsOneWidget);
    expect(find.textContaining('Someone'), findsOneWidget);
  });
}
