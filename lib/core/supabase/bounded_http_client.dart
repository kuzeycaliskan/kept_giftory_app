import 'package:http/http.dart' as http;

/// How long any single backend request may wait for its response headers.
/// Large enough for a photo upload on a slow mobile link and a link-preview
/// Edge Function run; small enough that a black-holed network (packets
/// dropped, no error) can never pin a screen on its spinner.
const Duration backendRequestTimeout = Duration(seconds: 30);

/// The app's one HTTP client for Supabase (auth, PostgREST, storage, Edge
/// Functions): every request is capped at [timeout]. A request that passes
/// it fails like any other transport error, so repositories map it to a
/// network failure and screens show their error state with retry instead
/// of waiting forever.
class BoundedHttpClient extends http.BaseClient {
  BoundedHttpClient(this._inner, {this.timeout = backendRequestTimeout});

  final http.Client _inner;
  final Duration timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner
        .send(request)
        .timeout(
          timeout,
          onTimeout: () => throw http.ClientException(
            'No response within ${timeout.inSeconds}s',
            request.url,
          ),
        );
  }

  @override
  void close() => _inner.close();
}
