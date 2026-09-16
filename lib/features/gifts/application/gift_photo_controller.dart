import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gift_photo_controller.g.dart';

/// Gift photo pipeline (G-204): camera-only capture, shared JPEG encoding,
/// attach/remove through the repository. Used by both log forms (photos
/// taken before the gift exists are attached right after it is created)
/// and the detail screen.
@riverpod
class GiftPhotoController extends _$GiftPhotoController {
  static const _captureDimension = 1600.0;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Opens the camera; null when the user backs out. Gallery is deliberately
  /// not offered — a gift photo is taken, not picked (product decision).
  Future<Uint8List?> capture() async {
    final picker = ref.read(imagePickerProvider);
    var picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _captureDimension,
      maxHeight: _captureDimension,
      requestFullMetadata: false,
    );
    if (picked == null && defaultTargetPlatform == TargetPlatform.android) {
      picked = (await picker.retrieveLostData()).file;
    }
    if (picked == null) return null;
    return picked.readAsBytes();
  }

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
