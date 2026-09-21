import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/format/money.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/data/dev_profile_repository.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/wishlist/application/claims_providers.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/claims_repository.dart';
import 'package:kept/features/wishlist/domain/wishlist_claim.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';
import 'package:kept/features/wishlist/presentation/wishlist_screen.dart';

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

/// In-memory claims keyed by item id; `taken` items refuse a new claim the
/// way the unique index does.
class _FakeClaimsRepository implements ClaimsRepository {
  _FakeClaimsRepository({
    Map<String, WishlistClaim> claims = const {},
    this.taken = const {},
  }) : claims = {...claims};

  static const me = 'dev-me';

  final Map<String, WishlistClaim> claims;
  final Set<String> taken;
  final calls = <String>[];

  @override
  Future<Result<Map<String, WishlistClaim>>> fetchForOwner(
    String ownerId,
  ) async => Success({
    for (final c in claims.values)
      if (c.ownerId == ownerId) c.itemId: c,
  });

  @override
  Future<Result<WishlistClaim>> claim(
    String itemId, {
    required ClaimKind kind,
    double? targetAmount,
  }) async {
    calls.add('claim:$itemId:${kind.name}:$targetAmount');
    if (taken.contains(itemId)) return const ResultFailure(ConflictFailure());
    final claim = WishlistClaim(
      id: 'c-$itemId',
      itemId: itemId,
      ownerId: 'ali',
      claimerId: me,
      kind: kind,
      targetAmount: targetAmount,
    );
    claims[itemId] = claim;
    return Success(claim);
  }

  @override
  Future<Result<void>> release(String claimId) async {
    calls.add('release:$claimId');
    claims.removeWhere((_, c) => c.id == claimId);
    return const Success(null);
  }

  @override
  Future<Result<void>> makeShared(
    String claimId, {
    double? targetAmount,
  }) async {
    calls.add('shared:$claimId:$targetAmount');
    return const Success(null);
  }

