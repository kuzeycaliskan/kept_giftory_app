import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(
    this.birthdays, {
    this.wishlistItems = const [],
    this.events = const [],
  });

  final List<UpcomingBirthday> birthdays;
  final List<FriendWishlistItem> wishlistItems;
  final List<HomeEvent> events;

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async => Success(birthdays);

  @override
  Future<Result<List<FriendWishlistItem>>> recentFriendWishlistItems({
    int limit = 6,
  }) async => Success(wishlistItems);

  @override
  Future<Result<List<HomeEvent>>> recentEvents({int limit = 6}) async =>
      Success(events);
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
    List<FriendWishlistItem> wishlistItems = const [],
    List<HomeEvent> events = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            _FakeHomeRepository(
              birthdays,
              wishlistItems: wishlistItems,
              events: events,
            ),
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

  const acceptedFriend = FriendEntry(
    friendshipId: 'f9',
    profileId: 'p9',
    username: 'zeynep',
    displayName: 'Zeynep',
    status: FriendshipStatus.accepted,
  );

  testWidgets('with friends, wishlist feed and activity render real rows', (
    tester,
  ) async {
    await pumpHome(
      tester,
      birthdays: const [],
      friendEntries: const [acceptedFriend],
      wishlistItems: [
        FriendWishlistItem(
          itemId: 'w1',
          title: 'Ski goggles',
          ownerId: 'p9',
          ownerUsername: 'zeynep',
          ownerDisplayName: 'Zeynep',
          createdAt: DateTime(2026, 9, 12),
        ),
      ],
      events: [
        HomeEvent(
          kind: HomeEventKind.giftReceived,
          at: DateTime(2026, 9, 11),
          actorId: 'p9',
          actorLabel: 'Zeynep',
        ),
      ],
    );

    expect(find.text("From friends' wishlists"), findsOneWidget);
    expect(find.text('Ski goggles'), findsOneWidget);
    // The stories strip (G-202) sits above; the lower sections need a scroll.
    await tester.drag(find.text('Upcoming'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Zeynep logged a gift for you'), findsOneWidget);
  });

  testWidgets('empty sections nudge toward inviting, not hide', (tester) async {
    await pumpHome(
      tester,
      birthdays: const [],
      friendEntries: const [acceptedFriend],
    );

    await tester.drag(find.text('Upcoming'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Invite'), findsNWidgets(2));
    expect(find.textContaining('gift ideas pile up'), findsOneWidget);
  });

  testWidgets('cold start (no friends) hides sections, shows one CTA', (
    tester,
  ) async {
    await pumpHome(tester, birthdays: const []);

    expect(find.text('Find friends'), findsOneWidget);
    expect(find.text("From friends' wishlists"), findsNothing);
    expect(find.text('Activity'), findsNothing);
  });
}
