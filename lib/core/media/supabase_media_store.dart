import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage-backed [MediaStore] (G-207: start here, migrate to R2 on
/// the recorded trigger).
class SupabaseMediaStore implements MediaStore {
  SupabaseMediaStore(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<String>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      return Success(path);
    } on StorageException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> delete({required String bucket, required String path}) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } on StorageException catch (e) {
      // Best-effort: an orphaned old avatar is cosmetic, never fatal.
      debugPrint('media delete failed ($bucket/$path): ${e.message}');
    }
  }

  @override
  String publicUrl({required String bucket, required String path}) =>
      _client.storage.from(bucket).getPublicUrl(path);
}
