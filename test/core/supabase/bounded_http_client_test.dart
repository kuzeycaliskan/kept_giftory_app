import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kept/core/supabase/bounded_http_client.dart';

/// A server that never answers (black-holed network).
class _SilentClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Completer<http.StreamedResponse>().future;
}

class _EchoClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(const Stream.empty(), 204);
}

void main() {
  test('a request with no response fails at the cap as a transport error', () {
    final client = BoundedHttpClient(
      _SilentClient(),
      timeout: const Duration(milliseconds: 200),
    );
    expect(
      client.get(Uri.parse('https://example.test/rest/v1/x')),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('a normal response passes through untouched', () async {
    final client = BoundedHttpClient(_EchoClient());
    final response = await client.get(Uri.parse('https://example.test/'));
    expect(response.statusCode, 204);
  });
}
