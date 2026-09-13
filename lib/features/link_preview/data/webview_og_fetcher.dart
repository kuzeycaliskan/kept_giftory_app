import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Client-side OG extraction through a hidden WebView (G-211 fallback).
///
/// Bot-walled shops (Akamai on Trendyol/Hepsiburada) 403 every server-side
/// fetch regardless of headers — the block is TLS-fingerprint based. A real
/// browser engine on the user's own device passes, and the user already
/// visited that page themselves to copy the link, so no new information
/// leaks anywhere.
class WebviewOgFetcher {
  static const _timeout = Duration(seconds: 8);

  /// JS that pulls the OG/Twitter fields out of the loaded document.
  static const _extractJs = '''
(function () {
  var m = function (p) {
    var e = document.querySelector(
      "meta[property='" + p + "'],meta[name='" + p + "']");
    return e ? e.getAttribute("content") : null;
  };
  return JSON.stringify({
    title: m("og:title") || m("twitter:title") || document.title || null,
    image: m("og:image") || m("og:image:url") || m("twitter:image") || null,
    price: m("product:price:amount") || m("og:price:amount") || null,
    site: m("og:site_name") || location.hostname || null,
  });
})()''';

  /// Loads [url] invisibly and returns the extracted OG fields, or null on
  /// any failure/timeout — callers fall back to free text as usual.
  Future<Map<String, String?>?> fetch(String url) async {
    try {
      final loaded = Completer<bool>();
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!loaded.isCompleted) loaded.complete(true);
          },
          onWebResourceError: (_) {
            // Subresource errors are normal; only give up via timeout.
          },
        ),
      );
      await controller.loadRequest(Uri.parse(url));
      final ok = await loaded.future.timeout(_timeout, onTimeout: () => false);
      if (!ok) return null;
      // Give client-rendered pages a beat to inject their meta tags.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final raw = await controller.runJavaScriptReturningResult(_extractJs);
      var jsonText = raw.toString();
      // Platforms wrap the JS string result differently — unquote if needed.
      if (jsonText.startsWith('"')) {
        jsonText = json.decode(jsonText) as String;
      }
      final map = json.decode(jsonText) as Map<String, dynamic>;
      String? str(Object? v) =>
          v is String && v.trim().isNotEmpty ? v.trim() : null;
      final title = str(map['title']);
      if (title == null) return null;
      return {
        'title': title,
        'image': str(map['image']),
        'price': str(map['price']),
        'site': str(map['site']),
      };
    } catch (e) {
      debugPrint('webview og fetch failed: $e');
      return null;
    }
  }
}
