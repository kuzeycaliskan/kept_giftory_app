import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/features/events/domain/events_repository.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/shared/domain/comment.dart';

/// The event notes board behind the shared comments sheet. Organizers may
/// remove any note; everyone removes their own.
class EventCommentTarget implements CommentTarget {
  const EventCommentTarget(
    this._repository,
    this.event, {
    required this.onChanged,
  });

  final EventsRepository _repository;
  final GiftEvent event;
  final VoidCallback onChanged;

  @override
  String get key => 'event:${event.id}';

  @override
  bool canDelete(Comment comment, String? viewerId) =>
      viewerId != null &&
      (comment.authorId == viewerId || event.isOrganizer(viewerId));

  @override
  Future<List<Comment>> load() async {
    final result = await _repository.fetchComments(event.id);
    return result.when(success: (c) => c, failure: (Failure f) => throw f);
  }

  @override
  Future<void> add(String body) async {
    final result = await _repository.addComment(event.id, body);
    result.when(success: (_) => onChanged(), failure: (Failure f) => throw f);
  }

  @override
  Future<void> remove(Comment comment) async {
    final result = await _repository.deleteComment(comment.id);
    result.when(success: (_) => onChanged(), failure: (Failure f) => throw f);
  }
}
