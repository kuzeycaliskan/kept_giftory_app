import 'package:flutter/foundation.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

/// One author's live moments, oldest first — a "story" in the strip.
@immutable
class StoryGroup {
  const StoryGroup({required this.author, required this.posts})
    : assert(posts.length > 0, 'a story group needs at least one post');

  final ProfileCard author;
  final List<Post> posts;

  DateTime get latestAt => posts.last.createdAt;

  /// True when at least one post is not in [seenIds].
  bool hasUnseen(Set<String> seenIds) =>
      posts.any((p) => !seenIds.contains(p.id));
}

/// Everything the strip needs in one read: the visible posts and who is
/// looking (so the viewer's own story sorts first).
@immutable
class FeedSnapshot {
  const FeedSnapshot({required this.posts, required this.viewerId});

  final List<Post> posts;
  final String? viewerId;
}

/// Groups posts by author: the viewer's own story first, then friends by
/// most recent post. Posts inside a group run oldest → newest so the viewer
/// plays them in order.
List<StoryGroup> groupStories(FeedSnapshot snapshot) {
  final byAuthor = <String, List<Post>>{};
  for (final post in snapshot.posts) {
    byAuthor.putIfAbsent(post.authorId, () => []).add(post);
  }
  final groups = [
    for (final posts in byAuthor.values)
      StoryGroup(
        author: posts.first.author,
        posts: [...posts]..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      ),
  ]..sort((a, b) => b.latestAt.compareTo(a.latestAt));

  final ownIndex = groups.indexWhere((g) => g.author.id == snapshot.viewerId);
  if (ownIndex > 0) groups.insert(0, groups.removeAt(ownIndex));
  return groups;
}
