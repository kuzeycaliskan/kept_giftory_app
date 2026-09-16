import 'package:flutter/foundation.dart';
import 'package:kept/core/error/result.dart';

/// Media storage boundary (G-207 decision): every byte of user media goes
/// through this interface, and the database only ever stores *paths* — full
/// URLs are resolved via [publicUrl] / [privateSource]. This keeps the R2
/// migration (trigger: media bill > $25/mo or ~25k active users) a copy job
/// plus a helper swap.
abstract interface class MediaStore {
  /// Uploads [bytes] to [bucket]/[path]. Paths must be unique (timestamped
  /// by convention) — plain insert, no upsert. Returns the stored path.
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

  /// How to fetch an object from a PRIVATE bucket (access decided by the
  /// backend's storage policies). Null when there is no signed-in session.
  PrivateMediaSource? privateSource({
    required String bucket,
    required String path,
  });
}

/// A fetchable reference to a private object: the URL plus whatever headers
/// the image loader must send. Backend-specific (bearer token on Supabase
/// Storage; a signed URL with no headers once media moves to R2).
@immutable
class PrivateMediaSource {
  const PrivateMediaSource({required this.uri, this.headers = const {}});

  final Uri uri;
  final Map<String, String> headers;
}
