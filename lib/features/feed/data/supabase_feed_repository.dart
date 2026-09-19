import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:kept/features/feed/domain/feed_repository.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/feed/domain/reaction.dart';
import 'package:kept/features/feed/domain/story_group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [FeedRepository].
///
/// Reads lean on RLS (`expires_at > now()` + profile visibility); the author
/// card is embedded through the posts→profiles FK. Writes own the two-step
/// storage + row transaction so callers see one result.
class SupabaseFeedRepository implements FeedRepository {
  SupabaseFeedRepository(this._client, this._media);

  final SupabaseClient _client;
  final MediaStore _media;

  /// A friend graph's 24h output is small; this is a safety cap, not paging.
  static const _fetchLimit = 200;

  static const _selectColumns =
      'id, author_id, media_path, caption, created_at, expires_at, '
      // FK hint is mandatory: post_reactions links posts↔profiles too, so a
      // bare `profiles` embed is ambiguous (PGRST201) since G-206.
      'author:profiles!posts_author_id_fkey'
      '(id, username, display_name, avatar_url), '
      'reactions:post_reactions(user_id, kind, '
      'user:profiles(id, username, display_name, avatar_url))';

  @override
  Future<Result<FeedSnapshot>> fetchActive() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final rows = await _client
          .from('posts')
          .select(_selectColumns)
          .order('created_at', ascending: true)
          .limit(_fetchLimit);
      final posts = rows.map(Post.fromJson).toList();
      return Success(FeedSnapshot(posts: posts, viewerId: userId));
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> createPost({
    required Uint8List jpegBytes,
    String? caption,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));

    final path = '$userId/post-${DateTime.now().microsecondsSinceEpoch}.jpg';
    final uploaded = await _media.upload(
      bucket: postsBucket,
      path: path,
      bytes: jpegBytes,
      contentType: 'image/jpeg',
    );
    final failure = uploaded.when<Failure?>(
      success: (_) => null,
      failure: (f) => f,
    );
    if (failure != null) return ResultFailure(failure);

    try {
      await _client.from('posts').insert({
        'author_id': userId,
        'media_path': path,
        if (caption != null && caption.isNotEmpty) 'caption': caption,
      });
      return const Success(null);
    } on PostgrestException catch (e) {
      // The row is the source of truth; an object without one is invisible
      // to everyone and unreachable by the purge, so roll it back now.
      await _media.delete(bucket: postsBucket, path: path);
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      await _media.delete(bucket: postsBucket, path: path);
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePost(Post post) async {
    try {
      // Photo first: if the row delete then fails the post still expires and
      // the purge converges (removing a missing object is not an error).
      await _media.delete(bucket: postsBucket, path: post.mediaPath);
      await _client.from('posts').delete().eq('id', post.id);
      return const Success(null);
    } on PostgrestException catch (e) {
      debugPrint('post delete failed (${post.id}): ${e.message}');
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setReaction(String postId, ReactionKind kind) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      // PK (post_id, user_id): a second reaction becomes a kind change.
      await _client.from('post_reactions').upsert({
        'post_id': postId,
        'user_id': userId,
        'kind': kind.name,
      });
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearReaction(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client
          .from('post_reactions')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
