import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/shared/domain/reaction.dart';

part 'post.freezed.dart';
part 'post.g.dart';

/// One ephemeral moment (G-202): a photo in the private `posts` bucket plus
/// an optional caption, visible until [expiresAt] (server-owned, 24h).
@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'media_path') required String mediaPath,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    required ProfileCard author,
    String? caption,
    @Default([]) List<Reaction> reactions,
    @Default(0) int commentCount,

    /// G-308: the received gift this moment unboxes, if any.
    @JsonKey(name: 'gift_id') String? giftId,

    /// The gift as the viewer may see it — null when RLS hides it even
    /// though [giftId] is set (then the tag says "unboxing", nothing more).
    UnboxedGift? gift,
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

/// What an unboxing moment shows about its gift (G-308): the item and who
/// gave it. Follows gifts RLS, so a hidden gift simply never arrives here.
@freezed
abstract class UnboxedGift with _$UnboxedGift {
  const factory UnboxedGift({
    required String id,
    required String item,
    ProfileCard? giver,
  }) = _UnboxedGift;

  factory UnboxedGift.fromJson(Map<String, dynamic> json) =>
      _$UnboxedGiftFromJson(json);
}

/// Storage bucket that holds post photos (private; read via a live post row).
const String postsBucket = 'posts';

/// Caption cap — mirrors the `posts_caption_len` CHECK.
const int postCaptionMaxLength = 140;
