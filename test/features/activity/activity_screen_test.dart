import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/activity/presentation/activity_screen.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/events/domain/events_repository.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:kept/features/notifications/application/notifications_providers.dart';
import 'package:kept/features/notifications/domain/app_notification.dart';
import 'package:kept/features/notifications/domain/notifications_repository.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/data/dev_profile_repository.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/shared/domain/comment.dart';

class _FakeFriendshipRepository implements FriendshipRepository {
  _FakeFriendshipRepository(this.entries);

  List<FriendEntry> entries;
  final List<String> accepted = [];
  final List<String> declined = [];

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => Success(entries);

  @override
  Future<Result<void>> accept(String friendshipId) async {
    accepted.add(friendshipId);
    entries = entries.where((e) => e.friendshipId != friendshipId).toList();
    return const Success(null);
  }

  @override
  Future<Result<void>> decline(String friendshipId) async {
    declined.add(friendshipId);
    entries = entries.where((e) => e.friendshipId != friendshipId).toList();
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String friendshipId) async => const Success(null);

  @override
  Future<Result<void>> sendRequest(String profileId) async =>
      const Success(null);
}

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(this.birthdays);
  @override
  Future<Result<SurpriseTeaser?>> surpriseTeaser() async => const Success(null);

  final List<UpcomingBirthday> birthdays;

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async => Success(birthdays);

  @override
  Future<Result<List<HomeEvent>>> recentEvents({int limit = 6}) async =>
      const Success([]);
}

const _request = FriendEntry(
  friendshipId: 'f1',
  profileId: 'selin-id',
  username: 'selin',
  displayName: 'Selin',
  status: FriendshipStatus.pending,
  direction: RequestDirection.incoming,
);

final _birthday = UpcomingBirthday(
  friendId: 'ali-id',
  username: 'ali',
  displayName: 'Ali',
  birthday: DateTime(1995, 9, 20),
  daysUntil: 3,
);

class _FakeEventsRepository implements EventsRepository {
  _FakeEventsRepository(this.events);

  List<GiftEvent> events;
  final calls = <String>[];

  @override
  Future<Result<List<GiftEvent>>> fetchMine() async => Success(events);

  @override
  Future<Result<GiftEvent?>> fetchEvent(String eventId) async =>
      Success(events.where((e) => e.id == eventId).firstOrNull);

  @override
  Future<Result<String>> createOrJoin(
    String honoreeId, {
    EventKind kind = EventKind.birthday,
    DateTime? date,
    String? title,
  }) async => const ResultFailure(NetworkFailure('fake'));

  @override
  Future<Result<EventForHonoree?>> eventForHonoree(String honoreeId) async =>
      const Success(null);

  @override
  Future<Result<List<ProfileCard>>> invitableFriends(String eventId) async =>
      const Success([]);

  @override
  Future<Result<void>> invite(String eventId, String userId) async =>
      const Success(null);

  @override
  Future<Result<void>> respond(String eventId, {required bool join}) async {
    calls.add('respond:$eventId:$join');
    events = events.where((e) => e.id != eventId).toList();
    return const Success(null);
  }

  @override
  Future<Result<void>> leave(String eventId) async => const Success(null);

  @override
  Future<Result<void>> delete(String eventId) async => const Success(null);

  final notes = <Comment>[];

  @override
  Future<Result<List<Comment>>> fetchComments(String eventId) async =>
      Success(notes);

  @override
  Future<Result<Comment>> addComment(String eventId, String body) async {
    final c = Comment(
      id: 'n${notes.length + 1}',
      authorId: 'dev-me',
      body: body,
      createdAt: DateTime.now(),
    );
    notes.add(c);
    return Success(c);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    notes.removeWhere((c) => c.id == commentId);
    return const Success(null);
  }

  @override
  Future<Result<void>> setChatUrl(String eventId, String? url) async =>
      const Success(null);

  @override
  Future<Result<void>> reveal(String eventId) async => const Success(null);

  @override
  Future<Result<void>> thank(String eventId, String note) async =>
      const Success(null);

  @override
  Future<Result<List<GiftEntry>>> fetchEventGifts(String eventId) async =>
      const Success([]);
}

GiftEvent _invite(String id) => GiftEvent(
  id: id,
  honoreeId: 'ali',
  honoree: const ProfileCard(id: 'ali', username: 'ali', displayName: 'Ali'),
  eventDate: DateTime(2026, 10, 4),
  revealAt: DateTime(2026, 10, 5),
  status: EventStatus.open,
  members: const [
    EventMember(
      userId: 'dev-me',
      role: EventMemberRole.member,
      status: EventMemberStatus.invited,
    ),
  ],
);

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository([List<AppNotification> rows = const []])
    : rows = [...rows];

  List<AppNotification> rows;
  final calls = <String>[];

  @override
  Future<Result<List<AppNotification>>> fetchRecent({int limit = 50}) async =>
      Success(rows);

  @override
  Future<Result<void>> markRead(String id) async {
    calls.add('read:$id');
    rows = [
      for (final n in rows)
        if (n.id == id)
          AppNotification(
            id: n.id,
            kind: n.kind,
            title: n.title,
            body: n.body,
            route: n.route,
            createdAt: n.createdAt,
            readAt: DateTime(2026, 10, 5),
          )
        else
          n,
    ];
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllRead() async {
    calls.add('read-all');
    return const Success(null);
  }
}

