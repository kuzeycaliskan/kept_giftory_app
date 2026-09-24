import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/activity/presentation/activity_screen.dart';
import 'package:kept/features/events/application/events_providers.dart';
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
  Future<Result<String>> createOrJoin(String honoreeId) async =>
      const ResultFailure(NetworkFailure('fake'));

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
  Future<Result<void>> cancel(String eventId) async => const Success(null);

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

void main() {
  String? pushedLocation;

  Future<void> pump(
    WidgetTester tester, {
    List<GiftEvent> invites = const [],
    List<FriendEntry> requests = const [],
    List<UpcomingBirthday> birthdays = const [],
    _FakeFriendshipRepository? friendships,
  }) async {
    pushedLocation = null;
    final router = GoRouter(
      initialLocation: '/activity',
      routes: [
        GoRoute(path: '/activity', builder: (_, __) => const ActivityScreen()),
        GoRoute(
          path: '/users/:uid',
          builder: (_, state) {
            pushedLocation = state.uri.toString();
            return const Scaffold(body: Text('profile screen'));
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

  testWidgets('event invitations show like requests and can be accepted', (
    tester,
  ) async {
    final fake = _FakeEventsRepository([_invite('e1')]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(fake),
          profileRepositoryProvider.overrideWithValue(
            const DevProfileRepository(),
          ),
          friendshipRepositoryProvider.overrideWithValue(
            _FakeFriendshipRepository(const []),
          ),
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepository([])),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ActivityScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invitations'), findsOneWidget);
    expect(find.text('Join the gift event for Ali?'), findsOneWidget);

    await tester.tap(find.byTooltip('Join'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['respond:e1:true']);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });
}
