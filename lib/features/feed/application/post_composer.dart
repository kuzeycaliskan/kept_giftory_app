import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/gifts/application/gift_photo_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_composer.g.dart';

/// Capture → share pipeline for a moment (G-201). Two steps so the compose
/// screen sits between them: [capture] opens the device camera (never the
/// gallery — a moment is taken now), [publish] shrinks + stores.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
@Riverpod(keepAlive: true)
class PostComposer extends _$PostComposer {
  /// Camera output is requested large enough that the shared downscale
  /// (core/media/image_encoding) never upsamples.
  static const _captureDimension = 1600.0;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Opens the camera and returns the raw bytes (null = user backed out).
  Future<Uint8List?> capture() async {
    final picker = ref.read(imagePickerProvider);
    var picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _captureDimension,
      maxHeight: _captureDimension,
      requestFullMetadata: false,
    );
    // Android may recycle our activity behind the camera; the shot then
    // surfaces through retrieveLostData on resume.
    if (picked == null && defaultTargetPlatform == TargetPlatform.android) {
      final lost = await picker.retrieveLostData();
      picked = lost.file;
    }
    if (picked == null) {
      debugPrint('moment capture cancelled or lost');
      return null;
    }
    return picked.readAsBytes();
  }

  /// Encodes and shares. Returns true when the moment is live. An unboxing
  /// ([giftId]) also keeps the photo with the gift's memories — the moment
  /// is gone in 24h, the gift record is not; a full memory strip (cap 3)
  /// just skips that part.
  Future<bool> publish({
    required Uint8List bytes,
    String? caption,
    String? giftId,
  }) async {
    state = const AsyncLoading();
    try {
      final jpeg = await ref.read(uploadEncoderProvider)(bytes);
      final trimmed = caption?.trim();
      final result = await ref
          .read(feedRepositoryProvider)
          .createPost(
            jpegBytes: jpeg,
            caption: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
            giftId: giftId,
          );
      result.when(success: (_) => null, failure: (Failure f) => throw f);
      ref.invalidate(storyGroupsProvider);
      if (giftId != null) {
        // Best effort by design: the controller reports its own failure
        // (cap reached, offline) and refreshes the gift surfaces either way.
        await ref
            .read(giftPhotoControllerProvider.notifier)
            .attach(giftId: giftId, captures: [bytes]);
      }
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
