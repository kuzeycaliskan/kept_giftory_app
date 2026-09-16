import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_actions.g.dart';

/// Owner actions on a live moment (currently: delete). Kept apart from the
/// composer so the viewer doesn't drag the capture pipeline in.
@riverpod
class PostActions extends _$PostActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Removes one of the viewer's own posts. Returns true when it is gone.
  Future<bool> delete(Post post) async {
    state = const AsyncLoading();
    final result = await ref.read(feedRepositoryProvider).deletePost(post);
    return result.when(
      success: (_) {
        ref.invalidate(storyGroupsProvider);
        state = const AsyncData(null);
        return true;
      },
      failure: (Failure failure) {
        debugPrint('post delete failed: $failure');
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}
