import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/friends/presentation/friends_screen.dart';

/// In-memory repository: accept moves pending→accepted, remove deletes.
class _FakeFriendshipRepository implements FriendshipRepository {
  _FakeFriendshipRepository(this.entries);

  List<FriendEntry> entries;

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => Success(entries);

  @override
  Future<Result<void>> accept(String friendshipId) async {
    entries = [
      for (final e in entries)
        if (e.friendshipId == friendshipId)
          FriendEntry(
            friendshipId: e.friendshipId,
            profileId: e.profileId,
            username: e.username,
            displayName: e.displayName,
            status: FriendshipStatus.accepted,
          )
        else
          e,
    ];
    return const Success(null);
  }

  @override
  Future<Result<void>> decline(String friendshipId) async {
    entries =
        entries.where((e) => e.friendshipId != friendshipId).toList();
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String friendshipId) async {
    entries =
        entries.where((e) => e.friendshipId != friendshipId).toList();
    return const Success(null);
  }

  @override
  Future<Result<void>> sendRequest(String profileId) async =>
      const Success(null);
}

void main() {
  Future<void> pumpFriends(
    WidgetTester tester,
    _FakeFriendshipRepository repo,
  ) async {
    final router = GoRouter(
      initialLocation: '/friends',
      routes: [
        GoRoute(
          path: '/friends',
          builder: (_, __) => const FriendsScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          friendshipRepositoryProvider.overrideWithValue(repo),
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

  const incoming = FriendEntry(
    friendshipId: 'f1',
    profileId: 'p1',
    username: 'selin',
    displayName: 'Selin',
    status: FriendshipStatus.pending,
    direction: RequestDirection.incoming,
  );
  const friend = FriendEntry(
    friendshipId: 'f2',
    profileId: 'p2',
    username: 'ali',
    displayName: 'Ali',
    status: FriendshipStatus.accepted,
  );

  testWidgets('empty state invites the user', (tester) async {
    await pumpFriends(tester, _FakeFriendshipRepository([]));

    expect(find.text('No friends yet'), findsOneWidget);
  });

  testWidgets('sections split requests and friends', (tester) async {
    await pumpFriends(tester, _FakeFriendshipRepository([incoming, friend]));

    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Selin'), findsOneWidget);
    expect(find.text('Ali'), findsOneWidget);
  });

  testWidgets('accepting a request moves it to friends', (tester) async {
    await pumpFriends(tester, _FakeFriendshipRepository([incoming]));

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    expect(find.text('Requests'), findsNothing);
    expect(find.text('Selin'), findsOneWidget);
    expect(find.byIcon(Icons.person_remove_outlined), findsOneWidget);
  });

  testWidgets('removing a friend asks for confirmation first',
      (tester) async {
    final repo = _FakeFriendshipRepository([friend]);
    await pumpFriends(tester, repo);

    await tester.tap(find.byIcon(Icons.person_remove_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Remove friend?'), findsOneWidget);

    // Cancel keeps the friend.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Ali'), findsOneWidget);

    // Confirm removes.
    await tester.tap(find.byIcon(Icons.person_remove_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('No friends yet'), findsOneWidget);
  });
}
