import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:kept/features/auth/presentation/sign_in_screen.dart';
import 'package:kept/features/home/presentation/home_screen.dart';
import 'package:kept/features/onboarding/presentation/onboarding_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// App navigation graph. The V1 tab shell (Home / Gifts / Add / Me) lands with
/// G-81; for now: sign-in → onboarding → home.
///
/// Redirect rule: signed-out users can only see /sign-in. Whether onboarding
/// is complete (profile row exists) is decided post-sign-in by the flow itself.
/// Backend-less runs (no --dart-define config) skip auth entirely so the app
/// stays runnable in early dev.
@riverpod
GoRouter appRouter(Ref ref) {
  final authState = Env.hasSupabaseConfig
      ? ref.watch(authStateProvider)
      : const AsyncValue<String?>.data(null);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!Env.hasSupabaseConfig) return null;

      final signedIn = authState.valueOrNull != null;
      final onSignIn = state.matchedLocation == '/sign-in';

      if (!signedIn && !onSignIn) return '/sign-in';
      if (signedIn && onSignIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}
