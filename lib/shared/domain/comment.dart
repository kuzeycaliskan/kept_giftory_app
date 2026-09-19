import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

/// Comment cap — mirrors the `body` CHECK on both comment tables.
const int commentMaxLength = 500;

/// One comment on a gift or a moment. [user] resolves through the
/// discovery-card RPC so the author is always named.
@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required String body,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    ProfileCard? user,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}

/// What a comments sheet needs from a feature: how to load, add and remove
/// comments on one target, and who may delete which. Implemented by the
/// gift and moment features over their own repositories.
abstract interface class CommentTarget {
  /// Stable key for caching/providers (e.g. 'gift:<id>').
  String get key;

  /// Can the viewer delete [comment]? (author, or the item's owner)
  bool canDelete(Comment comment, String? viewerId);

  Future<List<Comment>> load();
  Future<void> add(String body);
  Future<void> remove(Comment comment);
}
