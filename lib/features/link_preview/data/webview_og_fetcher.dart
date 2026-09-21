import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kept/features/link_preview/data/og_extractor_script.dart';
import 'package:kept/features/link_preview/domain/tracking_link.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Client-side OG extraction through a hidden WebView (G-211 fallback):
/// loads the page and runs the shared extractor script; nothing here knows
/// a shop's markup.
///
/// Bot-walled shops (Akamai on Trendyol/Hepsiburada) 403 every server-side
/// fetch regardless of headers — the block is TLS-fingerprint based. A real
/// browser engine on the user's own device passes, and the user already
/// visited that page themselves to copy the link, so no new information
/// leaks anywhere.
class WebviewOgFetcher {
  WebviewOgFetcher({OgExtractorScript? script})
    : _script = script ?? const OgExtractorScript();

  /// Plumbing only: what a page means is the extractor's business.
  final OgExtractorScript _script;

  /// Heavy shop pages (Amazon) can pass 8s on a phone; the DOM usually has
  /// its meta and price well before `load`, so a timeout still reads it.
  static const _timeout = Duration(seconds: 12);

  /// Loads [url] invisibly and returns the extracted OG fields, or null on
  /// any failure/timeout — callers fall back to free text as usual.
  Future<Map<String, String?>?> fetch(String url) async {
    // First pass without page scripts: the shops we care about print title,
    // OG tags and price server-side, and a script-free load is a fraction
    // of the work (no WebGL, no service workers) — Amazon's full page took
    // an emulator's WebView renderer down, and Android kills the whole app
    // with it. Only a page that yields no title gets the scripted retry.
    return await _attempt(url, scripts: false) ??
        await _attempt(url, scripts: true);
  }

  Future<Map<String, String?>?> _attempt(
    String url, {
    required bool scripts,
  }) async {
    try {
      final result = Completer<Map<String, String?>?>();
      final controller = WebViewController();
      await controller.setJavaScriptMode(
        scripts ? JavaScriptMode.unrestricted : JavaScriptMode.disabled,
      );
      var engineOn = scripts;

      // Reads the document as it is now; null when it has no title yet.
      Future<Map<String, String?>?> read() async {
        if (!engineOn) {
          // Our extractor needs the engine on; page scripts already parsed
          // as inert stay inert (no reload happens).
          await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
          engineOn = true;
        }
        final raw = await controller.runJavaScriptReturningResult(
          await _script.load(),
        );
        return parseExtractorResult(raw.toString());
      }

      // Android fires onPageFinished for a redirect target once while the
      // document is still about:blank (amzn.eu → amazon: title "", 3
      // nodes) and again when the page really landed. So every finish is
      // a read attempt, and the first one with a title wins.
      Future<void> tryRead() async {
        if (result.isCompleted) return;
        try {
          final meta = await read();
          if (meta != null && !result.isCompleted) result.complete(meta);
        } catch (e) {
          debugPrint('webview og fetch: read failed: $e');
        }
      }

      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final target = Uri.tryParse(request.url);
            if (target == null) return NavigationDecision.prevent;
            // App schemes (ty://, hb://) have no page to read.
            if (!target.isScheme('http') && !target.isScheme('https')) {
              return NavigationDecision.prevent;
            }
            final unwrapped = unwrapTrackingLink(target);
            if (unwrapped != null) {
              unawaited(controller.loadRequest(unwrapped));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (finished) {
            // Belt and braces: a redirect the delegate did not see still
            // lands on the interstitial — move on instead of reading it.
            final landed = Uri.tryParse(finished);
            final unwrapped = landed == null
                ? null
                : unwrapTrackingLink(landed);
            if (unwrapped != null) {
              unawaited(controller.loadRequest(unwrapped));
              return;
            }
            if (scripts) {
              // Give client-rendered pages a beat to inject their meta.
              unawaited(
                Future<void>.delayed(
                  const Duration(milliseconds: 400),
                ).then((_) => tryRead()),
              );
            } else {
              unawaited(tryRead());
            }
          },
          onWebResourceError: (_) {
            // Subresource errors are normal; only give up via timeout.
          },
        ),
      );
      await controller.loadRequest(Uri.parse(url));
      final meta = await result.future.timeout(
        _timeout,
        onTimeout: () async {
          // Slow page: read whatever the DOM holds right now.
          debugPrint('webview og fetch: load timed out, reading DOM');
          try {
            return await read();
          } catch (e) {
            debugPrint('webview og fetch: read failed: $e');
            return null;
          }
        },
      );
      if (meta == null) {
        debugPrint('webview og fetch: no title (scripts: $scripts) for $url');
      }
      return meta;
    } catch (e) {
      debugPrint('webview og fetch failed (scripts: $scripts): $e');
      return null;
    }
  }
}

/// The extractor's JSON, unwrapped from the platform's string quoting;
/// null when the document had no title (not a page worth keeping — an
/// about:blank between redirects, a shell before its content).
@visibleForTesting
Map<String, String?>? parseExtractorResult(String raw) {
  var jsonText = raw;
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
}
