import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/auth/application/sign_in_controller.dart';

/// Sign-in (G-11): Apple + Google only. Flows fail gracefully while provider
/// config is absent.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  Future<void> _handle(
    BuildContext context,
    Future<bool> Function() signIn,
  ) async {
    final ok = await signIn();
    // The router's redirect decides where to land: onboarding for accounts
    // without a profile row, Home for returning users.
    if (ok && context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(signInControllerProvider);
    final controller = ref.read(signInControllerProvider.notifier);

    ref.listen(signInControllerProvider, (_, next) {
      final error = next.error;
      // Cancelled sign-in is the user's own action — stay silent.
      if (error is Failure && error is! AuthCancelledFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSignInFailed)),
        );
      }
    });

    final busy = state.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signInTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => _handle(context, controller.signInWithApple),
                icon: const Icon(Icons.apple),
                label: Text(l10n.signInWithApple),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => _handle(context, controller.signInWithGoogle),
                icon: const Icon(Icons.g_mobiledata),
                label: Text(l10n.signInWithGoogle),
              ),
              if (busy) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              // Debug builds only: bypass auth to test the app before the
              // OAuth providers are configured. Stripped from release.
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: busy
                      ? null
                      : () {
                          ref.read(devSessionProvider.notifier).enable();
                          context.go('/');
                        },
                  child: Text(l10n.signInDevMode),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
