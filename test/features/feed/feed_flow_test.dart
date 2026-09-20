import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/app.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/data/dev_profile_repository.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feed_test_support.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpApp(
    WidgetTester tester, {
    required FakeFeedRepository feed,
    FakeImagePicker? picker,
    bool asDevMe = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedRepositoryProvider.overrideWithValue(feed),
          mediaStoreProvider.overrideWithValue(const FakeMediaStore()),
          imagePickerProvider.overrideWithValue(
            picker ?? FakeImagePicker(null),
          ),
          // Skip the isolate hop: fake async and compute don't mix.
          uploadEncoderProvider.overrideWithValue((bytes) async => bytes),
          if (asDevMe)
            profileRepositoryProvider.overrideWithValue(
              const DevProfileRepository(),
            ),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Route transition + first frames of the viewer, without settling the
  /// 5s auto-advance animation.
  Future<void> pumpViewer(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  List<Post> friendsPosts() => [
    samplePost(
      id: 'z1',
      authorId: 'zeynep',
      username: 'zeynep',
      displayName: 'Zeynep',
      caption: 'Yeni kupa!',
    ),
    samplePost(id: 'a1', authorId: 'ali', username: 'ali'),
  ];

  group('stories strip', () {
    testWidgets('empty feed shows the camera ring and a hint', (tester) async {
      await pumpApp(tester, feed: FakeFeedRepository());

      expect(find.text('Share a moment'), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera_outlined), findsWidgets);
      expect(
        find.text("Friends' moments show up here for 24 hours."),
        findsOneWidget,
      );
    });

    testWidgets('renders one ring per friend story', (tester) async {
      await pumpApp(tester, feed: FakeFeedRepository(posts: friendsPosts()));

      expect(find.text('Zeynep'), findsOneWidget);
      expect(find.text('ali'), findsOneWidget);
      expect(find.text('Share a moment'), findsOneWidget);
    });

    testWidgets('load failure shows an inline error with retry', (
      tester,
    ) async {
      final feed = FakeFeedRepository(failFetch: true);
      await pumpApp(tester, feed: feed);
      expect(find.text("Couldn't load moments"), findsOneWidget);

      feed.failFetch = false;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.text('Share a moment'), findsOneWidget);
    });
  });

  group('story viewer', () {
    testWidgets('tapping a ring opens the story with caption and author', (
      tester,
    ) async {
      await pumpApp(tester, feed: FakeFeedRepository(posts: friendsPosts()));

      await tester.tap(find.text('Zeynep'));
      await pumpViewer(tester);

      expect(find.text('Yeni kupa!'), findsOneWidget);
      expect(find.textContaining('Zeynep · Just now'), findsOneWidget);
      // No backend in tests → the private photo resolves to the fallback.
      expect(find.text('Photo unavailable'), findsOneWidget);
      // A friend's story: ⋯ offers report, not delete (G-209).
      await tester.tap(find.byIcon(Icons.more_horiz));
      await pumpViewer(tester);
      expect(find.text('Report'), findsOneWidget);
      expect(find.text('Delete moment'), findsNothing);
      await tester.tap(find.text('Cancel'));
      await pumpViewer(tester);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('pulling the story down closes it', (tester) async {
      await pumpApp(tester, feed: FakeFeedRepository(posts: friendsPosts()));
      await tester.tap(find.text('Zeynep'));
      await pumpViewer(tester);
      expect(find.text('Yeni kupa!'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(0, 260));
      await tester.pumpAndSettle();

      expect(find.text('Yeni kupa!'), findsNothing);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('watched stories are remembered locally', (tester) async {
      await pumpApp(tester, feed: FakeFeedRepository(posts: friendsPosts()));

      await tester.tap(find.text('ali'));
      await pumpViewer(tester);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('seen_post_ids'), ['a1']);
    });

    testWidgets('owner can delete a moment from the viewer', (tester) async {
      final feed = FakeFeedRepository(
        viewerId: 'dev-me',
        posts: [
          samplePost(
            id: 'mine',
            authorId: 'dev-me',
            username: 'you',
            caption: 'benim',
          ),
        ],
      );
      await pumpApp(tester, feed: feed, asDevMe: true);
      expect(find.text('You'), findsOneWidget);

      await tester.tap(find.text('You'));
      await pumpViewer(tester);
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete moment'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this moment?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete moment'));
      await tester.pumpAndSettle();

      expect(feed.deleted, ['mine']);
      expect(find.text('Moment deleted'), findsOneWidget);
      // Back on Home with no own story left → camera ring again.
      expect(find.text('Share a moment'), findsOneWidget);
    });
  });

  group('reactions (G-206)', () {
    testWidgets('a friend reacts, changes and clears from the bar', (
      tester,
    ) async {
      final feed = FakeFeedRepository(
        viewerId: 'dev-me',
        posts: friendsPosts(),
      );
      await pumpApp(tester, feed: feed, asDevMe: true);
      await tester.tap(find.text('Zeynep'));
      await pumpViewer(tester);

      // Single pill, nothing chosen yet: heart outline, no picker.
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('🎉'), findsNothing);

      // Tap = heart.
      await tester.tap(find.byIcon(Icons.favorite_border));
      await pumpViewer(tester);
      expect(feed.reactions, ['set:z1:heart']);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Hold → picker → pick another kind.
      await tester.longPress(find.text('❤️'));
      await pumpViewer(tester);
      expect(find.text('🎉'), findsOneWidget);
      await tester.tap(find.text('🎉'));
      await pumpViewer(tester);
      expect(feed.reactions.last, 'set:z1:congrats');
      expect(find.text('🎉'), findsOneWidget);

      // Tap on the pill while reacted clears it.
      await tester.tap(find.text('🎉'));
      await pumpViewer(tester);
      expect(feed.reactions.last, 'clear:z1');
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('the comment pill opens the sheet and posts', (tester) async {
      final feed = FakeFeedRepository(
        viewerId: 'dev-me',
        posts: friendsPosts(),
      );
      await pumpApp(tester, feed: feed, asDevMe: true);
      await tester.tap(find.text('Zeynep'));
      await pumpViewer(tester);

      await tester.tap(find.text('Write a comment…'));
      await pumpViewer(tester);
      expect(find.text('Comments'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'harika');
      await tester.tap(find.byTooltip('Send'));
      await pumpViewer(tester);
      expect(feed.comments['z1']?.single.body, 'harika');
      expect(find.text('harika'), findsOneWidget);
    });

    testWidgets('the author sees a summary and who reacted', (tester) async {
      final feed = FakeFeedRepository(
        viewerId: 'dev-me',
        posts: [
          samplePost(
            id: 'mine',
            authorId: 'dev-me',
            username: 'you',
            reactions: const [
              Reaction(
                userId: 'ali',
                kind: ReactionKind.heart,
                user: ProfileCard(
                  id: 'ali',
                  username: 'ali',
                  displayName: 'Ali',
                ),
              ),
              Reaction(
                userId: 'zeynep',
                kind: ReactionKind.heart,
                user: ProfileCard(id: 'zeynep', username: 'zeynep'),
              ),
              Reaction(
                userId: 'mert',
                kind: ReactionKind.wow,
                user: ProfileCard(id: 'mert', username: 'mert'),
              ),
            ],
          ),
        ],
      );
      await pumpApp(tester, feed: feed, asDevMe: true);
      await tester.tap(find.text('You'));
      await pumpViewer(tester);

      expect(find.text('❤️😮 3'), findsOneWidget);
      // No reaction pill on your own moment.
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      // Short pumps: settling would run the 5s auto-advance under the sheet.
      await tester.tap(find.text('❤️😮 3'));
      await pumpViewer(tester);
      expect(find.text('Reactions'), findsOneWidget);
      expect(find.text('Ali'), findsOneWidget);
      expect(find.text('zeynep'), findsOneWidget);
      expect(find.text('mert'), findsOneWidget);
    });
  });

  group('capture + compose', () {
    testWidgets('Add tab opens the camera; backing out does nothing', (
      tester,
    ) async {
      final picker = FakeImagePicker(null);
      await pumpApp(tester, feed: FakeFeedRepository(), picker: picker);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(picker.calls, 1);
      expect(picker.lastSource, ImageSource.camera);
      expect(find.text('New moment'), findsNothing);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('a captured photo is shared with its caption', (tester) async {
      final feed = FakeFeedRepository(viewerId: 'me');
      await pumpApp(tester, feed: feed, picker: FakeImagePicker(tinyPng));

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('New moment'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '  Yeni kupa  ');
      await tester.tap(find.widgetWithText(FilledButton, 'Share'));
      await tester.pumpAndSettle();

      expect(feed.created.single.caption, 'Yeni kupa');
      expect(feed.created.single.bytes, tinyPng);
      expect(find.text('Shared. Gone in 24 hours.'), findsOneWidget);
      expect(find.text('New moment'), findsNothing);
    });

    testWidgets('the camera ring in the strip also captures', (tester) async {
      final feed = FakeFeedRepository(viewerId: 'me');
      await pumpApp(tester, feed: feed, picker: FakeImagePicker(tinyPng));

      await tester.tap(find.text('Share a moment'));
      await tester.pumpAndSettle();

      expect(find.text('New moment'), findsOneWidget);
    });

    testWidgets('share failure keeps the compose screen with a message', (
      tester,
    ) async {
      final feed = FakeFeedRepository(viewerId: 'me', failCreate: true);
      await pumpApp(tester, feed: feed, picker: FakeImagePicker(tinyPng));

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Share'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't share. Try again."), findsOneWidget);
      expect(find.text('New moment'), findsOneWidget);
    });

    testWidgets('caption is capped at 140 characters', (tester) async {
      await pumpApp(
        tester,
        feed: FakeFeedRepository(viewerId: 'me'),
        picker: FakeImagePicker(tinyPng),
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'x' * 200);
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text.length, 140);
      expect(find.text('140/140'), findsOneWidget);
    });
  });

  test('toUploadJpeg produces a jpeg from any decodable input', () {
    final out = toUploadJpeg(tinyPng);
    // JPEG SOI marker.
    expect(out[0], 0xFF);
    expect(out[1], 0xD8);
  });
}
