import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

/// Why a user is being reported (G-73). Wire values match the DB check
/// constraint on `reports.reason`.
enum ReportReason { spam, harassment, inappropriate, other }

/// Block / report boundary (G-72/G-73). Blocking is mutual and silent:
/// it severs any friendship and hides both users from each other everywhere
/// (profile, sections, search, cards) — enforced server-side.
abstract interface class SafetyRepository {
  /// Blocks [userId] and severs any friendship/pending request (atomic RPC).
  Future<Result<void>> block(String userId);

  /// Removes [userId] from the caller's block list.
  Future<Result<void>> unblock(String userId);

  /// The caller's blocked users, newest first.
  Future<Result<List<ProfileCard>>> blockedUsers();

  /// Files a report about [userId]. Duplicate reports for the same user are
  /// treated as success (the queue already has the pair).
  Future<Result<void>> report(
    String userId,
    ReportReason reason, {
    String? details,
  });
}
