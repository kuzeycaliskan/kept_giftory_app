import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_composer.g.dart';

/// Capture → share pipeline for a moment (G-201). Two steps so the compose
/// screen sits between them: [capture] opens the device camera (never the
/// gallery — a moment is taken now), [publish] shrinks + stores.
@riverpod
class PostComposer extends _$PostComposer {
  /// Camera output is requested large enough that the final downscale never
  /// upsamples; the isolate then encodes 1080px/80q (≈150–300 KB), matching
  /// the bucket's 1 MB server cap with room to spare.
  static const _captureDimension = 1600.0;
  static const _outputMaxSide = 1080;
  static const _jpegQuality = 80;

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

  /// Encodes and shares. Returns true when the moment is live.
  Future<bool> publish({required Uint8List bytes, String? caption}) async {
    state = const AsyncLoading();
    try {
      final jpeg = await ref.read(postEncoderProvider)(bytes);
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

/// Bytes-in → post JPEG-out. A provider so widget tests can skip the isolate
/// hop (`compute` and fake async don't mix) with an identity encoder.
@Riverpod(keepAlive: true)
Future<Uint8List> Function(Uint8List) postEncoder(Ref ref) =>
    (bytes) => compute(toPostJpeg, bytes);

/// Isolate entry: any input encoding → EXIF-upright JPEG, longest side ≤1080.
@visibleForTesting
Uint8List toPostJpeg(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw const FormatException('Undecodable image');
  }
  // Camera files carry orientation in EXIF; bake it so every viewer agrees.
  final upright = img.bakeOrientation(decoded);
  final longest = upright.width > upright.height
      ? upright.width
      : upright.height;
  final resized = longest > PostComposer._outputMaxSide
      ? (upright.width >= upright.height
            ? img.copyResize(upright, width: PostComposer._outputMaxSide)
            : img.copyResize(upright, height: PostComposer._outputMaxSide))
      : upright;
  return Uint8List.fromList(
    img.encodeJpg(resized, quality: PostComposer._jpegQuality),
  );
}
