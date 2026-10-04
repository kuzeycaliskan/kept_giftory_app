import 'package:image_picker/image_picker.dart';
import 'package:kept/core/media/camera/camera_backend.dart';
import 'package:kept/core/media/camera/plugin_camera_backend.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:kept/core/media/supabase_media_store.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_providers.g.dart';

@Riverpod(keepAlive: true)
MediaStore mediaStore(Ref ref) =>
    SupabaseMediaStore(ref.watch(supabaseClientProvider));

/// Platform image picker — gallery only since G-407; the camera is Kept's
/// own ([cameraBackend]).
@Riverpod(keepAlive: true)
ImagePicker imagePicker(Ref ref) => ImagePicker();

/// The device camera (G-407); tests override it with a fake backend.
@Riverpod(keepAlive: true)
CameraBackend cameraBackend(Ref ref) => const PluginCameraBackend();

/// Resolves a stored avatar value to a displayable URL (G-207 rule: the DB
/// holds paths; URLs come from one place). Tolerates full URLs for
/// dev/sample data. Null when the user has no avatar.
String? avatarDisplayUrl(MediaStore store, String? stored) {
  if (stored == null || stored.isEmpty) return null;
  if (stored.startsWith('http')) return stored;
  return store.publicUrl(bucket: 'avatars', path: stored);
}
