import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_controller.g.dart';

/// Drives the sign-in buttons (G-11): idle / loading / error.
@riverpod
class SignInController extends _$SignInController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> signInWithApple() => _run(
        () => ref.read(authRepositoryProvider).signInWithApple(),
      );

  Future<bool> signInWithGoogle() => _run(
        () => ref.read(authRepositoryProvider).signInWithGoogle(),
      );

  Future<bool> _run(Future<Result<Object?>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}
