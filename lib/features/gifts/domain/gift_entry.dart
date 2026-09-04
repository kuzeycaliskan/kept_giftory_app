import 'package:flutter/foundation.dart';

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
  });

  final String id;
  final String item;
  final String? note;
  final DateTime giftDate;
  final bool isSurprise;
  final DateTime? revealAt;
  final String? counterpartId;
  final String? counterpartLabel;

  /// Still hidden from the recipient (giver-side badge).
  bool get isPendingSurprise =>
      isSurprise && revealAt != null && DateTime.now().isBefore(revealAt!);
}
