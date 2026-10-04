import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_composer.g.dart';

/// Share pipeline for a moment (G-201): the shot comes from Kept's camera
/// (G-407, never the gallery — a moment is taken now); [publish] shrinks +
/// stores.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
@Riverpod(keepAlive: true)
class PostComposer extends _$PostComposer {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Encodes and shares. Returns true when the moment is live. (An
  /// unboxing story is posted by the gift photo pipeline instead — G-308.)
  Future<bool> publish({required Uint8List bytes, String? caption}) async {
    state = const AsyncLoading();
    try {
      final jpeg = await ref.read(uploadEncoderProvider)(bytes);
      final trimmed = caption?.trim();
      final result = await ref
          .read(feedRepositoryProvider)
          .createPost(
            jpegBytes: jpeg,
            caption: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
          );
      result.when(success: (_) => null, failure: (Failure f) => throw f);
      ref.invalidate(storyGroupsProvider);
      state = const AsyncData(null);
      return true;
    } on Failure catch (failure, stack) {
      debugPrint('moment publish failed (failure): $failure');
      state = AsyncError(failure, stack);
      return false;
    } catch (e, stack) {
      debugPrint('moment publish failed: $e');
      state = AsyncError(UnknownFailure(e.toString()), stack);
      return false;
    }
  }
}
