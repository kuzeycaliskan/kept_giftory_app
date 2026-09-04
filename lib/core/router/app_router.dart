import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/features/activity/presentation/activity_screen.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/auth/presentation/sign_in_screen.dart';
import 'package:kept/features/friends/presentation/friends_screen.dart';
import 'package:kept/features/gifts/presentation/gifts_screen.dart';
import 'package:kept/features/gifts/presentation/log_gift_screen.dart';
import 'package:kept/features/home/presentation/home_screen.dart';
import 'package:kept/features/me/presentation/me_screen.dart';
import 'package:kept/features/onboarding/presentation/onboarding_screen.dart';
import 'package:kept/features/shell/presentation/app_shell.dart';
import 'package:kept/features/wishlist/presentation/add_wishlist_item_screen.dart';
import 'package:kept/features/wishlist/presentation/wishlist_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// App navigation graph (G-81).
///
/// Tab shell (Home / Gifts / Me as stateful branches; ➕ Add is an action, not
/// a branch) + full-screen routes above the shell (sign-in, onboarding,
/// activity, quick-add targets).
///
/// Redirect rule: signed-out users can only see /sign-in. Whether onboarding
/// is complete (profile row exists) is decided post-sign-in by the flow
/// itself. Backend-less runs (no --dart-define config) skip auth entirely so
/// the app stays runnable in early dev.
@riverpod
GoRouter appRouter(Ref ref) {
  final authState = Env.hasSupabaseConfig
      ? ref.watch(authStateProvider)
      : const AsyncValue<String?>.data(null);
  final devSession = ref.watch(devSessionProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!Env.hasSupabaseConfig) return null;

      final signedIn = authState.valueOrNull != null || devSession;
      final onSignIn = state.matchedLocation == '/sign-in';

      if (!signedIn && !onSignIn) return '/sign-in';
      if (signedIn && onSignIn) return '/';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gifts',
                name: 'gifts',
                builder: (context, state) => const GiftsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                name: 'me',
                builder: (context, state) => const MeScreen(),
              ),
            ],
          ),
        ],
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
      GoRoute(
        path: '/activity',
        name: 'activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/gifts/log',
        name: 'log-gift',
        builder: (context, state) => const LogGiftScreen(),
      ),
      GoRoute(
        path: '/wishlist/add',
        name: 'add-wishlist-item',
        builder: (context, state) => const AddWishlistItemScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        name: 'my-wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/users/:uid/wishlist',
        name: 'friend-wishlist',
        builder: (context, state) => WishlistScreen(
          ownerId: state.pathParameters['uid'],
          ownerLabel: state.uri.queryParameters['name'],
        ),
      ),
    ],
  );
}
