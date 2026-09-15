import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'avatar_controller.g.dart';

/// Picks, shrinks and uploads the user's avatar (G-23 handover; first
/// MediaStore consumer). Path layout '<uid>/avatar-<epoch>.jpg' gives free
/// cache-busting; the previous file is best-effort deleted after success.
@riverpod
class AvatarController extends _$AvatarController {
  static const _maxDimension = 512.0;
  static const _jpegQuality = 82;

  final _picker = ImagePicker();

  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns true when a new avatar was stored (false = user cancelled).
  Future<bool> pickAndUpload(ImageSource source) async {
    var picked = await _picker.pickImage(
      source: source,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _jpegQuality,
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

    state = const AsyncLoading();
    try {
      final bytes = await picked.readAsBytes();
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
