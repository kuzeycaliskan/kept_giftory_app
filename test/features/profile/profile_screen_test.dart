import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:kept/features/profile/presentation/user_profile_screen.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.other});

  final Profile? other;

  @override
  Future<Result<Profile?>> fetchMyProfile() async => const Success(null);

  @override
  Future<Result<Profile?>> fetchProfile(String profileId) async =>
      Success(other);

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async =>
      const Success(true);

  @override
  Future<Result<Profile>> createProfile({
    required String username,
    String? displayName,
    DateTime? birthday,
  }) async =>
      Success(Profile(id: 'x', username: username));

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async =>
      Success(profile);
}

class _FakeFriendshipRepository implements FriendshipRepository {
  _FakeFriendshipRepository({this.entries = const []});

  final List<FriendEntry> entries;
  final List<String> sentRequests = [];

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => Success(entries);

  @override
  Future<Result<void>> sendRequest(String profileId) async {
    sentRequests.add(profileId);
    return const Success(null);
  }

  @override
  Future<Result<void>> accept(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> decline(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> remove(String friendshipId) async =>
      const Success(null);
}

const _ali = Profile(
  id: 'ali-id',
  username: 'ali',
  displayName: 'Ali',
  occupation: 'Designer',
);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required _FakeProfileRepository profiles,
    _FakeFriendshipRepository? friendships,
  }) async {
    final router = GoRouter(
      initialLocation: '/users/ali-id?name=Ali',
      routes: [
        GoRoute(
          path: '/users/:uid',
          builder: (_, state) => UserProfileScreen(
            profileId: state.pathParameters['uid']!,
            label: state.uri.queryParameters['name'],
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(profiles),
          friendshipRepositoryProvider
              .overrideWithValue(friendships ?? _FakeFriendshipRepository()),
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

  testWidgets('renders header, tabs and Add friend for a stranger',
      (tester) async {
    final friendships = _FakeFriendshipRepository();
    await pump(
      tester,
      profiles: _FakeProfileRepository(other: _ali),
      friendships: friendships,
    );

    expect(find.text('@ali'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.text('Gifts'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    await tester.tap(find.text('Add friend'));
    await tester.pumpAndSettle();
    expect(friendships.sentRequests, ['ali-id']);
  });

  testWidgets('shows Friends chip when already friends', (tester) async {
    await pump(
      tester,
      profiles: _FakeProfileRepository(other: _ali),
      friendships: _FakeFriendshipRepository(
        entries: const [
          FriendEntry(
            friendshipId: 'f1',
            profileId: 'ali-id',
            username: 'ali',
            displayName: 'Ali',
            status: FriendshipStatus.accepted,
          ),
        ],
      ),
    );

    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Add friend'), findsNothing);
  });

  testWidgets('About tab shows profile facts', (tester) async {
    await pump(tester, profiles: _FakeProfileRepository(other: _ali));

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('Occupation'), findsOneWidget);
    expect(find.text('Designer'), findsOneWidget);
  });

  testWidgets('hidden profile renders the not-visible state', (tester) async {
    await pump(tester, profiles: _FakeProfileRepository());

    expect(find.text("This profile isn't visible"), findsOneWidget);
  });
}
