import 'package:flutter_test/flutter_test.dart';
import 'package:kept/features/feed/domain/story_group.dart';

import 'feed_test_support.dart';

void main() {
  final t0 = DateTime(2026, 9, 16, 10);

  test('groups by author, viewer first, then most recent story', () {
    final posts = [
      samplePost(id: 'a1', authorId: 'ali', username: 'ali', createdAt: t0),
      samplePost(
        id: 'z1',
        authorId: 'zeynep',
        username: 'zeynep',
        createdAt: t0.add(const Duration(hours: 2)),
      ),
      samplePost(
        id: 'me1',
        authorId: 'me',
        username: 'you',
        createdAt: t0.subtract(const Duration(hours: 5)),
      ),
      samplePost(
        id: 'a2',
        authorId: 'ali',
        username: 'ali',
        createdAt: t0.add(const Duration(hours: 3)),
      ),
    ];

    final groups = groupStories(FeedSnapshot(posts: posts, viewerId: 'me'));

    expect(groups.map((g) => g.author.id), ['me', 'ali', 'zeynep']);
    expect(groups[1].posts.map((p) => p.id), ['a1', 'a2']);
  });

  test('posts inside a story play oldest to newest', () {
    final posts = [
      samplePost(
        id: 'late',
        authorId: 'ali',
        username: 'ali',
        createdAt: t0.add(const Duration(minutes: 30)),
      ),
      samplePost(id: 'early', authorId: 'ali', username: 'ali', createdAt: t0),
    ];

    final groups = groupStories(FeedSnapshot(posts: posts, viewerId: null));

    expect(groups.single.posts.map((p) => p.id), ['early', 'late']);
    expect(groups.single.latestAt, t0.add(const Duration(minutes: 30)));
  });

  test('a story is unseen until every post was watched', () {
    final group = groupStories(
      FeedSnapshot(
        posts: [
          samplePost(id: 'p1', authorId: 'ali', username: 'ali'),
          samplePost(id: 'p2', authorId: 'ali', username: 'ali'),
        ],
        viewerId: null,
      ),
    ).single;

    expect(group.hasUnseen(const {}), isTrue);
    expect(group.hasUnseen(const {'p1'}), isTrue);
    expect(group.hasUnseen(const {'p1', 'p2'}), isFalse);
  });

  test('empty feed produces no groups', () {
    expect(
      groupStories(const FeedSnapshot(posts: [], viewerId: 'me')),
      isEmpty,
    );
  });
}
