import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/features/feed/domain/feed_repository.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/shared/domain/comment.dart';

/// Comments on one moment, backed by the feed repository.
class PostCommentTarget implements CommentTarget {
  const PostCommentTarget(
    this._repository,
    this.post, {
    required this.onChanged,
  });

  final FeedRepository _repository;
  final Post post;
  final VoidCallback onChanged;

  @override
  String get key => 'post:${post.id}';

  @override
  bool canDelete(Comment comment, String? viewerId) =>
      viewerId != null &&
      (comment.authorId == viewerId || post.authorId == viewerId);

  @override
  Future<List<Comment>> load() async {
    final result = await _repository.fetchComments(post.id);
    return result.when(success: (c) => c, failure: (Failure f) => throw f);
  }

  @override
  Future<void> add(String body) async {
    final result = await _repository.addComment(post.id, body);
    result.when(success: (_) => onChanged(), failure: (Failure f) => throw f);
  }

  @override
  Future<void> remove(Comment comment) async {
    final result = await _repository.deleteComment(comment.id);
    result.when(success: (_) => onChanged(), failure: (Failure f) => throw f);
  }
}
