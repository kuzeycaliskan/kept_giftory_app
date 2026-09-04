import 'package:kept/core/error/result.dart';

/// Authentication boundary (G-11). Implementations live in `data/`.
///
/// Social-only sign-in (Apple + Google) per the locked product decision —
/// no phone OTP at login.
abstract interface class AuthRepository {
  /// The signed-in user's id, or null when signed out.
  String? get currentUserId;

  /// Emits the user id on sign-in and null on sign-out.
  Stream<String?> authStateChanges();

  /// Native Sign in with Apple → Supabase session.
  Future<Result<String>> signInWithApple();

  /// Native Google Sign-In → Supabase session.
  Future<Result<String>> signInWithGoogle();

  Future<Result<void>> signOut();
}
