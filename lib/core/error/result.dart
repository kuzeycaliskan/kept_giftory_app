import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';

/// A lightweight success-or-failure value, used as the return type of all
/// repository methods. Avoids throwing for expected / control-flow errors
/// (CLAUDE.md §5).
@immutable
sealed class Result<T> {
  const Result();

  /// Fold both branches into a single value.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  });
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) =>
      success(value);
}

class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) =>
      failure(this.failure);
}
