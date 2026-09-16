import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:kept/core/media/supabase_media_store.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_providers.g.dart';

@Riverpod(keepAlive: true)
MediaStore mediaStore(Ref ref) =>
    SupabaseMediaStore(ref.watch(supabaseClientProvider));

/// Platform image picker behind a provider so tests can hand screens a
/// fake camera.
@Riverpod(keepAlive: true)
ImagePicker imagePicker(Ref ref) => ImagePicker();

/// Resolves a stored avatar value to a displayable URL (G-207 rule: the DB
/// holds paths; URLs come from one place). Tolerates full URLs for
/// dev/sample data. Null when the user has no avatar.
String? avatarDisplayUrl(MediaStore store, String? stored) {
  if (stored == null || stored.isEmpty) return null;
  if (stored.startsWith('http')) return stored;
  return store.publicUrl(bucket: 'avatars', path: stored);
}
