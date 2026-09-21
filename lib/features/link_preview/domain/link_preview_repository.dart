import 'package:kept/features/link_preview/domain/link_preview.dart';

/// Link-preview boundary (G-211).
///
/// Deliberately NOT a `Result`: previews are an enhancement, never a
/// dependency. Every failure mode (invalid URL, unreachable site, no OG
/// tags, rate limit, network) collapses to null and the form silently keeps
/// its free-text behavior — the flow must never block on this.
abstract interface class LinkPreviewRepository {
  /// [refresh] asks the server to re-check a cached row's price/image if
  /// its slot is due (daily without a price, monthly with one); otherwise
  /// the cached row comes back untouched.
  Future<LinkPreview?> fetch(String url, {bool refresh = false});
}
