import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_preview.freezed.dart';
part 'link_preview.g.dart';

/// Cached OG metadata for a pasted product link (G-211; maps
/// `public.link_previews`). The image lives in the public `link-previews`
/// storage bucket — clients never touch the original site.
@freezed
class LinkPreview with _$LinkPreview {
  const factory LinkPreview({
    required String id,
    String? url,
    String? title,
    @JsonKey(name: 'image_path') String? imagePath,
    String? price,
    String? site,

    /// Server clock for the price refresh cadence (see [isPriceRefreshDue]).
    @JsonKey(name: 'price_checked_at') DateTime? priceCheckedAt,
  }) = _LinkPreview;

  factory LinkPreview.fromJson(Map<String, dynamic> json) =>
      _$LinkPreviewFromJson(json);
}

/// Form fields cap titles at this length (matches the DB check on items).
const int kLinkPreviewTitleMaxLength = 200;

extension LinkPreviewTitleFit on LinkPreview {
  /// Product titles routinely exceed form limits; programmatic
  /// controller.text assignment bypasses maxLength, so inherit THIS instead.
  String? get titleForField {
    final t = title;
    if (t == null) return null;
    return t.length <= kLinkPreviewTitleMaxLength
        ? t
        : t.substring(0, kLinkPreviewTitleMaxLength).trimRight();
  }
}

/// Refresh cadence mirrored from the server: a missing price is asked
/// about once a day, a known one once a month. The server keeps the real
/// clock and claims the slot; this only decides whether asking is worth
/// a round trip.
const Duration kPriceRetryInterval = Duration(days: 1);
const Duration kPriceRefreshInterval = Duration(days: 30);

extension LinkPreviewRefresh on LinkPreview {
  bool isPriceRefreshDue(DateTime now) {
    final last = priceCheckedAt;
    if (last == null) return true;
    final interval = price == null
        ? kPriceRetryInterval
        : kPriceRefreshInterval;
    return now.difference(last) >= interval;
  }
}
