import 'package:flutter/foundation.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/shared/domain/comment.dart';
import 'package:kept/shared/domain/reaction.dart';

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
    String? linkPreviewId,
  });

  /// Records a gift received from a non-member (G-212): the giver is a
  /// fixed relation, never a surprise. RLS binds it to the caller's history.
  Future<Result<GiftEntry>> logExternal({
    required GiftRelation relation,
    required String item,
    required DateTime giftDate,
    String? note,
    String? linkPreviewId,
  });

  /// Giver-only for member gifts; recipient-only for external ones (RLS).
  Future<Result<void>> delete(String giftId);

  /// One gift with its photos; null when RLS hides it (or it was deleted).
  /// [counterpartIsGiver] picks which side to resolve as the counterpart.
  Future<Result<GiftEntry?>> fetchGift(
    String giftId, {
    required bool counterpartIsGiver,
  });

  /// Attaches an encoded JPEG to a gift (giver or recipient, cap 3 — the
  /// server rejects the fourth). Storage + row are one logical write.
  Future<Result<GiftPhoto>> addPhoto({
    required String giftId,
    required Uint8List jpegBytes,
  });

  /// Removes one of the caller's own photos (object first, then row).
  Future<Result<void>> removePhoto(GiftPhoto photo);

  /// Sets (or changes) the caller's reaction on a gift — one per user.
  Future<Result<void>> setReaction(String giftId, ReactionKind kind);

  /// Removes the caller's reaction on a gift.
  Future<Result<void>> clearReaction(String giftId);

  /// Comments on a gift, oldest first (visibility via gifts RLS).
  Future<Result<List<Comment>>> fetchComments(String giftId);

  Future<Result<Comment>> addComment(String giftId, String body);

  /// Author or a gift party (RLS).
  Future<Result<void>> deleteComment(String commentId);
}
