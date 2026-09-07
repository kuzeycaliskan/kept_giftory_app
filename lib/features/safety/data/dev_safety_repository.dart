import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/safety/domain/safety_repository.dart';

/// Debug-only in-memory block list so the dev session exercises the flows.
class DevSafetyRepository implements SafetyRepository {
  const DevSafetyRepository();

  static final List<ProfileCard> _blocked = [];

  @override
  Future<Result<void>> block(String userId) async {
    if (!_blocked.any((c) => c.id == userId)) {
      _blocked.add(ProfileCard(id: userId, username: userId));
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> unblock(String userId) async {
    _blocked.removeWhere((c) => c.id == userId);
    return const Success(null);
  }

  @override
  Future<Result<List<ProfileCard>>> blockedUsers() async =>
      Success(List.unmodifiable(_blocked));

  @override
  Future<Result<void>> report(
    String userId,
    ReportReason reason, {
    String? details,
  }) async => const Success(null);
}

/// Backend-less fallback (no --dart-define config).
class EmptySafetyRepository implements SafetyRepository {
  const EmptySafetyRepository();

  @override
  Future<Result<void>> block(String userId) async => const Success(null);

  @override
  Future<Result<void>> unblock(String userId) async => const Success(null);

  @override
  Future<Result<List<ProfileCard>>> blockedUsers() async => const Success([]);

  @override
  Future<Result<void>> report(
    String userId,
    ReportReason reason, {
    String? details,
  }) async => const Success(null);
}
