import 'package:flutter/foundation.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';

/// Who gave an externally-logged gift (G-212). Wire names match the
/// `giver_relation` Postgres enum; the UI localizes labels.
enum GiftRelation {
  mother,
  father,
  sibling,
  partner,
  relative,
  friend,
  coworker,
  other,
}

/// A gift row shaped for the UI: the counterpart is already resolved
/// (recipient when listing given gifts, giver when listing received/history).
/// A null [counterpartLabel] means the giver deleted their account (G-71
/// anonymization) — the UI shows a localized fallback.
@immutable
class GiftEntry {
  const GiftEntry({
    required this.id,
    required this.item,
    required this.giftDate,
    required this.isSurprise,
    this.note,
    this.revealAt,
    this.counterpartId,
    this.counterpartLabel,
    this.preview,
    this.giverRelation,
  });

  final String id;
  final String item;
  final String? note;
  final DateTime giftDate;
  final bool isSurprise;
  final DateTime? revealAt;
  final String? counterpartId;
  final String? counterpartLabel;

  /// Attached product preview (G-211); null for free-text gifts.
  final LinkPreview? preview;

  /// Set on self-logged external gifts (G-212): the giver isn't a member.
  /// Distinct from a null [counterpartLabel] with null relation, which means
  /// a DELETED member (anonymized).
  final GiftRelation? giverRelation;

  /// Still hidden from the recipient (giver-side badge).
  bool get isPendingSurprise =>
      isSurprise && revealAt != null && DateTime.now().isBefore(revealAt!);
}
