import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/activity/presentation/activity_screen.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

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

  final List<UpcomingBirthday> birthdays;

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async => Success(birthdays);
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

void main() {
  String? pushedLocation;

  Future<void> pump(
    WidgetTester tester, {
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
}
