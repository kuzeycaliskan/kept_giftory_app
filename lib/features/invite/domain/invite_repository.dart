import 'package:flutter/foundation.dart';
import 'package:kept/core/error/result.dart';

/// Who you just became friends with by redeeming a code.
@immutable
class RedeemedInvite {
  const RedeemedInvite({required this.inviterId, required this.label});

  final String inviterId;
  final String label;
}

/// Invite boundary (G-34): personal code sharing + redemption.
/// Real deep links attach here once a domain exists (App/Universal Links).
abstract interface class InviteRepository {
  /// The signed-in user's stable invite code.
  Future<Result<String>> fetchMyCode();

  /// Redeem someone's code → instant accepted friendship.
  Future<Result<RedeemedInvite>> redeem(String code);
}
