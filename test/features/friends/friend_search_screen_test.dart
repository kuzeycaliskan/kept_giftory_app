import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/presentation/friend_search_screen.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.results = const [], this.failSearch = false});

  final List<ProfileCard> results;
  final bool failSearch;
  final List<String> queries = [];

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async {
    queries.add(query);
    if (failSearch) return const ResultFailure(NetworkFailure('offline'));
    final q = query.toLowerCase();
    return Success(
      results
          .where(
            (p) =>
                p.username.contains(q) ||
                (p.displayName?.toLowerCase().contains(q) ?? false),
          )
          .toList(),
    );
  }

  @override
  Future<Result<Profile?>> fetchMyProfile() async => const Success(null);

  @override
  Future<Result<Profile?>> fetchProfile(String profileId) async =>
      const Success(null);

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
  }) async => const Success(Profile(id: 'x', username: 'x'));

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async =>
      const Success(null);
}

const _ali = ProfileCard(id: 'ali-id', username: 'ali', displayName: 'Ali');
const _alice = ProfileCard(id: 'alice-id', username: 'alice');

void main() {
  String? pushedLocation;

  Future<void> pump(
    WidgetTester tester,
    _FakeProfileRepository repository,
  ) async {
    pushedLocation = null;
    final router = GoRouter(
      initialLocation: '/friends/search',
      routes: [
        GoRoute(
          path: '/friends/search',
          builder: (_, __) => const FriendSearchScreen(),
        ),
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
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    // Cross the debounce window, then let the request settle.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  testWidgets('short queries show the prompt and never hit the repository', (
    tester,
  ) async {
    final repository = _FakeProfileRepository();
    await pump(tester, repository);

    expect(find.text('Type at least 2 characters to search'), findsOneWidget);

    await search(tester, 'a');
    expect(find.text('Type at least 2 characters to search'), findsOneWidget);
    expect(repository.queries, isEmpty);
  });

  testWidgets('results render and tapping one opens the profile', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(results: const [_ali, _alice]);
    await pump(tester, repository);

    await search(tester, 'al');
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('@ali'), findsOneWidget);
    expect(find.text('@alice'), findsOneWidget);

    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();
    expect(pushedLocation, '/users/ali-id?name=Ali');
  });

  testWidgets('no matches show the empty state', (tester) async {
    final repository = _FakeProfileRepository(results: const [_ali]);
    await pump(tester, repository);

    await search(tester, 'zeynep');
    expect(
      find.text('No one found — check the spelling or invite them!'),
      findsOneWidget,
    );
  });

  testWidgets('a failed search shows the error state', (tester) async {
    final repository = _FakeProfileRepository(failSearch: true);
    await pump(tester, repository);

    await search(tester, 'ali');
    expect(find.text('Search failed — please try again.'), findsOneWidget);
  });
}
