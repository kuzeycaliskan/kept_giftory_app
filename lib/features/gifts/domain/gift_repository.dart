import 'package:kept/core/error/result.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';

/// Gifts boundary (G-51/G-52). Surprise isolation is enforced by RLS:
/// unrevealed surprises never reach the recipient's queries.
abstract interface class GiftRepository {
  /// Gifts I logged (counterpart = recipient). Includes pending surprises.
  Future<Result<List<GiftEntry>>> fetchGiven();

  /// Gifts logged for me (counterpart = giver). RLS hides pending surprises.
  Future<Result<List<GiftEntry>>> fetchReceived();

  /// A friend's history (counterpart = giver), per their visibility.
  Future<Result<List<GiftEntry>>> fetchFor(String profileId);

  /// Log a gift I bought. [revealAt] required when [isSurprise].
  Future<Result<GiftEntry>> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
  });

  /// Giver-only (RLS enforced).
  Future<Result<void>> delete(String giftId);
}
