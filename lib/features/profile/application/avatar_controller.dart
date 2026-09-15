import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'avatar_controller.g.dart';

/// Picks, crops, shrinks and uploads the user's avatar (G-23 handover;
/// first MediaStore consumer). After picking, a native circle-crop screen
/// (Instagram-style) lets the user choose the framing. Path layout
/// '<uid>/avatar-<epoch>.jpg' gives free cache-busting; the previous file
/// is best-effort deleted after success.
@riverpod
class AvatarController extends _$AvatarController {
  /// Base picked at higher resolution so cropping doesn't compound loss;
  /// the cropper emits the final 512px/82q square.
  static const _pickDimension = 1600.0;
  static const _outputDimension = 512;
  static const _jpegQuality = 82;

  final _picker = ImagePicker();

  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns true when a new avatar was stored (false = user cancelled at
  /// either the picker or the crop screen). [cropTitle] and the colors come
  /// from the UI — the controller carries no presentation knowledge.
  Future<bool> pickAndUpload(
    ImageSource source, {
    required String cropTitle,
    required Color accentColor,
    required Color onAccentColor,
  }) async {
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
      return false;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: _outputDimension,
      maxHeight: _outputDimension,
      compressQuality: _jpegQuality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: accentColor,
          toolbarWidgetColor: onAccentColor,
          activeControlsWidgetColor: accentColor,
          lockAspectRatio: true,
          hideBottomControls: true,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: cropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          cropStyle: CropStyle.circle,
        ),
      ],
    );
    if (cropped == null) return false; // user backed out of the crop screen

    state = const AsyncLoading();
    try {
      final bytes = await cropped.readAsBytes();
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
