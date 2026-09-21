import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kept/features/link_preview/domain/tracking_link.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Client-side OG extraction through a hidden WebView (G-211 fallback).
///
/// Bot-walled shops (Akamai on Trendyol/Hepsiburada) 403 every server-side
/// fetch regardless of headers — the block is TLS-fingerprint based. A real
/// browser engine on the user's own device passes, and the user already
/// visited that page themselves to copy the link, so no new information
/// leaks anywhere.
class WebviewOgFetcher {
  /// Heavy shop pages (Amazon) can pass 8s on a phone; the DOM usually has
  /// its meta and price well before `load`, so a timeout still reads it.
  static const _timeout = Duration(seconds: 12);

  /// JS that pulls the OG/Twitter fields out of the loaded document.
  static const _extractJs = r'''
(function () {
  var m = function (p) {
    var e = document.querySelector(
      "meta[property='" + p + "'],meta[name='" + p + "']");
    return e ? e.getAttribute("content") : null;
  };
  var img = m("og:image") || m("og:image:url") || m("twitter:image");
  if (!img) {
    var l = document.querySelector("link[rel='image_src']");
    if (l) img = l.getAttribute("href");
  }
  if (!img) {
    // Fallback: largest rendered image on the page (product hero). Only
    // product-shaped images qualify — a tall sprite sheet of icons is
    // "large" too, and once won on Amazon.
    var best = null, bestArea = 40000; // require at least ~200x200
    document.querySelectorAll("img").forEach(function (e) {
      var w = e.naturalWidth || 0, h = e.naturalHeight || 0;
      var a = w * h, ratio = h > 0 ? w / h : 0;
      var shaped = w >= 200 && h >= 200 && ratio >= 0.5 && ratio <= 2;
      if (shaped && a > bestArea && e.src && e.src.indexOf("http") === 0) {
        best = e.src; bestArea = a;
      }
    });
    img = best;
  }
  if (img && img.indexOf("//") === 0) img = "https:" + img;
  // Price: og tags first; else what shops publish for Google (itemprop,
  // JSON-LD offers) rendered like an og price ("₺1.299,00").
  var fmt = function (raw, cur) {
    var n = Number(String(raw).indexOf(",") >= 0 && String(raw).indexOf(".") < 0
      ? String(raw).replace(",", ".") : String(raw).replace(/,/g, ""));
    if (!isFinite(n) || n <= 0) return null;
    try {
      return new Intl.NumberFormat("tr-TR",
        { style: "currency", currency: cur || "TRY" }).format(n);
    } catch (e) { return null; }
  };
  var price = m("product:price:amount") || m("og:price:amount") || null;
  if (!price) {
    // Amazon: no structured price. The price-to-pay block is the one that
    // is not a struck-through list price or a per-unit price; its
    // accessible text is often empty on mobile, so assemble the parts.
    var pay = document.querySelector(
      ".priceToPay," +
      "#corePriceDisplay_mobile_feature_div .a-price:not(.a-text-price)," +
      "#corePrice_mobile_feature_div .a-price:not(.a-text-price)," +
      "#corePriceDisplay_desktop_feature_div .a-price:not(.a-text-price)," +
      "#corePrice_feature_div .a-price:not(.a-text-price)");
    if (pay) {
      var off = pay.querySelector(".a-offscreen");
      var t = off ? (off.textContent || "").trim() : "";
      if (!t) {
        var whole = pay.querySelector(".a-price-whole");
        var frac = pay.querySelector(".a-price-fraction");
        // Amazon renders an empty symbol node before the number and the
        // real one after it — take the first non-empty.
        var sym = "";
        pay.querySelectorAll(".a-price-symbol").forEach(function (e) {
          if (!sym) sym = (e.textContent || "").trim();
        });
        var w = whole ? (whole.textContent || "").replace(/[^0-9.]/g, "") : "";
        if (w) {
          t = w + (frac ? "," + (frac.textContent || "").trim() : "") +
            " " + (sym || "TL");
        }
      }
      if (t) price = t.replace(/([0-9])(TL|TRY)$/, "$1 $2");
    }
  }
  if (!price) {
    var ip = document.querySelector("[itemprop='price']");
    var ipv = ip && (ip.getAttribute("content") || ip.textContent);
    var ipc = document.querySelector("[itemprop='priceCurrency']");
    if (ipv) price = fmt(ipv, ipc && ipc.getAttribute("content"));
  }
  if (!price) {
    var scripts = document.querySelectorAll(
      "script[type='application/ld+json']");
    for (var i = 0; i < scripts.length && !price; i++) {
      var t = scripts[i].textContent || "";
      var pm = t.match(/"(?:price|lowPrice)"\s*:\s*"?([0-9][0-9.,]*)"?/);
      if (!pm) continue;
      var cm = t.match(/"priceCurrency"\s*:\s*"([A-Z]{3})"/);
      price = fmt(pm[1], cm && cm[1]);
    }
  }
  return JSON.stringify({
    title: m("og:title") || m("twitter:title") || document.title || null,
    image: img || null,
    price: price,
    site: m("og:site_name") || location.hostname || null,
  });
})()''';

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
      final loaded = Completer<bool>();
      final controller = WebViewController();
      await controller.setJavaScriptMode(
        scripts ? JavaScriptMode.unrestricted : JavaScriptMode.disabled,
      );
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
            if (!loaded.isCompleted) loaded.complete(true);
          },
          onWebResourceError: (_) {
            // Subresource errors are normal; only give up via timeout.
          },
        ),
      );
      await controller.loadRequest(Uri.parse(url));
      final ok = await loaded.future.timeout(_timeout, onTimeout: () => false);
      if (!ok) debugPrint('webview og fetch: load timed out, reading DOM');
      if (scripts) {
        // Give client-rendered pages a beat to inject their meta tags.
        await Future<void>.delayed(const Duration(milliseconds: 400));
      } else {
        // Our extractor needs the engine on; page scripts already parsed
        // as inert stay inert (no reload happens).
        await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      }
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
      if (title == null) {
        debugPrint('webview og fetch: no title (scripts: $scripts) for $url');
        return null;
      }
      return {
        'title': title,
        'image': str(map['image']),
        'price': str(map['price']),
        'site': str(map['site']),
      };
    } catch (e) {
      debugPrint('webview og fetch failed (scripts: $scripts): $e');
      return null;
    }
  }
}
