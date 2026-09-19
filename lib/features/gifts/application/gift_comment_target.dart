import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';
import 'package:kept/shared/domain/comment.dart';

/// Comments on one gift, backed by the gift repository. [onChanged] lets
/// the caller refresh the gift surfaces after a write (counts stay honest).
class GiftCommentTarget implements CommentTarget {
  const GiftCommentTarget(
    this._repository,
    this.gift, {
    required this.onChanged,
  });

  final GiftRepository _repository;
  final GiftEntry gift;
  final VoidCallback onChanged;

  @override
  String get key => 'gift:${gift.id}';

  @override
  bool canDelete(Comment comment, String? viewerId) =>
      viewerId != null &&
      (comment.authorId == viewerId || gift.isParty(viewerId));

  @override
  Future<List<Comment>> load() async {
    final result = await _repository.fetchComments(gift.id);
    return result.when(success: (c) => c, failure: (Failure f) => throw f);
  }

  @override
  Future<void> add(String body) async {
    final result = await _repository.addComment(gift.id, body);
    result.when(success: (_) => onChanged(), failure: (Failure f) => throw f);
  }

  @override
  Future<void> remove(Comment comment) async {
    final result = await _repository.deleteComment(comment.id);
    result.when(success: (_) => onChanged(), failure: (Failure f) => throw f);
  }
}
