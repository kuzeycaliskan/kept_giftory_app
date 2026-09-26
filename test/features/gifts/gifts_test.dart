import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';
import 'package:kept/features/gifts/domain/reveal_math.dart';
import 'package:kept/features/gifts/presentation/gift_detail_screen.dart';
import 'package:kept/features/gifts/presentation/gifts_screen.dart';
import 'package:kept/features/gifts/presentation/log_external_gift_screen.dart';
import 'package:kept/features/gifts/presentation/log_gift_screen.dart';
import 'package:kept/features/gifts/presentation/widgets/gift_photo_strip.dart';
import 'package:kept/features/link_preview/application/link_preview_providers.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/features/link_preview/domain/link_preview_repository.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/data/dev_profile_repository.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/shared/domain/comment.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:kept/shared/widgets/private_media_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../feed/feed_test_support.dart';

class _FakeGiftRepository implements GiftRepository {
  _FakeGiftRepository({List<GiftEntry>? given, List<GiftEntry>? received})
    : given = given ?? [],
      received = received ?? [];

  String? lastLinkPreviewId;
  String? lastEventId;
  String? lastClaimId;

  final List<GiftEntry> given;
  final List<GiftEntry> received;

  GiftRelation? lastExternalRelation;

  @override
  Future<Result<GiftEntry>> logExternal({
    required GiftRelation relation,
    required String item,
    required DateTime giftDate,
    String? note,
    String? linkPreviewId,
  }) async {
    lastExternalRelation = relation;
    final entry = GiftEntry(
      id: 'ext-1',
      item: item,
      giftDate: giftDate,
      isSurprise: false,
      giverRelation: relation,
    );
    received.add(entry);
    return Success(entry);
  }

  @override
  Future<Result<List<GiftEntry>>> fetchGiven() async => Success(given);

  @override
  Future<Result<List<GiftEntry>>> fetchReceived() async => Success(received);

  @override
  Future<Result<List<GiftEntry>>> fetchFor(String profileId) async =>
      const Success([]);

