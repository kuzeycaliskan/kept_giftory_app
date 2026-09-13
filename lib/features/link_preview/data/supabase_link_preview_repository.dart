import 'package:flutter/foundation.dart';
import 'package:kept/features/link_preview/data/webview_og_fetcher.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/features/link_preview/domain/link_preview_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Calls the `link-preview` edge function (SSRF guards, rate limit and the
/// cache all live server-side). When the server can't reach the page
/// (bot-walled shops), a hidden WebView on the device extracts the OG
/// fields and the server stores them (G-211 fallback).
class SupabaseLinkPreviewRepository implements LinkPreviewRepository {
  SupabaseLinkPreviewRepository(this._client, {WebviewOgFetcher? ogFetcher})
    : _ogFetcher = ogFetcher ?? WebviewOgFetcher();

  final SupabaseClient _client;
  final WebviewOgFetcher _ogFetcher;

  @override
  Future<LinkPreview?> fetch(String url) async {
    final trimmed = url.trim();
    final parsed = Uri.tryParse(trimmed);
    final schemeOk =
        parsed != null && (parsed.isScheme('http') || parsed.isScheme('https'));
    if (!schemeOk) {
      return null;
    }
    // 1) Server-side fetch (cached, SSRF-guarded) — primary path.
    final server = await _invoke({'url': trimmed});
    if (server != null) return server;

    // 2) Bot-walled site? Extract on-device via hidden WebView, let the
    //    server validate/store (and download the image itself).
    final meta = await _ogFetcher.fetch(trimmed);
    if (meta == null) return null;
    return _invoke({'url': trimmed, 'meta': meta});
  }

  Future<LinkPreview?> _invoke(Map<String, dynamic> body) async {
    try {
      final response = await _client.functions.invoke(
        'link-preview',
        body: body,
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final preview = data['preview'];
      if (preview is! Map<String, dynamic>) return null;
      return LinkPreview.fromJson(preview);
    } catch (e) {
      // Enhancement only — log and fall back to free text (design: G-211).
      debugPrint('link-preview fetch failed: $e');
      return null;
    }
  }
}
