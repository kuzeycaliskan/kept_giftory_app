import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/auth/domain/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [AuthRepository] using NATIVE sign-in flows
/// (`signInWithIdToken`), not web redirects (CLAUDE.md §2 auth note).
///
/// Apple requires the raw-nonce dance: we send SHA-256(rawNonce) to Apple and
/// the raw nonce to Supabase, which verifies the token was minted for us.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  bool _googleInitialized = false;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<String?> authStateChanges() =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user.id);

  @override
  Future<Result<String>> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        return const ResultFailure(
          AuthFailure('Apple did not return an identity token'),
        );
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      return _sessionResult(response);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const ResultFailure(AuthFailure('Sign-in cancelled'));
      }
      return ResultFailure(AuthFailure(e.message));
    } on AuthException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> signInWithGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        const iosClientId = Env.googleIosClientId;
        const webClientId = Env.googleWebClientId;
        await signIn.initialize(
          clientId: iosClientId.isEmpty ? null : iosClientId,
          serverClientId: webClientId.isEmpty ? null : webClientId,
        );
        _googleInitialized = true;
      }

      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return const ResultFailure(
          AuthFailure('Google did not return an id token'),
        );
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return _sessionResult(response);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const ResultFailure(AuthFailure('Sign-in cancelled'));
      }
      return ResultFailure(
        AuthFailure(e.description ?? 'Google sign-in failed'),
      );
    } on AuthException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  Result<String> _sessionResult(AuthResponse response) {
    final userId = response.user?.id;
    if (userId == null) {
      return const ResultFailure(AuthFailure('No session returned'));
    }
    return Success(userId);
  }

  /// Cryptographically random nonce for the Apple flow.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
