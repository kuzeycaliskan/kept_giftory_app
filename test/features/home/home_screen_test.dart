import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';
import 'package:kept/shared/widgets/private_media_image.dart';

import '../feed/feed_test_support.dart';

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(this.birthdays, {this.events = const [], this.teaser});

  final List<UpcomingBirthday> birthdays;
  final List<HomeEvent> events;
  final SurpriseTeaser? teaser;

  @override
  Future<Result<SurpriseTeaser?>> surpriseTeaser() async => Success(teaser);

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async => Success(birthdays);

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

/// A handful of frames for screens with a looping animation (shimmer),
/// where pumpAndSettle would never return.
Future<void> pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

class _FakeWishlistRepository implements WishlistRepository {
  const _FakeWishlistRepository(this.items);

  final List<WishlistItem> items;

  @override
  Future<Result<List<WishlistItem>>> fetchMine() async => const Success([]);

  @override
  Future<Result<List<WishlistItem>>> fetchFor(String profileId) async =>
      Success(items.where((i) => i.ownerId == profileId).toList());

  @override
  Future<Result<WishlistItem>> add({
    required String title,
    String? note,
    String? url,
    String? linkPreviewId,
  }) async => const ResultFailure(NetworkFailure('read-only fake'));

  @override
  Future<Result<void>> delete(String itemId) async => const Success(null);
}

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    required List<UpcomingBirthday> birthdays,
    List<FriendEntry> friendEntries = const [],
    List<HomeEvent> events = const [],
    SurpriseTeaser? teaser,
    List<WishlistItem> friendWishes = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            _FakeHomeRepository(birthdays, events: events, teaser: teaser),
          ),
          wishlistRepositoryProvider.overrideWithValue(
            _FakeWishlistRepository(friendWishes),
          ),
          mediaStoreProvider.overrideWithValue(const FakeMediaStore()),
          friendshipRepositoryProvider.overrideWithValue(
            _FakeFriendshipRepository(friendEntries),
          ),
        ],
        child: const KeptApp(),
      ),
    );
    if (teaser == null) {
      await tester.pumpAndSettle();
    } else {
      // The teaser's shimmer loops forever: settle by frames, not idleness.
      await pumpFrames(tester);
    }
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
      events: [
        HomeEvent(
          kind: HomeEventKind.giftReceived,
          at: DateTime(2026, 9, 11),
          actorId: 'p9',
          actorLabel: 'Zeynep',
          item: 'Scarf',
        ),
        // G-212: my own record of a gift from outside Kept — never "someone".
        HomeEvent(
          kind: HomeEventKind.externalGiftLogged,
          at: DateTime(2026, 9, 10),
          giverRelation: GiftRelation.father,
          item: 'Watch',
        ),
      ],
    );

    // The stories strip (G-202) sits above; the lower sections need a scroll.
    await tester.drag(find.text('Upcoming'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Zeynep logged a gift for you'), findsOneWidget);
    expect(find.text('Scarf'), findsOneWidget);
    expect(find.text('Gift from Dad'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.textContaining('Someone'), findsNothing);
  });

  testWidgets('empty sections nudge toward inviting, not hide', (tester) async {
    await pumpHome(
      tester,
      birthdays: const [],
      friendEntries: const [acceptedFriend],
    );

    await tester.drag(find.text('Upcoming'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Invite'), findsOneWidget);
    expect(find.textContaining('things happen here'), findsOneWidget);
  });

  testWidgets('cold start (no friends) hides sections, shows one CTA', (
    tester,
  ) async {
    await pumpHome(tester, birthdays: const []);

    expect(find.text('Find friends'), findsOneWidget);
    expect(find.text('Activity'), findsNothing);
  });

  testWidgets("friends' gifts render as posts with photos and link", (
    tester,
  ) async {
    final gift = GiftEntry(
      id: 'g9',
      item: 'Kupa',
      giftDate: DateTime(2026, 9, 13),
      isSurprise: false,
      counterpartId: 'k',
      counterpartLabel: 'Kuzey',
      giverId: 'k',
      recipientId: 'z',
      photos: [
        GiftPhoto(
          id: 'p1',
          giftId: 'g9',
          uploaderId: 'z',
          mediaPath: 'z/g9-1.jpg',
          createdAt: DateTime(2026, 9, 13),
        ),
        GiftPhoto(
          id: 'p2',
          giftId: 'g9',
          uploaderId: 'k',
          mediaPath: 'k/g9-2.jpg',
          createdAt: DateTime(2026, 9, 14),
        ),
      ],
    );
    await pumpHome(
      tester,
      birthdays: const [],
      friendEntries: const [acceptedFriend],
      events: [
        HomeEvent(
          kind: HomeEventKind.friendGiftReceived,
          at: DateTime(2026, 9, 13),
          actorId: 'k',
          actorLabel: 'Kuzey',
          item: 'Kupa',
          gift: gift,
          recipientId: 'z',
          recipientLabel: 'Zeynep',
        ),
      ],
    );
    await tester.drag(find.text('Upcoming'), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Zeynep got a gift from Kuzey'), findsOneWidget);
    expect(find.text('Kupa'), findsOneWidget);
    expect(find.byType(PrivateMediaImage), findsNWidgets(2));
  });

  testWidgets('a pending surprise shows the teaser, nothing more', (
    tester,
  ) async {
    await pumpHome(
      tester,
      birthdays: const [],
      friendEntries: const [acceptedFriend],
      teaser: SurpriseTeaser(nextRevealAt: DateTime(2026, 10, 16)),
    );
    await tester.drag(find.text('Upcoming'), const Offset(0, -500));
    await pumpFrames(tester);

    expect(find.text('A surprise is on its way to you'), findsOneWidget);
    expect(find.text('Opens on October 16'), findsOneWidget);
  });

  testWidgets("a birthday row expands into that friend's wishlist", (
    tester,
  ) async {
    await pumpHome(
      tester,
      birthdays: [
        UpcomingBirthday(
          friendId: 'z',
          username: 'zeynep',
          displayName: 'Zeynep',
          birthday: DateTime(1997, 9, 12),
          daysUntil: 3,
        ),
      ],
      friendWishes: const [
        WishlistItem(id: 'w1', ownerId: 'z', title: 'Ski goggles'),
        WishlistItem(id: 'w2', ownerId: 'other', title: 'Not hers'),
      ],
    );
    expect(find.text('Ski goggles'), findsNothing);

    await tester.tap(find.text('Zeynep'));
    await tester.pumpAndSettle();

    expect(find.text('Ski goggles'), findsOneWidget);
    expect(find.text('Not hers'), findsNothing);
    expect(find.text('See full wishlist'), findsOneWidget);

    // Collapses again on a second tap.
    await tester.tap(find.text('Zeynep'));
    await tester.pumpAndSettle();
    expect(find.text('Ski goggles'), findsNothing);
  });

  testWidgets('no overflow and no clipped countdown at 2x text scale', (
    tester,
  ) async {
    // Narrow phone, huge text, long name: the countdown must still show in
    // full (no ellipsis) and nothing may overflow (design.md §5).
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpHome(
      tester,
      birthdays: [
        UpcomingBirthday(
          friendId: 'w',
          username: 'wolfe',
          displayName: 'Wolfeschlegelsteinhausenbergerdorff',
          birthday: DateTime(1990, 9, 2),
          daysUntil: 361,
        ),
      ],
      friendEntries: const [acceptedFriend],
    );

    expect(tester.takeException(), isNull);
    final countdown = tester.widget<Text>(find.text('In 361 days'));
    expect(countdown.overflow, isNot(TextOverflow.ellipsis));
    expect(countdown.maxLines, isNull);
    expect(find.widgetWithText(FilledButton, 'Wishlist'), findsOneWidget);

    await tester.tap(find.text('In 361 days'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
