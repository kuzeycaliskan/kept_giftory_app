import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage-backed [MediaStore] (G-207: start here, migrate to R2 on
/// the recorded trigger).
///
/// Uploads/deletes go over raw HTTP with the session token attached
/// explicitly. Rationale: the storage_client's auth plumbing produced RLS
/// 403s inside the running app while byte-identical requests (curl, pure
/// dart with the same package versions) passed — this request shape is the
/// proven-working one and leaves nothing implicit about identity.
class SupabaseMediaStore implements MediaStore {
  SupabaseMediaStore(this._client);

  final SupabaseClient _client;

  static const _timeout = Duration(seconds: 20);

  Map<String, String>? _authHeaders() {
    final token = _client.auth.currentSession?.accessToken;
    if (token == null) return null;
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      'apikey':
          _client.rest.headers['apikey'] ?? _client.headers['apikey'] ?? '',
    };
  }

  Uri _objectUri(String bucket, String path) =>
      Uri.parse('${_client.storage.url}/object/$bucket/$path');

  @override
  Future<Result<String>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final headers = _authHeaders();
    if (headers == null) {
      return const ResultFailure(AuthFailure('Signed out'));
    }
    final httpClient = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await httpClient.postUrl(_objectUri(bucket, path));
      headers.forEach(request.headers.set);
      request.headers.set(HttpHeaders.contentTypeHeader, contentType);
      request.add(bytes);
      final response = await request.close().timeout(_timeout);
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) return Success(path);
      debugPrint('media upload ${response.statusCode}: $body');
      return ResultFailure(NetworkFailure('Upload failed: $body'));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    } finally {
      httpClient.close(force: true);
    }
  }

  @override
  Future<void> delete({required String bucket, required String path}) async {
    final headers = _authHeaders();
    if (headers == null) return;
    final httpClient = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await httpClient.deleteUrl(_objectUri(bucket, path));
      headers.forEach(request.headers.set);
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != 200) {
        // Best-effort: an orphaned old file is cosmetic, never fatal.
        debugPrint('media delete ${response.statusCode} ($bucket/$path)');
      }
      await response.drain<void>();
    } catch (e) {
      debugPrint('media delete failed ($bucket/$path): $e');
    } finally {
      httpClient.close(force: true);
    }
  }

  @override
  String publicUrl({required String bucket, required String path}) =>
      _client.storage.from(bucket).getPublicUrl(path);
}
