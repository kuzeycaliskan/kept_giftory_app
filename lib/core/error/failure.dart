import 'package:flutter/foundation.dart';

/// Base type for all *expected* failures returned from the data layer.
///
/// Repositories return failures via `Result` instead of throwing for control
/// flow. Exceptions are reserved for truly exceptional / programmer errors.
@immutable
sealed class Failure {
  const Failure(this.message);

  /// Human-facing (localizable) description of what went wrong.
  final String message;

  @override
  String toString() => 'Failure: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}
