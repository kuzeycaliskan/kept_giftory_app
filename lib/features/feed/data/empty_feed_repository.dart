import 'dart:typed_data';

import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/feed/domain/feed_repository.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/feed/domain/story_group.dart';
import 'package:kept/shared/domain/reaction.dart';

/// Backend-less runs (no --dart-define config): an empty, read-only feed so
/// Home renders without a Supabase instance.
class EmptyFeedRepository implements FeedRepository {
  const EmptyFeedRepository();

  @override
  Future<Result<FeedSnapshot>> fetchActive() async =>
      const Success(FeedSnapshot(posts: [], viewerId: null));

  @override
  Future<Result<void>> createPost({
    required Uint8List jpegBytes,
    String? caption,
  }) async => const ResultFailure(NetworkFailure('No backend configured'));

  @override
  Future<Result<void>> deletePost(Post post) async =>
      const ResultFailure(NetworkFailure('No backend configured'));

  @override
  Future<Result<void>> setReaction(String postId, ReactionKind kind) async =>
      const ResultFailure(NetworkFailure('No backend configured'));

  @override
  Future<Result<void>> clearReaction(String postId) async =>
      const ResultFailure(NetworkFailure('No backend configured'));
}