  @override
  Future<Result<void>> pledge(String claimId, double amount) async {
    calls.add('pledge:$claimId:$amount');
    final entry = claims.entries.firstWhere((e) => e.value.id == claimId);
    final c = entry.value;
    claims[entry.key] = WishlistClaim(
      id: c.id,
      itemId: c.itemId,
      ownerId: c.ownerId,
      claimerId: c.claimerId,
      kind: c.kind,
      targetAmount: c.targetAmount,
      claimer: c.claimer,
      pledges: [
        ...c.pledges.where((p) => p.userId != me),
        Pledge(userId: me, amount: amount),
      ],
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> withdrawPledge(String claimId, String userId) async {
    calls.add('withdraw:$claimId:$userId');
    return const Success(null);
  }
}

void main() {
  const grinder = WishlistItem(
    id: 'f1',
    ownerId: 'ali',
    title: 'Coffee grinder',
  );
  const zeynep = ProfileCard(
    id: 'zeynep',
    username: 'zeynep',
    displayName: 'Zeynep',
  );

  Future<void> pump(
    WidgetTester tester, {
    required _FakeClaimsRepository claims,
    List<WishlistItem> items = const [grinder],
    double textScale = 1,
  }) async {
    final router = GoRouter(
      initialLocation: '/users/ali/wishlist?name=Ali',
      routes: [
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
        overrides: [
          wishlistRepositoryProvider.overrideWithValue(
            _FakeWishlistRepository(items),
          ),
          claimsRepositoryProvider.overrideWithValue(claims),
          profileRepositoryProvider.overrideWithValue(
            const DevProfileRepository(),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('money', () {
    test('parses Turkish and plain amounts', () {
      expect(parseAmount('1200'), 1200);
      expect(parseAmount('1.200'), 1200);
      expect(parseAmount('1.200,50'), 1200.5);
      expect(parseAmount('1200,50'), 1200.5);
      expect(parseAmount('1200.50'), 1200.5);
      expect(parseAmount('0'), isNull);
      expect(parseAmount('abc'), isNull);
      // Shop price strings from link previews.
      expect(parseAmount('1.299,00 TL'), 1299);
      expect(parseAmount('₺1.299'), 1299);
      expect(parseAmount('1299 TRY'), 1299);
    });

    test('plain field text round-trips through parse', () {
      expect(plainAmount(1299), '1299');
      expect(plainAmount(1299.5), '1299,50');
      expect(parseAmount(plainAmount(1299.5)), 1299.5);
    });

    test('formats lira without noise', () {
      expect(formatTry('en', 1200), '₺1,200');
      expect(formatTry('tr', 1200.5), '₺1.200,50');
    });
  });

  group('claim strip', () {
    testWidgets('a free item offers both ways in; "I\'ll get this" claims it', (
      tester,
    ) async {
      final claims = _FakeClaimsRepository();
      await pump(tester, claims: claims);

      expect(find.text("I'll get this"), findsOneWidget);
      expect(find.text('Chip in together'), findsOneWidget);

      await tester.tap(find.text("I'll get this"));
      await tester.pumpAndSettle();

      expect(claims.calls, ['claim:f1:solo:null']);
      expect(find.text("You're getting this"), findsOneWidget);
      expect(find.text("I'll get this"), findsNothing);
    });

    testWidgets('losing the race is explained, not retried', (tester) async {
      final claims = _FakeClaimsRepository(taken: {'f1'});
      await pump(tester, claims: claims);

      await tester.tap(find.text("I'll get this"));
      await tester.pumpAndSettle();

      expect(find.text('Someone already reserved this'), findsOneWidget);
    });

    testWidgets("someone else's claim shows who and no buttons", (
      tester,
    ) async {
      final claims = _FakeClaimsRepository(
        claims: const {
          'f1': WishlistClaim(
            id: 'c1',
            itemId: 'f1',
            ownerId: 'ali',
            claimerId: 'zeynep',
            kind: ClaimKind.solo,
            claimer: zeynep,
          ),
        },
      );
      await pump(tester, claims: claims);

      expect(find.text('Zeynep is getting this'), findsOneWidget);
      expect(find.text("I'll get this"), findsNothing);
      expect(find.byIcon(Icons.more_horiz), findsNothing);
    });

    testWidgets('a pool shows progress and takes my pledge', (tester) async {
      final claims = _FakeClaimsRepository(
        claims: const {
          'f1': WishlistClaim(
            id: 'c1',
            itemId: 'f1',
            ownerId: 'ali',
            claimerId: 'zeynep',
            kind: ClaimKind.shared,
            targetAmount: 3000,
            claimer: zeynep,
            pledges: [Pledge(userId: 'zeynep', amount: 1000, user: zeynep)],
          ),
        },
      );
      await pump(tester, claims: claims);

      expect(find.text('Group gift · 1 in · ₺1,000 of ₺3,000'), findsOneWidget);
      expect(find.text('33% · ₺2,000 left'), findsOneWidget);

      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();
      expect(find.text('₺2,000 left · 1 in'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '500');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(claims.calls, ['pledge:c1:500.0']);
      expect(find.text('Your share: ₺500'), findsOneWidget);
      expect(find.text('Group gift · 2 in · ₺1,500 of ₺3,000'), findsOneWidget);
      expect(find.text('50% · ₺1,500 left'), findsOneWidget);
    });

    testWidgets('a pool that reached its price reads as funded', (
      tester,
    ) async {
      final claims = _FakeClaimsRepository(
        claims: const {
          'f1': WishlistClaim(
            id: 'c1',
            itemId: 'f1',
            ownerId: 'ali',
            claimerId: 'zeynep',
            kind: ClaimKind.shared,
            targetAmount: 1000,
            claimer: zeynep,
            pledges: [Pledge(userId: 'zeynep', amount: 1200, user: zeynep)],
          ),
        },
      );
      await pump(tester, claims: claims);

      expect(find.text('Fully funded'), findsOneWidget);
      expect(find.textContaining('left'), findsNothing);
    });

    testWidgets('starting a pool pre-fills the product price, editable', (
      tester,
    ) async {
      final claims = _FakeClaimsRepository();
      await pump(
        tester,
        claims: claims,
        items: const [
          WishlistItem(
            id: 'f1',
            ownerId: 'ali',
            title: 'Racket',
            preview: LinkPreview(
              id: 'lp',
              url: 'https://shop.example.com/racket',
              title: 'Babolat Pure Drive',
              price: '1.299,00 TL',
            ),
          ),
        ],
      );

      await tester.tap(find.text('Chip in together'));
      await tester.pumpAndSettle();
      final priceField = find.widgetWithText(
        TextField,
        'Product price (target)',
      );
      expect(tester.widget<TextField>(priceField).controller!.text, '1299');

      await tester.enterText(priceField, '1100');
      await tester.enterText(
        find.widgetWithText(TextField, 'Your share (optional)'),
        '300',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(claims.calls.first, 'claim:f1:shared:1100.0');
      expect(claims.calls.last, 'pledge:c-f1:300.0');
      expect(find.text('27% · ₺800 left'), findsOneWidget);
    });

    testWidgets('a pledge must be a positive amount', (tester) async {
      final claims = _FakeClaimsRepository(
        claims: const {
          'f1': WishlistClaim(
            id: 'c1',
            itemId: 'f1',
            ownerId: 'ali',
            claimerId: 'zeynep',
            kind: ClaimKind.shared,
          ),
        },
      );
      await pump(tester, claims: claims);
      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter an amount above zero'), findsOneWidget);
      expect(claims.calls, isEmpty);
    });

    testWidgets('the organiser can cancel the pool from the participants', (
      tester,
    ) async {
      final claims = _FakeClaimsRepository(
        claims: const {
          'f1': WishlistClaim(
            id: 'c1',
            itemId: 'f1',
            ownerId: 'ali',
            claimerId: 'dev-me',
            kind: ClaimKind.shared,
            pledges: [Pledge(userId: 'zeynep', amount: 250, user: zeynep)],
          ),
        },
      );
      await pump(tester, claims: claims);

      await tester.tap(find.textContaining('Group gift'));
      await tester.pumpAndSettle();
      expect(find.text('Zeynep'), findsOneWidget);
      expect(find.text('₺250'), findsOneWidget);

      await tester.tap(find.text('Cancel the group gift'));
      await tester.pumpAndSettle();

      expect(claims.calls, ['release:c1']);
      expect(find.text("I'll get this"), findsOneWidget);
    });

    testWidgets('narrow screen at 2x text scale never overflows', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final claims = _FakeClaimsRepository(
        claims: const {
          'f2': WishlistClaim(
            id: 'c2',
            itemId: 'f2',
            ownerId: 'ali',
            claimerId: 'zeynep',
            kind: ClaimKind.shared,
            targetAmount: 12000,
            claimer: zeynep,
            pledges: [Pledge(userId: 'zeynep', amount: 4500, user: zeynep)],
          ),
        },
      );
      await pump(
        tester,
        claims: claims,
        items: const [
          grinder,
          WishlistItem(id: 'f2', ownerId: 'ali', title: 'Espresso machine'),
        ],
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      expect(find.text("I'll get this"), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);
    });
  });
}
