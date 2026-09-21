import 'package:flutter/services.dart';

/// The shop-page extractor shared with the Edge Function
/// (`supabase/functions/link-preview/extractor.js`, bundled as an asset).
/// Loaded once; the WebView evaluates it and gets a JSON string back.
class OgExtractorScript {
  const OgExtractorScript();

  static const assetPath = 'supabase/functions/link-preview/extractor.js';

  static Future<String>? _cached;

  Future<String> load() => _cached ??= rootBundle.loadString(assetPath);
}
