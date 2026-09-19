import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

/// Why something is being reported (G-73). Wire values match the DB check
/// constraint on `reports.reason`.
enum ReportReason { spam, harassment, inappropriate, other }

/// What is being reported (G-209). Wire values match `report_target`.
enum ReportTargetType { profile, post, gift, postComment, giftComment }

/// A report target: the thing plus the accountable person (its owner).
/// For profiles both ids are the same.
class ReportTarget {
  const ReportTarget({
    required this.type,
    required this.id,
    required this.ownerId,
  });

  const ReportTarget.profile(String profileId)
    : this(type: ReportTargetType.profile, id: profileId, ownerId: profileId);

  final ReportTargetType type;
  final String id;
  final String ownerId;

  String get wireType => switch (type) {
    ReportTargetType.profile => 'profile',
    ReportTargetType.post => 'post',
    ReportTargetType.gift => 'gift',
    ReportTargetType.postComment => 'post_comment',
    ReportTargetType.giftComment => 'gift_comment',
  };
}

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

  /// Files a report about [target]. Reporting the same target twice is
  /// treated as success (the queue already has it).
  Future<Result<void>> report(
    ReportTarget target,
    ReportReason reason, {
    String? details,
  });
}
