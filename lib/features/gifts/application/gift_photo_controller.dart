import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gift_photo_controller.g.dart';

/// Gift photo pipeline (G-204): shots come from Kept's camera (G-407),
/// shared JPEG encoding, attach/remove through the repository. Used by both log forms (photos
/// taken before the gift exists are attached right after it is created)
/// and the detail screen.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
@Riverpod(keepAlive: true)
class GiftPhotoController extends _$GiftPhotoController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Encodes and attaches each capture in order. Returns how many landed;
  /// stops at the first failure so the error state is meaningful.
  Future<int> attach({
    required String giftId,
    required List<Uint8List> captures,
  }) async {
    if (captures.isEmpty) return 0;
    state = const AsyncLoading();
    final encode = ref.read(uploadEncoderProvider);
    final repository = ref.read(giftRepositoryProvider);
    var attached = 0;
    try {
      for (final bytes in captures) {
        final jpeg = await encode(bytes);
        final result = await repository.addPhoto(
          giftId: giftId,
          jpegBytes: jpeg,
        );
        result.when(
          success: (_) => attached++,
          failure: (Failure f) => throw f,
        );
      }
      state = const AsyncData(null);
    } on Failure catch (failure, stack) {
      debugPrint('gift photo attach failed: $failure');
      state = AsyncError(failure, stack);
    } catch (e, stack) {
      debugPrint('gift photo attach failed: $e');
      state = AsyncError(UnknownFailure(e.toString()), stack);
    }
    _refreshGiftSurfaces();
    return attached;
  }

  /// One photo with its note, kept with the gift — and, when the
  /// recipient asks, also out as a 24h unboxing story (G-308). The photo
  /// lands first (it is the permanent part); a story failure after that is
  /// reported as [GiftPhotoOutcome.storyFailed], not as a lost photo.
  Future<GiftPhotoOutcome> share({
    required String giftId,
    required Uint8List bytes,
    String? note,
    bool asStory = false,
  }) async {
    state = const AsyncLoading();
    final trimmed = note?.trim();
    final caption = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    try {
      final jpeg = await ref.read(uploadEncoderProvider)(bytes);
      final added = await ref
          .read(giftRepositoryProvider)
          .addPhoto(giftId: giftId, jpegBytes: jpeg, caption: caption);
      added.when(success: (_) => null, failure: (Failure f) => throw f);
      _refreshGiftSurfaces();
      if (!asStory) {
        state = const AsyncData(null);
        return GiftPhotoOutcome.saved;
      }
      final posted = await ref
          .read(feedRepositoryProvider)
          .createPost(jpegBytes: jpeg, caption: caption, giftId: giftId);
      final storyFailure = posted.when<Failure?>(
        success: (_) => null,
        failure: (f) => f,
      );
      if (storyFailure != null) {
        debugPrint('unboxing story failed: $storyFailure');
        state = AsyncError(storyFailure, StackTrace.current);
        return GiftPhotoOutcome.storyFailed;
      }
      ref.invalidate(storyGroupsProvider);
      state = const AsyncData(null);
      return GiftPhotoOutcome.shared;
    } on Failure catch (failure, stack) {
      debugPrint('gift photo share failed: $failure');
      state = AsyncError(failure, stack);
      return GiftPhotoOutcome.failed;
    } catch (e, stack) {
      debugPrint('gift photo share failed: $e');
      state = AsyncError(UnknownFailure(e.toString()), stack);
      return GiftPhotoOutcome.failed;
    }
  }

  Future<bool> remove(GiftPhoto photo) async {
    state = const AsyncLoading();
    final result = await ref.read(giftRepositoryProvider).removePhoto(photo);
    final ok = result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
    _refreshGiftSurfaces();
    return ok;
  }

  /// Photos show on every gift surface; invalidating all three lists plus the
  /// detail family is cheaper than tracking which one the caller came from.
  void _refreshGiftSurfaces() {
    ref
      ..invalidate(givenGiftsProvider)
      ..invalidate(receivedGiftsProvider)
      ..invalidate(friendGiftHistoryProvider)
      ..invalidate(giftDetailProvider);
  }
}

/// What came of [GiftPhotoController.share].
enum GiftPhotoOutcome {
  /// Photo kept with the gift; no story was asked for.
  saved,

  /// Photo kept and the unboxing story is live.
  shared,

  /// Photo kept, but the story did not go out.
  storyFailed,

  /// Nothing landed.
  failed,
}
