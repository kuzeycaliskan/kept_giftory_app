import 'dart:typed_data';

import 'package:kept/core/error/result.dart';

/// Media storage boundary (G-207 decision): every byte of user media goes
/// through this interface, and the database only ever stores *paths* — full
/// URLs are resolved via [publicUrl]. This keeps the R2 migration (trigger:
/// media bill > $25/mo or ~25k active users) a copy job plus a helper swap.
abstract interface class MediaStore {
  /// Uploads [bytes] to [bucket]/[path] (upsert). Returns the stored path.
  Future<Result<String>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  });

  /// Best-effort removal of a stored object (superseded avatars etc.).
  Future<void> delete({required String bucket, required String path});

  /// Public URL for a stored object (public buckets only).
  String publicUrl({required String bucket, required String path});
}
