import 'package:kept/core/error/result.dart';

/// Device-token boundary (G-61). Dispatch happens server-side (G-62).
abstract interface class PushTokenRepository {
  /// Upsert this device's FCM token for the signed-in user.
  Future<Result<void>> register({
    required String token,
    required String platform,
  });

  /// Remove a token (sign-out hygiene).
  Future<Result<void>> unregister(String token);
}
