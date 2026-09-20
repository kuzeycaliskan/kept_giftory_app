import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'avatar_controller.g.dart';

/// Avatar pipeline (G-23 handover; first MediaStore consumer), split in two
/// steps so the UI can host the in-app crop screen between them:
/// [pickImage] → (AvatarCropScreen) → [uploadCropped]. Path layout
/// '<uid>/avatar-<epoch>.jpg' gives free cache-busting; the previous file
/// is best-effort deleted after success.
@riverpod
class AvatarController extends _$AvatarController {
  /// Base picked at higher resolution so cropping doesn't compound loss;
  /// [uploadCropped] shrinks the final square to 512px/82q jpeg.
  static const _pickDimension = 1600.0;
  static const _outputDimension = 512;
  static const _jpegQuality = 82;

  final _picker = ImagePicker();

  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Picks a photo and returns its bytes (null = user cancelled).
  Future<Uint8List?> pickImage(ImageSource source) async {
    var picked = await _picker.pickImage(
      source: source,
      maxWidth: _pickDimension,
      maxHeight: _pickDimension,
      requestFullMetadata: false,
    );
    // Android: the OS may kill our activity while the camera is open; the
    // result then arrives via retrieveLostData on resume instead of null.
    if (picked == null && defaultTargetPlatform == TargetPlatform.android) {
      final lost = await _picker.retrieveLostData();
      final file = lost.file;
      if (file != null) picked = file;
    }
    if (picked == null) {
      debugPrint('avatar pick cancelled or lost');
      return null;
    }
    // Bake EXIF orientation first: the cropper works on raw pixels, so a
    // front-camera "mirrored" orientation flag would otherwise flip the
    // saved avatar relative to what the user framed.
    final raw = await picked.readAsBytes();
    return compute(normalizeOrientation, raw);
  }

  /// Shrinks the cropped square to the avatar format and stores it.
  /// Returns true when the new avatar is live on the profile.
  Future<bool> uploadCropped(Uint8List croppedBytes) async {
    state = const AsyncLoading();
    try {
      // Decode/resize/encode off the UI thread — a 1600px source is real work.
      final bytes = await compute(_toAvatarJpeg, croppedBytes);

      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure('Signed out');
      }
      final previousPath = ref.read(myProfileProvider).valueOrNull?.avatarUrl;
      final path =
          '$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';

      final store = ref.read(mediaStoreProvider);
      final uploaded = await store.upload(
        bucket: 'avatars',
        path: path,
        bytes: bytes,
        contentType: 'image/jpeg',
      );
      final stored = uploaded.when(
        success: (p) => p,
        failure: (Failure f) => throw f,
      );

      final updated = await ref
          .read(profileRepositoryProvider)
          .updateAvatarPath(stored);
      updated.when(success: (_) => null, failure: (Failure f) => throw f);

      // Best-effort cleanup of the superseded file (paths only, never URLs).
      if (previousPath != null && !previousPath.startsWith('http')) {
        await store.delete(bucket: 'avatars', path: previousPath);
      }

      ref.invalidate(myProfileProvider);
      state = const AsyncData(null);
      return true;
    } on Failure catch (failure, stack) {
      // Log the concrete failure — the UI only shows a generic message.
      debugPrint('avatar upload failed (failure): $failure');
      state = AsyncError(failure, stack);
      return false;
    } catch (e, stack) {
      debugPrint('avatar upload failed: $e');
      state = AsyncError(UnknownFailure(e.toString()), stack);
      return false;
    }
  }
}

/// Isolate entry: any input encoding → 512px/82q jpeg square.
Uint8List _toAvatarJpeg(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw const FormatException('Undecodable image');
  }
  final resized =
      (decoded.width > AvatarController._outputDimension ||
          decoded.height > AvatarController._outputDimension)
      ? img.copyResize(
          decoded,
          width: AvatarController._outputDimension,
          height: AvatarController._outputDimension,
        )
      : decoded;
  return Uint8List.fromList(
    img.encodeJpg(resized, quality: AvatarController._jpegQuality),
  );
}
