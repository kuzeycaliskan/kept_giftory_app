import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/media/camera/camera_backend.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:kept/features/feed/domain/feed_repository.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/feed/domain/story_group.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/shared/domain/comment.dart';
import 'package:kept/shared/domain/reaction.dart';

/// 1×1 transparent PNG — enough for Image.memory and the identity encoder.
final Uint8List tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

Post samplePost({
  required String id,
  required String authorId,
  required String username,
  String? displayName,
  String? caption,
  DateTime? createdAt,
  List<Reaction> reactions = const [],
  String? giftId,
  UnboxedGift? gift,
}) {
  final created = createdAt ?? DateTime.now();
  return Post(
    reactions: reactions,
    giftId: giftId,
    gift: gift,
    id: id,
    authorId: authorId,
    mediaPath: '$authorId/post-$id.jpg',
    caption: caption,
    createdAt: created,
    expiresAt: created.add(const Duration(hours: 24)),
    author: ProfileCard(
      id: authorId,
      username: username,
      displayName: displayName,
    ),
  );
}

class FakeFeedRepository implements FeedRepository {
  FakeFeedRepository({
    List<Post> posts = const [],
    this.viewerId,
    this.failCreate = false,
    this.failFetch = false,
  }) : posts = [...posts];

  List<Post> posts;
  final String? viewerId;
  bool failCreate;
  bool failFetch;
  final created = <({Uint8List bytes, String? caption, String? giftId})>[];
  final deleted = <String>[];

  @override
  Future<Result<FeedSnapshot>> fetchActive() async => failFetch
      ? const ResultFailure(NetworkFailure('offline'))
      : Success(FeedSnapshot(posts: posts, viewerId: viewerId));

  @override
  Future<Result<void>> createPost({
    required Uint8List jpegBytes,
    String? caption,
    String? giftId,
  }) async {
    if (failCreate) return const ResultFailure(NetworkFailure('upload'));
    created.add((bytes: jpegBytes, caption: caption, giftId: giftId));
    final id = 'new-${created.length}';
    posts.add(
      samplePost(
        id: id,
        authorId: viewerId ?? 'me',
        username: 'you',
        caption: caption,
      ),
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> deletePost(Post post) async {
    deleted.add(post.id);
    posts.removeWhere((p) => p.id == post.id);
    return const Success(null);
  }

  final reactions = <String>[];
  final comments = <String, List<Comment>>{};

  @override
  Future<Result<List<Comment>>> fetchComments(String postId) async =>
      Success(comments[postId] ?? const []);

  @override
  Future<Result<Comment>> addComment(String postId, String body) async {
    final c = Comment(
      id: 'c${(comments[postId]?.length ?? 0) + 1}',
      authorId: viewerId ?? 'me',
      body: body,
      createdAt: DateTime.now(),
    );
    comments.putIfAbsent(postId, () => []).add(c);
    return Success(c);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    for (final list in comments.values) {
      list.removeWhere((c) => c.id == commentId);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> setReaction(String postId, ReactionKind kind) async {
    reactions.add('set:$postId:${kind.name}');
    final i = posts.indexWhere((p) => p.id == postId);
    if (i >= 0) {
      final others = posts[i].reactions.where((r) => r.userId != viewerId);
      posts[i] = posts[i].copyWith(
        reactions: [
          ...others,
          Reaction(userId: viewerId ?? 'me', kind: kind),
        ],
      );
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> clearReaction(String postId) async {
    reactions.add('clear:$postId');
    final i = posts.indexWhere((p) => p.id == postId);
    if (i >= 0) {
      posts[i] = posts[i].copyWith(
        reactions: posts[i].reactions
            .where((r) => r.userId != viewerId)
            .toList(),
      );
    }
    return const Success(null);
  }
}

/// Camera stand-in: returns [bytes] once (null = user backed out).
class FakeImagePicker extends ImagePicker {
  FakeImagePicker(this.bytes);

  final Uint8List? bytes;
  int calls = 0;
  ImageSource? lastSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls++;
    lastSource = source;
    final b = bytes;
    return b == null ? null : XFile.fromData(b, name: 'shot.png');
  }

  @override
  Future<LostDataResponse> retrieveLostData() async => LostDataResponse.empty();
}

/// No backend in widget tests: private objects resolve to "unavailable".
class FakeMediaStore implements MediaStore {
  const FakeMediaStore();

  @override
  Future<Result<String>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async => Success(path);

  @override
  Future<void> delete({required String bucket, required String path}) async {}

  @override
  String publicUrl({required String bucket, required String path}) =>
      'https://example.invalid/$bucket/$path';

  @override
  PrivateMediaSource? privateSource({
    required String bucket,
    required String path,
  }) => null;
}

/// Kept's camera (G-407) with a canned shot: records what the screen asked
/// for so tests can assert on lens, flash and how often it opened.
class FakeCameraBackend implements CameraBackend {
  FakeCameraBackend(
    this.shot, {
    List<CameraLens> lenses = const [CameraLens.back, CameraLens.front],
    this.denied = false,
  }) : available = lenses;

  final Uint8List? shot;
  final List<CameraLens> available;
  final bool denied;
  int opened = 0;
  final openedLenses = <CameraLens>[];
  final flashes = <CameraFlash>[];

  @override
  Future<List<CameraLens>> lenses() async {
    if (available.isEmpty) throw const CameraUnavailable('none');
    return available;
  }

  @override
  Future<CameraSession> open(CameraLens lens) async {
    if (denied) throw const CameraPermissionDenied();
    opened++;
    openedLenses.add(lens);
    return _FakeSession(this, lens);
  }
}

class _FakeSession implements CameraSession {
  _FakeSession(this.backend, this.lens);

  final FakeCameraBackend backend;
  @override
  final CameraLens lens;

  @override
  Widget preview() =>
      const ColoredBox(key: Key('fake-camera-preview'), color: Colors.black);

  @override
  Future<void> setFlash(CameraFlash mode) async => backend.flashes.add(mode);

  @override
  Future<Uint8List> takePhoto() async {
    final bytes = backend.shot;
    if (bytes == null) throw StateError('no shot');
    return bytes;
  }

  @override
  Future<void> dispose() async {}
}

/// Drives Kept's camera screen like a user: shutter, then "Use photo".
Future<void> snap(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('camera-shutter')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Use photo'));
  await tester.pumpAndSettle();
}
