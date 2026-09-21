/// Shops' share links (ty.gl, app.hb.biz) bounce through an Adjust
/// interstitial (`*.adj.st`) that tries to open the app and only later
/// moves to the web page via JS. A WebView stopping there reads the title
/// "adjust deeplinking...". The web fallback rides along as a query
/// parameter — this returns it, or null when [url] is not such a link.
Uri? unwrapTrackingLink(Uri url) {
  final host = url.host.toLowerCase();
  final isAdjust =
      host == 'adj.st' || host.endsWith('.adj.st') || host == 'app.adjust.com';
  if (!isAdjust) return null;
  const keys = [
    'adjust_redirect',
    'adj_redirect',
    'adjust_fallback',
    'adj_fallback',
    'adjust_redirect_ios',
    'adj_redirect_ios',
    'adjust_redirect_android',
    'adj_redirect_android',
  ];
  for (final key in keys) {
    final raw = url.queryParameters[key];
    if (raw == null || raw.isEmpty) continue;
    final target = Uri.tryParse(raw);
    if (target != null &&
        (target.isScheme('http') || target.isScheme('https')) &&
        target.host.contains('.')) {
      return target;
    }
  }
  return null;
}