void main() {
  String? pushedLocation;

  Future<void> pump(
    WidgetTester tester, {
    List<GiftEvent> invites = const [],
    List<FriendEntry> requests = const [],
    List<UpcomingBirthday> birthdays = const [],
    _FakeFriendshipRepository? friendships,
    _FakeNotificationsRepository? inbox,
    // The real app opens Activity on top of the tab shell; tests that
    // follow a notice into a tab need that stack, not a bare screen.
    bool overShell = false,
  }) async {
    pushedLocation = null;
    final router = GoRouter(
      initialLocation: overShell ? '/' : '/activity',
      routes: [
        GoRoute(path: '/activity', builder: (_, _) => const ActivityScreen()),
        // The app's tab shell, so a notice aimed at a tab root is exercised
        // the way it crashes for real: a push of an already-present page.
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => shell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => const Scaffold(body: Text('home tab')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/gifts',
                  builder: (_, state) {
                    pushedLocation = state.uri.toString();
                    return const Scaffold(body: Text('gifts tab'));
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/users/:uid',
          builder: (_, state) {
            pushedLocation = state.uri.toString();
            return const Scaffold(body: Text('profile screen'));
          },
        ),
        GoRoute(
          path: '/events/:id',
          builder: (_, state) {
            pushedLocation = state.uri.toString();
            return const Scaffold(body: Text('event screen'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(
            _FakeEventsRepository(invites),
          ),
          profileRepositoryProvider.overrideWithValue(
            const DevProfileRepository(),
          ),
          friendshipRepositoryProvider.overrideWithValue(
            friendships ?? _FakeFriendshipRepository(List.of(requests)),
          ),
          homeRepositoryProvider.overrideWithValue(
            _FakeHomeRepository(birthdays),
          ),
          notificationsRepositoryProvider.overrideWithValue(
            inbox ?? _FakeNotificationsRepository(),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (overShell) {
      unawaited(router.push('/activity'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('empty state renders when nothing is pending', (tester) async {
    await pump(tester);

    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('shows requests and birthdays in sections', (tester) async {
    await pump(tester, requests: const [_request], birthdays: [_birthday]);

    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Selin'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Ali'), findsOneWidget);
  });

  testWidgets('accepting a request removes the row', (tester) async {
    final friendships = _FakeFriendshipRepository([_request]);
    await pump(tester, friendships: friendships);

    await tester.tap(find.byTooltip('Accept'));
    await tester.pumpAndSettle();

    expect(friendships.accepted, ['f1']);
    expect(find.text('Selin'), findsNothing);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('tapping rows opens the profile', (tester) async {
    await pump(tester, requests: const [_request]);

    await tester.tap(find.text('Selin'));
    await tester.pumpAndSettle();
    expect(pushedLocation, '/users/selin-id?name=Selin');
  });

  testWidgets('accepting an invitation lands in the event', (tester) async {
    await pump(tester, invites: [_invite('e9')]);
    await tester.tap(find.byTooltip('Join'));
    await tester.pumpAndSettle();
    expect(pushedLocation, '/events/e9');
  });

  testWidgets('the inbox lists notices; a tap marks read and follows', (
    tester,
  ) async {
    final inbox = _FakeNotificationsRepository([
      AppNotification(
        id: 'n1',
        kind: 'pool:logged',
        title: 'Ortak hediye kaydedildi',
        body: 'Kamil Tent kaydetti; sen de verenler arasındasın.',
        route: '/events/e5',
        createdAt: DateTime(2026, 10, 5, 9, 30),
      ),
      AppNotification(
        id: 'n2',
        kind: 'event:thanks',
        title: 'Kuzey teşekkür etti',
        body: 'Sağ olun',
        createdAt: DateTime(2026, 10, 4, 18),
        readAt: DateTime(2026, 10, 4, 19),
      ),
    ]);
    await pump(tester, inbox: inbox);

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Ortak hediye kaydedildi'), findsOneWidget);
    // One unread dot, one read row; the header offers mark-all.
    expect(find.byIcon(Icons.circle), findsOneWidget);
    expect(find.byTooltip('Mark all as read'), findsOneWidget);

    await tester.tap(find.text('Ortak hediye kaydedildi'));
    await tester.pumpAndSettle();
    expect(inbox.calls, ['read:n1']);
    expect(pushedLocation, '/events/e5');
  });

  testWidgets('a notice aimed at a tab root switches tabs, no duplicate page', (
    tester,
  ) async {
    final inbox = _FakeNotificationsRepository([
      AppNotification(
        id: 'n3',
        kind: 'pool:share_removed',
        title: 'Ortak hediyeden çıkarıldın',
        body: 'Kamil Tent havuzundan katkını kaldırdı.',
        route: '/gifts',
        createdAt: DateTime(2026, 10, 5, 9, 30),
      ),
    ]);
    await pump(tester, inbox: inbox, overShell: true);

    await tester.tap(find.text('Ortak hediyeden çıkarıldın'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('gifts tab'), findsOneWidget);
    expect(pushedLocation, '/gifts');
  });
}
