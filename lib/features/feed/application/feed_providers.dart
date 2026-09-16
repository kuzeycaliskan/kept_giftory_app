import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/core/prefs/prefs_providers.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/feed/data/empty_feed_repository.dart';
import 'package:kept/features/feed/data/supabase_feed_repository.dart';
import 'package:kept/features/feed/domain/feed_repository.dart';
import 'package:kept/features/feed/domain/story_group.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_providers.g.dart';

@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyFeedRepository();
  return SupabaseFeedRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(mediaStoreProvider),
  );
}

/// Platform image picker behind a provider so tests can hand the shell a
/// fake camera.
@Riverpod(keepAlive: true)
ImagePicker imagePicker(Ref ref) => ImagePicker();

/// The strip's data: live posts grouped per author, viewer first.
@riverpod
Future<List<StoryGroup>> storyGroups(Ref ref) async {
  final result = await ref.watch(feedRepositoryProvider).fetchActive();
  final snapshot = result.when(
    success: (s) => s,
    failure: (failure) => throw failure,
  );
  final groups = groupStories(snapshot);
  // Forget seen-markers of posts that are gone so the local set stays tiny.
  ref.read(seenPostsProvider.notifier).retain({
    for (final p in snapshot.posts) p.id,
  });
  return groups;
}

/// Device-local "already watched" markers (ring colour in the strip). Purely
/// a UI nicety, so it lives in preferences, not Postgres.
@Riverpod(keepAlive: true)
class SeenPosts extends _$SeenPosts {
  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    return {...?prefs?.getStringList(PrefKeys.seenPostIds)};
  }

  void markSeen(String postId) {
    if (state.contains(postId)) return;
    state = {...state, postId};
    _persist();
  }

  /// Drops ids that are no longer in the feed (expired or deleted).
  void retain(Set<String> liveIds) {
    final kept = state.intersection(liveIds);
    if (kept.length == state.length) return;
    state = kept;
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider).valueOrNull;
    prefs?.setStringList(PrefKeys.seenPostIds, state.toList());
  }
}
