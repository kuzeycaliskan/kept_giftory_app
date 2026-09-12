import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(this.birthdays);

  final List<UpcomingBirthday> birthdays;

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async => Success(birthdays);
}

class _FakeFriendshipRepository implements FriendshipRepository {
  _FakeFriendshipRepository(this.entries);

  final List<FriendEntry> entries;

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => Success(entries);

  @override
  Future<Result<void>> accept(String friendshipId) async => const Success(null);

  @override
  Future<Result<void>> decline(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> remove(String friendshipId) async => const Success(null);

  @override
  Future<Result<void>> sendRequest(String profileId) async =>
      const Success(null);
}

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    required List<UpcomingBirthday> birthdays,
    List<FriendEntry> friendEntries = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            _FakeHomeRepository(birthdays),
          ),
          friendshipRepositoryProvider.overrideWithValue(
            _FakeFriendshipRepository(friendEntries),
          ),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty upcoming section drives friend discovery', (tester) async {
    await pumpHome(tester, birthdays: const []);

    expect(find.text('No upcoming birthdays yet'), findsOneWidget);
    expect(find.text('Find friends'), findsOneWidget);
    // The mock activity panel is gone (G-86) — no sample badge anywhere.
    expect(find.text('sample'), findsNothing);
  });

  testWidgets('shows birthday cards sorted with countdown', (tester) async {
    await pumpHome(
      tester,
      birthdays: [
        UpcomingBirthday(
          friendId: 'a',
          username: 'ali',
          displayName: 'Ali',
          birthday: DateTime(1995, 9, 6),
          daysUntil: 0,
        ),
        UpcomingBirthday(
          friendId: 'z',
          username: 'zeynep',
          displayName: 'Zeynep',
          birthday: DateTime(1997, 9, 12),
          daysUntil: 3,
        ),
      ],
    );

    expect(find.text('Ali'), findsOneWidget);
    expect(find.textContaining('Today!'), findsOneWidget);
    expect(find.text('Zeynep'), findsOneWidget);
    expect(find.textContaining('In 3 days'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Gift'), findsNWidgets(2));
  });

  testWidgets('tapping Find friends opens the Friends screen', (tester) async {
    await pumpHome(tester, birthdays: const []);

    await tester.tap(find.text('Find friends'));
    await tester.pumpAndSettle();

    expect(find.text('No friends yet'), findsOneWidget);
  });

  testWidgets('bell shows a badge with the pending-request count', (
    tester,
  ) async {
    await pumpHome(
      tester,
      birthdays: const [],
      friendEntries: const [
        FriendEntry(
          friendshipId: 'f1',
          profileId: 'p1',
          username: 'selin',
          displayName: 'Selin',
          status: FriendshipStatus.pending,
          direction: RequestDirection.incoming,
        ),
      ],
    );

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);
    expect(find.text('1'), findsOneWidget);
  });
}
