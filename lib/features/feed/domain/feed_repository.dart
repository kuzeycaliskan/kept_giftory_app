import 'dart:typed_data';

import 'package:kept/core/error/result.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/feed/domain/story_group.dart';
import 'package:kept/shared/domain/reaction.dart';

/// Ephemeral feed boundary (G-201/202). Visibility and expiry are enforced
/// by RLS — the repository never filters on them client-side.
abstract interface class FeedRepository {
  /// Every post the viewer may currently see, plus the viewer's id.
  Future<Result<FeedSnapshot>> fetchActive();

  /// Stores an already-encoded JPEG and creates its post row. Storage and row
  /// are one logical write: a failed row insert removes the uploaded object.
  Future<Result<void>> createPost({
    required Uint8List jpegBytes,
    String? caption,
  });

  /// Removes the author's own post (photo first, then the row).
  Future<Result<void>> deletePost(Post post);

  /// Sets (or changes) the viewer's reaction on a moment — one per user.
  Future<Result<void>> setReaction(String postId, ReactionKind kind);

  /// Removes the viewer's reaction on a moment.
  Future<Result<void>> clearReaction(String postId);
}
