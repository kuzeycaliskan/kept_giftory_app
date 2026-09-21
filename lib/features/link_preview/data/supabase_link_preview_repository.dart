import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  /// URLs already enriched this session — an image-less cached preview
  /// triggers the WebView path once, not on every keystroke/paste.
  static final Set<String> _enriched = {};

  static const _maxImageBytes = 300 * 1024;

  @override
  Future<LinkPreview?> fetch(String url, {bool refresh = false}) async {
    final trimmed = url.trim();
    final parsed = Uri.tryParse(trimmed);
    final schemeOk =
        parsed != null && (parsed.isScheme('http') || parsed.isScheme('https'));
    if (!schemeOk) {
      return null;
    }
    // 1) Server-side fetch (cached, SSRF-guarded) — primary path. A row
    //    that still lacks its image or price gets one on-device try per
    //    session (the server refetches such rows on a fresh paste too).
    //    A refresh the server declined (slot not due) is final.
    final response = await _invoke({
      'url': trimmed,
      if (refresh) 'refresh': true,
    });
    final server = response?.preview;
    if (refresh && response != null && response.cached) return server;
    final complete =
        server != null && server.imagePath != null && server.price != null;
    if (complete || (server != null && _enriched.contains(trimmed))) {
      return server;
    }

    // 2) Bot-walled site or incomplete cache: extract on-device via hidden
    //    WebView; the device also downloads the image bytes (some CDNs
    //    require a browserly referer the server can't fake) and the server
    //    validates + stores everything.
    _enriched.add(trimmed);
    final meta = await _ogFetcher.fetch(trimmed);
    if (meta == null) return server;
    final imageB64 = await _downloadImage(meta['image'], referer: trimmed);
    final enriched = await _invoke({
      'url': trimmed,
      if (refresh) 'refresh': true,
      'meta': {...meta, if (imageB64 != null) 'image_b64': imageB64},
    });
    return enriched?.preview ?? server;
  }

  /// Fetches the product image on-device (≤300KB) and base64-encodes it.
  Future<String?> _downloadImage(String? url, {required String referer}) async {
    if (url == null) return null;
    final parsed = Uri.tryParse(url);
    final schemeOk =
        parsed != null && (parsed.isScheme('http') || parsed.isScheme('https'));
    if (!schemeOk) {
      return null;
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final request = await client.getUrl(parsed);
      request.headers
        ..set(
          HttpHeaders.userAgentHeader,
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X)',
        )
        ..set(HttpHeaders.refererHeader, referer)
        ..set(HttpHeaders.acceptHeader, 'image/*');
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != 200) return null;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
        if (builder.length > _maxImageBytes) return null;
      }
      final bytes = builder.takeBytes();
      return bytes.isEmpty ? null : base64Encode(bytes);
    } catch (e) {
      debugPrint('preview image download failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<_PreviewResponse?> _invoke(Map<String, dynamic> body) async {
    try {
      final response = await _client.functions.invoke(
        'link-preview',
        body: body,
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final preview = data['preview'];
      if (preview is! Map<String, dynamic>) return null;
      return _PreviewResponse(
        LinkPreview.fromJson(preview),
        cached: data['cached'] == true,
      );
    } catch (e) {
      // Enhancement only — log and fall back to free text (design: G-211).
      debugPrint('link-preview fetch failed: $e');
      return null;
    }
  }
}

/// The function's answer: the row, and whether it came straight from the
/// cache (no fetch happened — nothing further to try this time).
class _PreviewResponse {
  const _PreviewResponse(this.preview, {required this.cached});

  final LinkPreview preview;
  final bool cached;
}
