import 'package:freezed_annotation/freezed_annotation.dart';
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
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

/// Storage bucket that holds post photos (private; read via a live post row).
const String postsBucket = 'posts';

/// Caption cap — mirrors the `posts_caption_len` CHECK.
const int postCaptionMaxLength = 140;