  @override
  Future<Result<GiftEntry>> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
    String? linkPreviewId,
    String? eventId,
    String? claimId,
  }) async {
    lastLinkPreviewId = linkPreviewId;
    lastEventId = eventId;
    lastClaimId = claimId;
    final entry = GiftEntry(
      id: 'new-${given.length}',
      item: item,
      giftDate: giftDate,
      isSurprise: isSurprise,
      revealAt: revealAt,
      counterpartId: recipientId,
      counterpartLabel: 'Ali',
    );
    given.add(entry);
    return Success(entry);
  }

  @override
  Future<Result<void>> delete(String giftId) async {
    given.removeWhere((g) => g.id == giftId);
    return const Success(null);
  }

  final attachedTo = <String>[];
  final removed = <String>[];

  @override
  Future<Result<GiftEntry?>> fetchGift(
    String giftId, {
    required bool counterpartIsGiver,
  }) async =>
      Success([...given, ...received].where((g) => g.id == giftId).firstOrNull);

  @override
  Future<Result<GiftPhoto>> addPhoto({
    required String giftId,
    required Uint8List jpegBytes,
  }) async {
    attachedTo.add(giftId);
    final photo = GiftPhoto(
      id: 'photo-${attachedTo.length}',
      giftId: giftId,
      uploaderId: 'dev-me',
      mediaPath: 'dev-me/$giftId-${attachedTo.length}.jpg',
      createdAt: DateTime(2026, 9, 16),
    );
    for (final list in [given, received]) {
      final i = list.indexWhere((g) => g.id == giftId);
      if (i >= 0) list[i] = _withPhotos(list[i], [...list[i].photos, photo]);
    }
    return Success(photo);
  }

  @override
  Future<Result<void>> removePhoto(GiftPhoto photo) async {
    removed.add(photo.id);
    for (final list in [given, received]) {
      final i = list.indexWhere((g) => g.id == photo.giftId);
      if (i >= 0) {
        list[i] = _withPhotos(
          list[i],
          list[i].photos.where((p) => p.id != photo.id).toList(),
        );
      }
    }
    return const Success(null);
  }

  final reactions = <String>[];

  @override
  Future<Result<void>> setReaction(String giftId, ReactionKind kind) async {
    reactions.add('set:$giftId:${kind.name}');
    for (final list in [given, received]) {
      final i = list.indexWhere((g) => g.id == giftId);
      if (i >= 0) {
        list[i] = list[i].copyWith(
          reactions: [
            ...list[i].reactions.where((r) => r.userId != 'dev-me'),
            Reaction(userId: 'dev-me', kind: kind),
          ],
        );
      }
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> clearReaction(String giftId) async {
    reactions.add('clear:$giftId');
    for (final list in [given, received]) {
      final i = list.indexWhere((g) => g.id == giftId);
      if (i >= 0) {
        list[i] = list[i].copyWith(
          reactions: list[i].reactions
              .where((r) => r.userId != 'dev-me')
              .toList(),
        );
      }
    }
    return const Success(null);
  }

  final comments = <String, List<Comment>>{};

  @override
  Future<Result<List<Comment>>> fetchComments(String giftId) async =>
      Success(comments[giftId] ?? const []);

  @override
  Future<Result<Comment>> addComment(String giftId, String body) async {
    final c = Comment(
      id: 'c${(comments[giftId]?.length ?? 0) + 1}',
      authorId: 'dev-me',
      body: body,
      createdAt: DateTime.now(),
      user: const ProfileCard(id: 'dev-me', username: 'you'),
    );
    comments.putIfAbsent(giftId, () => []).add(c);
    for (final list in [given, received]) {
      final i = list.indexWhere((g) => g.id == giftId);
      if (i >= 0) {
        list[i] = list[i].copyWith(commentCount: comments[giftId]!.length);
      }
    }
    return Success(c);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    for (final list in comments.values) {
      list.removeWhere((c) => c.id == commentId);
    }
    return const Success(null);
  }

  static GiftEntry _withPhotos(GiftEntry g, List<GiftPhoto> photos) =>
      GiftEntry(
        id: g.id,
        item: g.item,
        giftDate: g.giftDate,
        isSurprise: g.isSurprise,
        note: g.note,
        revealAt: g.revealAt,
        counterpartId: g.counterpartId,
        counterpartLabel: g.counterpartLabel,
        preview: g.preview,
        giverRelation: g.giverRelation,
        giverId: g.giverId,
        recipientId: g.recipientId,
        photos: photos,
      );
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
      const Success(null);
}

const _aliFriend = FriendEntry(
  friendshipId: 'f1',
  profileId: 'ali',
  username: 'ali',
  displayName: 'Ali',
  status: FriendshipStatus.accepted,
);

class _FakeLinkPreviewRepository implements LinkPreviewRepository {
  _FakeLinkPreviewRepository({this.preview});

  final LinkPreview? preview;

  @override
  Future<LinkPreview?> fetch(String url, {bool refresh = false}) async =>
      preview;
}

/// Forms grew past one screen (photo section): bring the target into the
/// viewport before tapping — scrollUntilVisible only guarantees it is built.
Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('defaultRevealAt', () {
    test('is next birthday + 1 day', () {
      final reveal = defaultRevealAt(
        DateTime(1995, 9, 10),
        DateTime(2026, 9, 4),
      );
      expect(reveal, DateTime(2026, 9, 11));
    });

    test('falls back to +30 days without a birthday', () {
      final reveal = defaultRevealAt(null, DateTime(2026, 9, 4));
      expect(reveal, DateTime(2026, 10, 4));
    });
  });

  Future<void> pump(
    WidgetTester tester, {
    required _FakeGiftRepository gifts,
    List<FriendEntry> friends = const [_aliFriend],
    String initial = '/gifts',
    _FakeLinkPreviewRepository? linkPreviews,
    FakeImagePicker? picker,
    List<Override> overrides = const [],
  }) async {
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(path: '/gifts', builder: (_, __) => const GiftsScreen()),
        GoRoute(
          path: '/gifts/log',
          builder: (_, state) => LogGiftScreen(
            initialRecipientId: state.uri.queryParameters['recipient'],
            eventId: state.uri.queryParameters['event'],
            claimId: state.uri.queryParameters['claim'],
            initialItem: state.uri.queryParameters['item'],
            initialUrl: state.uri.queryParameters['url'],
          ),
        ),
        GoRoute(
          path: '/gifts/log-external',
          builder: (_, __) => const LogExternalGiftScreen(),
        ),
        GoRoute(
          path: '/gifts/:id',
          builder: (_, state) => GiftDetailScreen(
            giftId: state.pathParameters['id']!,
            counterpartIsGiver:
                state.uri.queryParameters['side'] != 'recipient',
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          giftRepositoryProvider.overrideWithValue(gifts),
          // Signed-in identity for "may I add photos" (dev-me).
          profileRepositoryProvider.overrideWithValue(
            const DevProfileRepository(),
          ),
          mediaStoreProvider.overrideWithValue(const FakeMediaStore()),
          imagePickerProvider.overrideWithValue(
            picker ?? FakeImagePicker(null),
          ),
          uploadEncoderProvider.overrideWithValue((bytes) async => bytes),
          friendshipRepositoryProvider.overrideWithValue(
            _FakeFriendshipRepository(friends),
          ),
          linkPreviewRepositoryProvider.overrideWithValue(
            linkPreviews ?? _FakeLinkPreviewRepository(),
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

  testWidgets('empty given tab drives logging', (tester) async {
    await pump(tester, gifts: _FakeGiftRepository());

    expect(find.text('No gifts logged yet'), findsOneWidget);
    expect(find.text('Log your first gift'), findsOneWidget);
  });

  testWidgets(
    'log form: surprise on by default, requires recipient/item/reveal date',
    (tester) async {
      await pump(tester, gifts: _FakeGiftRepository(), initial: '/gifts/log');

      final surprise = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(surprise.value, isTrue);

      await tester.scrollUntilVisible(
        find.text('Save'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await scrollToAndTap(tester, find.text('Save'));
      // Validation messages sit at the top of the (now longer) form.
      await tester.drag(find.byType(ListView), const Offset(0, 800));
      await tester.pumpAndSettle();

      expect(find.text('Pick a recipient'), findsOneWidget);
      expect(find.text('Gift is required'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pick a reveal date'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pick a reveal date'), findsOneWidget);
    },
  );

  testWidgets('logging a surprise gift with a reveal date pops back', (
    tester,
  ) async {
    final repo = _FakeGiftRepository();
    await pump(tester, gifts: repo);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Who is it for?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ali').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Gift'), 'Kindle');

    // Pick the suggested reveal date from the wheel-picker sheet.
    await tester.tap(find.text('Reveal date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.given, hasLength(1));
    expect(repo.given.single.isSurprise, isTrue);
    expect(repo.given.single.revealAt, isNotNull);
    expect(find.text('Kindle'), findsOneWidget);
  });

  testWidgets('logging from an event pre-selects the honoree and links it', (
    tester,
  ) async {
    final repo = _FakeGiftRepository();
    await pump(tester, gifts: repo);
    // Pushed from the event page, so saving can pop back to it.
    unawaited(
      GoRouter.of(
        tester.element(find.byType(GiftsScreen)),
      ).push('/gifts/log?recipient=ali&event=e1'),
    );
    await tester.pumpAndSettle();

    // Recipient already chosen and locked: it is the honoree's event.
    expect(find.text('Ali'), findsWidgets);
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .onChanged,
      isNull,
    );
    await tester.enterText(find.widgetWithText(TextField, 'Gift'), 'Kindle');
    await tester.tap(find.text('Reveal date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.given, hasLength(1));
    expect(repo.lastEventId, 'e1');
  });

  testWidgets('a reservation pre-fills the gift and links the record', (
    tester,
  ) async {
    final repo = _FakeGiftRepository();
    await pump(tester, gifts: repo);
    unawaited(
      GoRouter.of(
        tester.element(find.byType(GiftsScreen)),
      ).push('/gifts/log?recipient=ali&claim=c1&item=Coffee%20grinder'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ali'), findsWidgets);
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Gift'))
          .controller!
          .text,
      'Coffee grinder',
    );
    await tester.tap(find.text('Reveal date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.given, hasLength(1));
    expect(repo.lastClaimId, 'c1');
  });

  testWidgets('an event gift takes the event reveal as its date', (
    tester,
  ) async {
    final repo = _FakeGiftRepository();
    final event = GiftEvent(
      id: 'e1',
      honoreeId: 'ali',
      eventDate: DateTime(2026, 10, 4),
      revealAt: DateTime(2026, 10, 5),
      status: EventStatus.open,
      members: const [],
    );
    await pump(
      tester,
      gifts: repo,
      overrides: [eventDetailProvider('e1').overrideWith((ref) async => event)],
    );
    unawaited(
      GoRouter.of(
        tester.element(find.byType(GiftsScreen)),
      ).push('/gifts/log?recipient=ali&event=e1'),
    );
    await tester.pumpAndSettle();

    // No picker: the date is the event's, shown read-only.
    expect(find.textContaining('Reveal date: Oct 5, 2026'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Gift'), 'Kindle');
    // The pushed form sits over the gifts list: fling the form's own list
    // to its end so Save is fully on screen once the scroll settles.
    final formList = find
        .descendant(
          of: find.byType(LogGiftScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.fling(formList, const Offset(0, -1200), 3000);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'), warnIfMissed: true);
    await tester.pumpAndSettle();

    expect(repo.given.single.revealAt, DateTime(2026, 10, 5));
    expect(repo.lastEventId, 'e1');
  });

  testWidgets('turning surprise off asks for confirmation', (tester) async {
    await pump(tester, gifts: _FakeGiftRepository(), initial: '/gifts/log');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Turn off surprise?'), findsOneWidget);

    // Cancel keeps surprise on.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    // Confirm turns it off.
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });

  testWidgets('"don\'t show again" skips the confirmation next time', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'hide_surprise_off_warning': true});
    await pump(tester, gifts: _FakeGiftRepository(), initial: '/gifts/log');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Turn off surprise?'), findsNothing);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });

  testWidgets('surprise gifts carry a badge on the given tab', (tester) async {
    await pump(
      tester,
      gifts: _FakeGiftRepository(
        given: [
          GiftEntry(
            id: 'g1',
            item: 'Secret watch',
            giftDate: DateTime(2026, 9),
            isSurprise: true,
            revealAt: DateTime.now().add(const Duration(days: 5)),
            counterpartLabel: 'Zeynep',
          ),
        ],
      ),
    );

    expect(find.text('Secret watch'), findsOneWidget);
    expect(find.text('Surprise'), findsOneWidget);
  });

  testWidgets('swiping a given gift left deletes it', (tester) async {
    final repo = _FakeGiftRepository(
      given: [
        GiftEntry(
          id: 'g1',
          item: 'AirPods',
          giftDate: DateTime(2026, 8, 15),
          isSurprise: false,
          counterpartLabel: 'Ali',
        ),
      ],
    );
    await pump(tester, gifts: repo);

    await tester.drag(find.text('AirPods'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(repo.given, isEmpty);
    expect(find.text('No gifts logged yet'), findsOneWidget);
  });

  testWidgets('received tab shows anonymized giver fallback', (tester) async {
    await pump(
      tester,
      gifts: _FakeGiftRepository(
        received: [
          GiftEntry(
            id: 'r1',
            item: 'Board game',
            giftDate: DateTime(2026, 7),
            isSurprise: false,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Received'));
    await tester.pumpAndSettle();

    expect(find.text('Board game'), findsOneWidget);
    expect(find.textContaining('Someone'), findsOneWidget);
  });

  testWidgets('horizontal swipe moves between given and received', (
    tester,
  ) async {
    await pump(
      tester,
      gifts: _FakeGiftRepository(
        given: [
          GiftEntry(
            id: 'g1',
            item: 'Tennis racket',
            giftDate: DateTime(2026, 6),
            isSurprise: false,
            counterpartLabel: 'Ali',
          ),
        ],
        received: [
          GiftEntry(
            id: 'r1',
            item: 'Board game',
            giftDate: DateTime(2026, 7),
            isSurprise: false,
          ),
        ],
      ),
    );

    expect(find.text('Tennis racket'), findsOneWidget);

    // Swipe left → Received page, segment follows.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Board game'), findsOneWidget);

    // Swipe right → back to Given.
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Tennis racket'), findsOneWidget);
  });

  const racketPreview = LinkPreview(
    id: 'lp-9',
    url: 'https://shop.example.com/racket',
    title: 'Babolat Pure Drive',
    price: '1.299,00 TL',
    site: 'shop.example.com',
  );

  testWidgets('log form attaches a fetched preview to the gift', (
    tester,
  ) async {
    final repo = _FakeGiftRepository();
    await pump(
      tester,
      gifts: repo,
      linkPreviews: _FakeLinkPreviewRepository(preview: racketPreview),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Who is it for?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ali').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Link (optional)'),
      'https://shop.example.com/racket',
    );
    await tester.pump(const Duration(milliseconds: 700)); // debounce
    await tester.pumpAndSettle();
    // Empty item field inherited the product title.
    expect(find.text('Babolat Pure Drive'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Reveal date'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reveal date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.lastLinkPreviewId, 'lp-9');
  });

  testWidgets('gift rows with a preview render its thumbnail info', (
    tester,
  ) async {
    await pump(
      tester,
      gifts: _FakeGiftRepository(
        given: [
          GiftEntry(
            id: 'g7',
            item: 'Babolat Pure Drive',
            giftDate: DateTime(2026, 8),
            isSurprise: false,
            counterpartLabel: 'Ali',
            preview: racketPreview,
          ),
        ],
      ),
    );

    expect(find.text('Babolat Pure Drive'), findsOneWidget);
    // Price surfaces as the row's trailing (new product-row design).
    expect(find.text('1.299,00 TL'), findsOneWidget);
  });

  testWidgets('received tab logs an external gift via the relation dropdown', (
    tester,
  ) async {
    final repo = _FakeGiftRepository();
    await pump(tester, gifts: repo);

    // Switch to Received; its empty state offers the external-gift CTA.
    await tester.tap(find.text('Received'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a gift you received'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('From'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dad').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Gift'),
      'Hand-knit scarf',
    );
    await scrollToAndTap(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.lastExternalRelation, GiftRelation.father);
    // Back on Received, the row shows the relation label, not a member name.
    expect(find.text('Hand-knit scarf'), findsOneWidget);
    expect(find.textContaining('Dad'), findsOneWidget);
  });

  testWidgets('external gift form requires a relation', (tester) async {
    final repo = _FakeGiftRepository();
    await pump(tester, gifts: repo, initial: '/gifts/log-external');

    await tester.enterText(find.widgetWithText(TextField, 'Gift'), 'Scarf');
    await scrollToAndTap(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text("Pick who it's from"), findsOneWidget);
    expect(repo.lastExternalRelation, isNull);
  });

  group('gift photos (G-204)', () {
    GiftEntry giftWithPhotos({
      required String id,
      required int count,
      String uploader = 'dev-me',
      String? giverId = 'dev-me',
      String? recipientId = 'ali',
    }) => GiftEntry(
      id: id,
      item: 'Kupa',
      giftDate: DateTime(2026, 9),
      isSurprise: false,
      counterpartId: 'ali',
      counterpartLabel: 'Ali',
      giverId: giverId,
      recipientId: recipientId,
      photos: [
        for (var i = 0; i < count; i++)
          GiftPhoto(
            id: 'p$i',
            giftId: id,
            uploaderId: uploader,
            mediaPath: '$uploader/$id-$i.jpg',
            createdAt: DateTime(2026, 9, 1, i),
          ),
      ],
    );

    testWidgets('gift rows show up to three thumbnails', (tester) async {
      await pump(
        tester,
        gifts: _FakeGiftRepository(given: [giftWithPhotos(id: 'g1', count: 2)]),
      );

      expect(find.byType(GiftPhotoStrip), findsOneWidget);
      expect(find.byType(PrivateMediaImage), findsNWidgets(2));
    });

    testWidgets('tapping a row opens the detail; a party can add photos', (
      tester,
    ) async {
      await pump(
        tester,
        gifts: _FakeGiftRepository(given: [giftWithPhotos(id: 'g1', count: 1)]),
      );

      await tester.tap(find.text('Kupa'));
      await tester.pumpAndSettle();

      expect(find.text('Gift'), findsOneWidget);
      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('No photos yet'), findsNothing);
      expect(find.text('Ali'), findsOneWidget);
      expect(find.textContaining('Gift date:'), findsOneWidget);
    });

    testWidgets('a bystander sees photos but cannot add', (tester) async {
      await pump(
        tester,
        gifts: _FakeGiftRepository(
          received: [
            giftWithPhotos(
              id: 'g2',
              count: 1,
              uploader: 'someone',
              giverId: 'someone',
              recipientId: 'other',
            ),
          ],
        ),
        initial: '/gifts/g2?side=giver',
      );

      expect(find.text('Take a photo'), findsNothing);
      // Not a party: the app bar ⋯ offers report (G-209)...
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      // ...and the gallery adds no remove affordance for someone else's photo.
      await tester.tap(find.byType(PrivateMediaImage).first);
      await tester.pumpAndSettle();
      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('gallery swipes across all photos', (tester) async {
      await pump(
        tester,
        gifts: _FakeGiftRepository(given: [giftWithPhotos(id: 'g6', count: 3)]),
        initial: '/gifts/g6?side=recipient',
      );

      await tester.tap(find.byType(PrivateMediaImage).at(1));
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('3 / 3'), findsOneWidget);

      // Pull down past the threshold → the gallery closes.
      await tester.drag(find.byType(PageView), const Offset(0, 260));
      await tester.pumpAndSettle();
      expect(find.text('3 / 3'), findsNothing);
      expect(find.text('Gift'), findsOneWidget);
    });

    testWidgets('a short pull springs the photo back', (tester) async {
      await pump(
        tester,
        gifts: _FakeGiftRepository(given: [giftWithPhotos(id: 'g7', count: 2)]),
        initial: '/gifts/g7?side=recipient',
      );
      await tester.tap(find.byType(PrivateMediaImage).first);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(PageView), const Offset(0, 60));
      await tester.pumpAndSettle();
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('the cap hides the add button', (tester) async {
      await pump(
        tester,
        gifts: _FakeGiftRepository(given: [giftWithPhotos(id: 'g3', count: 3)]),
        initial: '/gifts/g3?side=recipient',
      );

      expect(find.text('Take a photo'), findsNothing);
    });

    testWidgets('detail: capture attaches a photo to the gift', (tester) async {
      final repo = _FakeGiftRepository(
        given: [giftWithPhotos(id: 'g4', count: 0)],
      );
      await pump(
        tester,
        gifts: repo,
        initial: '/gifts/g4?side=recipient',
        picker: FakeImagePicker(tinyPng),
      );
      // A party sees the camera card instead of the empty placeholder.
      expect(find.text('No photos yet'), findsNothing);
      expect(find.byType(PrivateMediaImage), findsNothing);

      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();

      expect(repo.attachedTo, ['g4']);
      expect(find.byType(PrivateMediaImage), findsOneWidget);
    });

    testWidgets('uploader removes their own photo from the detail', (
      tester,
    ) async {
      final repo = _FakeGiftRepository(
        given: [giftWithPhotos(id: 'g5', count: 1)],
      );
      await pump(tester, gifts: repo, initial: '/gifts/g5?side=recipient');

      // Card → full-screen gallery → ⋯ → remove.
      await tester.tap(find.byType(PrivateMediaImage).first);
      await tester.pumpAndSettle();
      expect(find.text('1 / 1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();

      expect(repo.removed, ['p0']);
      expect(find.text('Photo removed'), findsOneWidget);
      expect(find.byType(PrivateMediaImage), findsNothing);
      expect(find.text('Take a photo'), findsOneWidget);
    });

    testWidgets('reacting from the detail sets, changes and clears', (
      tester,
    ) async {
      final repo = _FakeGiftRepository(
        given: [giftWithPhotos(id: 'g8', count: 0)],
      );
      await pump(tester, gifts: repo, initial: '/gifts/g8?side=recipient');
      expect(find.text('Reactions'), findsOneWidget);

      // Hold → picker → congrats.
      await tester.longPress(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      await tester.tap(find.text('🎉'));
      await tester.pumpAndSettle();
      expect(repo.reactions, ['set:g8:congrats']);
      expect(find.text('1'), findsOneWidget);

      // Tap on the reacted pill clears.
      await tester.tap(find.text('🎉'));
      await tester.pumpAndSettle();
      expect(repo.reactions.last, 'clear:g8');
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('comments: open the sheet, write, delete own', (tester) async {
      final repo = _FakeGiftRepository(
        given: [giftWithPhotos(id: 'g9', count: 0)],
      );
      await pump(tester, gifts: repo, initial: '/gifts/g9?side=recipient');

      await tester.tap(find.text('Write a comment…'));
      await tester.pumpAndSettle();
      expect(find.text('Comments'), findsOneWidget);
      expect(find.text('No comments yet. Say something.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Çok güzel!');
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();
      expect(find.text('Çok güzel!'), findsOneWidget);
      expect(repo.comments['g9'], hasLength(1));

      // Long-press own comment → delete.
      await tester.longPress(find.text('Çok güzel!'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete comment'));
      await tester.pumpAndSettle();
      expect(repo.comments['g9'], isEmpty);
      expect(find.text('No comments yet. Say something.'), findsOneWidget);
    });

    testWidgets('photos taken in the log form attach after save', (
      tester,
    ) async {
      final repo = _FakeGiftRepository();
      await pump(tester, gifts: repo, picker: FakeImagePicker(tinyPng));
      await tester.tap(find.text('Received'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add a gift you received'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('From'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dad').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Gift'), 'Saat');

      await scrollToAndTap(tester, find.text('Take a photo'));
      await scrollToAndTap(tester, find.text('Take a photo'));
      expect(find.byIcon(Icons.close), findsNWidgets(2));

      await scrollToAndTap(tester, find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.received.single.item, 'Saat');
      expect(repo.attachedTo, ['ext-1', 'ext-1']);
      expect(find.text('Gift logged'), findsOneWidget);
    });
  });
}
