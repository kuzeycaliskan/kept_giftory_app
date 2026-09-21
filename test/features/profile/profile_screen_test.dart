import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:kept/features/profile/presentation/user_profile_screen.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.other, this.card});

  /// Mutable: tests flip it to simulate RLS unlocking after an accept.
  Profile? other;

  /// Card returned when the full profile is hidden (private-profile state).
  final ProfileCard? card;

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
  }) async => Success(Profile(id: 'x', username: username));

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async =>
      Success(profile);

  @override
  Future<Result<Profile>> updateVisibility({
    Visibility? profile,
    Visibility? wishlist,
    Visibility? giftHistory,
  }) async => Success(other ?? const Profile(id: 'x', username: 'x'));

  @override
  Future<Result<Profile>> setBirthdayReminders({required bool enabled}) async =>
      const Success(Profile(id: 'x', username: 'x'));

  @override
  Future<Result<Profile>> setSocialNotifications({
    required bool enabled,
  }) async => const Success(Profile(id: 'x', username: 'x'));

  @override
  Future<Result<Profile>> updateAvatarPath(String path) async =>
      const Success(Profile(id: 'x', username: 'x'));

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async =>
      const Success([]);

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async =>
      Success(card);
}

class _FakeFriendshipRepository implements FriendshipRepository {
  _FakeFriendshipRepository({this.entries = const [], this.onAccept});

  List<FriendEntry> entries;
  final List<String> sentRequests = [];

  /// Lets tests mimic server-side effects of accepting (RLS unlock).
  final void Function()? onAccept;

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => Success(entries);

  @override
  Future<Result<void>> sendRequest(String profileId) async {
    sentRequests.add(profileId);
    return const Success(null);
  }

  @override
  Future<Result<void>> accept(String friendshipId) async {
    onAccept?.call();
    return const Success(null);
  }

  @override
  Future<Result<void>> decline(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> remove(String friendshipId) async => const Success(null);
}

const _ali = Profile(
  id: 'ali-id',
  username: 'ali',
  displayName: 'Ali',
  occupation: 'Designer',
);

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
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> delete(String itemId) async => const Success(null);
}

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required _FakeProfileRepository profiles,
    _FakeFriendshipRepository? friendships,
    List<WishlistItem> wishlist = const [],
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
          friendshipRepositoryProvider.overrideWithValue(
            friendships ?? _FakeFriendshipRepository(),
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

  testWidgets('renders header, tabs and Add friend for a stranger', (
    tester,
  ) async {
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

  testWidgets("a friend's wishlist tab shows product cards and claim strips", (
    tester,
  ) async {
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
      wishlist: const [
        WishlistItem(
          id: 'w1',
          ownerId: 'ali-id',
          title: 'Racket',
          preview: LinkPreview(
            id: 'lp',
            url: 'https://shop.example.com/racket',
            title: 'Babolat Pure Drive',
            site: 'shop.example.com',
          ),
        ),
      ],
    );

    // The same product card as the wishlist screen, not a bare title.
    expect(find.text('Babolat Pure Drive'), findsOneWidget);
    expect(find.text('shop.example.com'), findsOneWidget);
    expect(find.text("I'll get this"), findsOneWidget);
  });

  testWidgets('About tab shows profile facts', (tester) async {
    await pump(tester, profiles: _FakeProfileRepository(other: _ali));

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('Occupation'), findsOneWidget);
    expect(find.text('Designer'), findsOneWidget);
  });

  testWidgets('deleted user (no card either) renders the not-visible state', (
    tester,
  ) async {
    await pump(tester, profiles: _FakeProfileRepository());

    expect(find.text("This profile isn't visible"), findsOneWidget);
  });

  testWidgets(
    'private profile shows the card, notice and a working Add friend',
    (tester) async {
      final friendships = _FakeFriendshipRepository();
      await pump(
        tester,
        profiles: _FakeProfileRepository(
          card: const ProfileCard(
            id: 'ali-id',
            username: 'ali',
            displayName: 'Ali',
          ),
        ),
        friendships: friendships,
      );

      expect(find.text('Ali'), findsWidgets);
      expect(find.text('@ali'), findsOneWidget);
      expect(find.text('This profile is private'), findsOneWidget);
      // Full-profile details must NOT leak into the private state.
      expect(find.text('Wishlist'), findsNothing);

      await tester.tap(find.text('Add friend'));
      await tester.pumpAndSettle();
      expect(friendships.sentRequests, ['ali-id']);
    },
  );

  testWidgets('accepting from the private state reveals the profile in place', (
    tester,
  ) async {
    final profiles = _FakeProfileRepository(
      card: const ProfileCard(
        id: 'ali-id',
        username: 'ali',
        displayName: 'Ali',
      ),
    );
    const incoming = FriendEntry(
      friendshipId: 'f1',
      profileId: 'ali-id',
      username: 'ali',
      displayName: 'Ali',
      status: FriendshipStatus.pending,
      direction: RequestDirection.incoming,
    );
    late final _FakeFriendshipRepository friendships;
    friendships = _FakeFriendshipRepository(
      entries: const [incoming],
      // Server side of an accept: friendship flips, RLS unlocks the profile.
      onAccept: () {
        profiles.other = _ali;
        friendships.entries = const [
          FriendEntry(
            friendshipId: 'f1',
            profileId: 'ali-id',
            username: 'ali',
            displayName: 'Ali',
            status: FriendshipStatus.accepted,
          ),
        ];
      },
    );
    await pump(tester, profiles: profiles, friendships: friendships);

    expect(find.text('This profile is private'), findsOneWidget);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    // Full profile appears without leaving the screen.
    expect(find.text('This profile is private'), findsNothing);
    expect(find.text('@ali'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
  });
}
