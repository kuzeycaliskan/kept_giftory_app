import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/events/domain/events_repository.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/events/presentation/event_detail_screen.dart';
import 'package:kept/features/events/presentation/events_page.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/data/dev_profile_repository.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';
import 'package:kept/shared/domain/comment.dart';

/// The honoree's wishlist as the event's gift ideas (G-303).
class _FakeWishlistRepository implements WishlistRepository {
  const _FakeWishlistRepository(this.items);

  final List<WishlistItem> items;

  @override
  Future<Result<List<WishlistItem>>> fetchMine() async => const Success([]);

  @override
  Future<Result<List<WishlistItem>>> fetchFor(String profileId) async =>
      Success(items);

  @override
  Future<Result<WishlistItem>> add({
    required String title,
    String? note,
    String? url,
    String? linkPreviewId,
  }) async => const ResultFailure(UnknownFailure());

  @override
  Future<Result<void>> delete(String itemId) async => const Success(null);
}

class _FakeEventsRepository implements EventsRepository {
  _FakeEventsRepository({List<GiftEvent> events = const []})
    : events = [...events];

  List<GiftEvent> events;
  final calls = <String>[];

  @override
  Future<Result<List<GiftEvent>>> fetchMine() async => Success(events);

  @override
  Future<Result<GiftEvent?>> fetchEvent(String eventId) async =>
      Success(events.where((e) => e.id == eventId).firstOrNull);

  @override
  Future<Result<String>> createOrJoin(String honoreeId) async {
    calls.add('create:$honoreeId');
    final event = GiftEvent(
      id: 'ev-$honoreeId',
      honoreeId: honoreeId,
      honoree: ProfileCard(id: honoreeId, username: 'ali', displayName: 'Ali'),
      eventDate: DateTime(2026, 10, 4),
      revealAt: DateTime(2026, 10, 5),
      status: EventStatus.open,
      members: const [
        EventMember(
          userId: 'dev-me',
          role: EventMemberRole.organizer,
          status: EventMemberStatus.joined,
        ),
      ],
    );
    events.add(event);
    return Success(event.id);
  }

  @override
  Future<Result<EventForHonoree?>> eventForHonoree(String honoreeId) async =>
      const Success(null);

  @override
  Future<Result<List<ProfileCard>>> invitableFriends(String eventId) async =>
      const Success([
        ProfileCard(id: 'zeynep', username: 'zeynep', displayName: 'Zeynep'),
      ]);

  @override
  Future<Result<void>> invite(String eventId, String userId) async {
    calls.add('invite:$eventId:$userId');
    return const Success(null);
  }

