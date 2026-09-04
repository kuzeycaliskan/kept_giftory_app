import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';
import 'package:kept/features/wishlist/presentation/add_wishlist_item_screen.dart';
import 'package:kept/features/wishlist/presentation/wishlist_screen.dart';

class _FakeWishlistRepository implements WishlistRepository {
  _FakeWishlistRepository({List<WishlistItem>? mine, this.friendItems})
      : mine = mine ?? [];

  final List<WishlistItem> mine;
  final List<WishlistItem>? friendItems;

  @override
  Future<Result<List<WishlistItem>>> fetchMine() async => Success(mine);

  @override
  Future<Result<List<WishlistItem>>> fetchFor(String profileId) async =>
      Success(friendItems ?? const []);

  @override
  Future<Result<WishlistItem>> add({
    required String title,
    String? note,
    String? url,
  }) async {
    final item = WishlistItem(
      id: 'new-${mine.length}',
      ownerId: 'me',
      title: title,
    );
    mine.add(item);
    return Success(item);
  }

  @override
  Future<Result<void>> delete(String itemId) async {
    mine.removeWhere((i) => i.id == itemId);
    return const Success(null);
  }
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    _FakeWishlistRepository repo, {
    String initial = '/wishlist',
  }) async {
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/wishlist',
          builder: (_, __) => const WishlistScreen(),
        ),
        GoRoute(
          path: '/wishlist/add',
          builder: (_, __) => const AddWishlistItemScreen(),
        ),
        GoRoute(
          path: '/users/:uid/wishlist',
          builder: (_, state) => WishlistScreen(
            ownerId: state.pathParameters['uid'],
            ownerLabel: state.uri.queryParameters['name'],
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [wishlistRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const kindle = WishlistItem(id: 'w1', ownerId: 'me', title: 'Kindle');

  testWidgets('empty own list drives adding', (tester) async {
    await pump(tester, _FakeWishlistRepository());

    expect(find.text('Your wishlist is empty'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('add form requires a title', (tester) async {
    await pump(tester, _FakeWishlistRepository(), initial: '/wishlist/add');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
  });

  testWidgets('saving a valid item stores it and pops back', (tester) async {
    final repo = _FakeWishlistRepository();
    await pump(tester, repo);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Ski goggles',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.mine, hasLength(1));
    expect(find.text('Ski goggles'), findsOneWidget); // back on the list
  });

  testWidgets('swiping own item left deletes it', (tester) async {
    final repo = _FakeWishlistRepository(mine: [kindle]);
    await pump(tester, repo);

    await tester.drag(find.text('Kindle'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(repo.mine, isEmpty);
    expect(find.text('Your wishlist is empty'), findsOneWidget);
  });

  testWidgets("friend's list is read-only", (tester) async {
    final repo = _FakeWishlistRepository(
      friendItems: const [
        WishlistItem(id: 'f1', ownerId: 'ali', title: 'Coffee grinder'),
      ],
    );
    await pump(tester, repo, initial: '/users/ali/wishlist?name=Ali');

    expect(find.text('Ali · Wishlist'), findsOneWidget);
    expect(find.text('Coffee grinder'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(Dismissible), findsNothing);
  });
}
