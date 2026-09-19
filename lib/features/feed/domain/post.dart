import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kept/features/feed/domain/reaction.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

part 'post.freezed.dart';
part 'post.g.dart';

/// One ephemeral moment (G-202): a photo in the private `posts` bucket plus
/// an optional caption, visible until [expiresAt] (server-owned, 24h).
@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'media_path') required String mediaPath,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    required ProfileCard author,
    String? caption,
    @Default([]) List<Reaction> reactions,
  }) = _Post;

  const Post._();

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  /// The viewer's own reaction, if any (one per user per moment).
  ReactionKind? reactionOf(String? userId) =>
      reactions.where((r) => r.userId == userId).firstOrNull?.kind;

  /// Per-kind counts, insertion-ordered by [ReactionKind] declaration.
  Map<ReactionKind, int> get reactionCounts => {
    for (final kind in ReactionKind.values)
      if (reactions.any((r) => r.kind == kind))
        kind: reactions.where((r) => r.kind == kind).length,
  };
}

/// Storage bucket that holds post photos (private; read via a live post row).
const String postsBucket = 'posts';

/// Caption cap — mirrors the `posts_caption_len` CHECK.
const int postCaptionMaxLength = 140;