  @override
  Future<Result<void>> respond(String eventId, {required bool join}) async {
    calls.add('respond:$eventId:$join');
    final i = events.indexWhere((e) => e.id == eventId);
    final e = events[i];
    events[i] = e.copyWith(
      members: [
        for (final m in e.members)
          if (m.userId == 'dev-me')
            EventMember(
              userId: m.userId,
              role: m.role,
              status: join
                  ? EventMemberStatus.joined
                  : EventMemberStatus.declined,
              user: m.user,
            )
          else
            m,
      ],
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> leave(String eventId) async {
    calls.add('leave:$eventId');
    events.removeWhere((e) => e.id == eventId);
    return const Success(null);
  }

  @override
  Future<Result<void>> cancel(String eventId) async {
    calls.add('cancel:$eventId');
    events.removeWhere((e) => e.id == eventId);
    return const Success(null);
  }

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
  Future<Result<void>> setChatUrl(String eventId, String? url) async {
    calls.add('chat:$eventId:$url');
    return const Success(null);
  }
}

class _FakeFriendshipRepository implements FriendshipRepository {
  const _FakeFriendshipRepository(this.entries);

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
      const ResultFailure(NetworkFailure('read-only fake'));
}

GiftEvent event({
  required String id,
  required EventMemberStatus myStatus,
  EventMemberRole myRole = EventMemberRole.member,
  String? chat,
}) => GiftEvent(
  id: id,
  honoreeId: 'ali',
  honoree: const ProfileCard(id: 'ali', username: 'ali', displayName: 'Ali'),
  eventDate: DateTime(2026, 10, 4),
  revealAt: DateTime(2026, 10, 5),
  status: EventStatus.open,
  externalChatUrl: chat,
  members: [
    EventMember(userId: 'dev-me', role: myRole, status: myStatus),
    const EventMember(
      userId: 'kamil',
      role: EventMemberRole.organizer,
      status: EventMemberStatus.joined,
      user: ProfileCard(id: 'kamil', username: 'kamil', displayName: 'Kamil'),
    ),
  ],
);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required _FakeEventsRepository repo,
    String initial = '/events',
    List<FriendEntry> friends = const [],
    List<WishlistItem> wishlist = const [],
  }) async {
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/events',
          builder: (_, __) => const Scaffold(body: EventsPage()),
        ),
        GoRoute(
          path: '/events/:id',
          builder: (_, state) =>
              EventDetailScreen(eventId: state.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(repo),
          profileRepositoryProvider.overrideWithValue(
            const DevProfileRepository(),
          ),
          friendshipRepositoryProvider.overrideWithValue(
            _FakeFriendshipRepository(friends),
          ),
          wishlistRepositoryProvider.overrideWithValue(
            _FakeWishlistRepository(wishlist),
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

  testWidgets('empty hub invites to open an event', (tester) async {
    await pump(tester, repo: _FakeEventsRepository());
    expect(find.text('No gift events yet'), findsOneWidget);
    expect(find.text('Open a gift event'), findsOneWidget);
  });

  testWidgets('invitations come first and can be accepted', (tester) async {
    final repo = _FakeEventsRepository(
      events: [
        event(id: 'e1', myStatus: EventMemberStatus.invited),
        event(id: 'e2', myStatus: EventMemberStatus.joined),
      ],
    );
    await pump(tester, repo: repo);

    expect(find.text('Invitations'), findsOneWidget);
    expect(find.text('Join the gift event for Ali?'), findsOneWidget);
    expect(find.text('Your events'), findsOneWidget);

    await tester.tap(find.byTooltip('Join'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['respond:e1:true']);
    expect(find.text('Invitations'), findsNothing);
  });

  testWidgets('detail shows members, secrecy note and invites a friend', (
    tester,
  ) async {
    final repo = _FakeEventsRepository(
      events: [
        event(
          id: 'e2',
          myStatus: EventMemberStatus.joined,
          chat: 'https://chat.whatsapp.com/x',
        ),
      ],
    );
    await pump(tester, repo: repo, initial: '/events/e2');

    expect(find.text("Ali's birthday"), findsOneWidget);
    expect(find.textContaining("can't see this event"), findsOneWidget);
    expect(find.text('Kamil'), findsOneWidget);
    expect(find.text('Open group chat'), findsOneWidget);

    // The gift-ideas section pushed the invite row below the fold.
    await tester.scrollUntilVisible(
      find.text('Invite friends'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invite friends'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invite'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['invite:e2:zeynep']);
  });

  testWidgets('picking a friend opens the event and lands on it', (
    tester,
  ) async {
    final repo = _FakeEventsRepository();
    await pump(
      tester,
      repo: repo,
      friends: [
        FriendEntry(
          friendshipId: 'f1',
          profileId: 'ali',
          username: 'ali',
          displayName: 'Ali',
          birthday: DateTime(1995, 10, 4),
          status: FriendshipStatus.accepted,
        ),
      ],
    );

    await tester.tap(find.text('Open a gift event'));
    await tester.pumpAndSettle();
    expect(find.text('Whose birthday?'), findsOneWidget);
    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['create:ali']);
    expect(find.text("Ali's birthday"), findsOneWidget);
    expect(find.text('Organizer'), findsOneWidget);
  });

  testWidgets("gift ideas list the honoree's wishlist with claim strips", (
    tester,
  ) async {
    final repo = _FakeEventsRepository(
      events: [event(id: 'e4', myStatus: EventMemberStatus.joined)],
    );
    await pump(
      tester,
      repo: repo,
      initial: '/events/e4',
      wishlist: const [
        WishlistItem(id: 'w1', ownerId: 'ali', title: 'Coffee grinder'),
      ],
    );

    expect(find.text('Gift ideas'), findsOneWidget);
    expect(find.text('Coffee grinder'), findsOneWidget);
    expect(find.text("I'll get this"), findsOneWidget);
    expect(find.text('Open the wishlist'), findsOneWidget);
  });

  testWidgets('pulling the detail down refetches the event', (tester) async {
    final repo = _FakeEventsRepository(
      events: [event(id: 'e6', myStatus: EventMemberStatus.joined)],
    );
    await pump(tester, repo: repo, initial: '/events/e6');
    expect(find.text("Ali's birthday"), findsOneWidget);

    // Someone joined meanwhile — the pull shows the new member count.
    final e = repo.events.single;
    repo.events = [
      e.copyWith(
        members: [
          ...e.members,
          const EventMember(
            userId: 'zeynep',
            role: EventMemberRole.member,
            status: EventMemberStatus.joined,
            user: ProfileCard(
              id: 'zeynep',
              username: 'zeynep',
              displayName: 'Zeynep',
            ),
          ),
        ],
      ),
    ];
    expect(find.text('Zeynep'), findsNothing);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Zeynep'), findsOneWidget);
  });

  testWidgets('an invitee sees no gift ideas yet', (tester) async {
    final repo = _FakeEventsRepository(
      events: [event(id: 'e5', myStatus: EventMemberStatus.invited)],
    );
    await pump(
      tester,
      repo: repo,
      initial: '/events/e5',
      wishlist: const [
        WishlistItem(id: 'w1', ownerId: 'ali', title: 'Coffee grinder'),
      ],
    );

    expect(find.text('Gift ideas'), findsNothing);
    expect(find.text('Coffee grinder'), findsNothing);
  });

  testWidgets('joined members write on the notes board', (tester) async {
    final repo = _FakeEventsRepository(
      events: [event(id: 'e3', myStatus: EventMemberStatus.joined)],
    );
    await pump(tester, repo: repo, initial: '/events/e3');

    expect(find.text('Notes'), findsOneWidget);
    await tester.tap(find.text('Write a comment…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Pastayı ben alıyorum');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(repo.notes.single.body, 'Pastayı ben alıyorum');
    expect(find.text('Pastayı ben alıyorum'), findsOneWidget);
  });
}
