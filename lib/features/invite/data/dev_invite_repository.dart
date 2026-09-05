import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/invite/domain/invite_repository.dart';

/// Debug-only invite behavior: your code is fixed; redeeming DEVCODE1
/// "befriends" Selin, anything else is invalid.
class DevInviteRepository implements InviteRepository {
  const DevInviteRepository();

  @override
  Future<Result<String>> fetchMyCode() async => const Success('KEPTDEV1');

  @override
  Future<Result<RedeemedInvite>> redeem(String code) async {
    if (code.trim().toUpperCase() == 'DEVCODE1') {
      return const Success(
        RedeemedInvite(inviterId: 'dev-selin', label: 'Selin'),
      );
    }
    return const ResultFailure(ValidationFailure('invite_not_found'));
  }
}

/// Backend-less fallback (no --dart-define config).
class EmptyInviteRepository implements InviteRepository {
  const EmptyInviteRepository();

  @override
  Future<Result<String>> fetchMyCode() async => const Success('--------');

  @override
  Future<Result<RedeemedInvite>> redeem(String code) async =>
      const ResultFailure(ValidationFailure('invite_not_found'));
}
