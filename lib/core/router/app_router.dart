import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/features/activity/presentation/activity_screen.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/auth/presentation/sign_in_screen.dart';
import 'package:kept/features/friends/presentation/friends_screen.dart';
import 'package:kept/features/gifts/presentation/friend_gifts_screen.dart';
import 'package:kept/features/gifts/presentation/gifts_screen.dart';
import 'package:kept/features/gifts/presentation/log_gift_screen.dart';
import 'package:kept/features/home/presentation/home_screen.dart';
import 'package:kept/features/invite/presentation/invite_screen.dart';
import 'package:kept/features/me/presentation/me_screen.dart';
import 'package:kept/features/onboarding/presentation/onboarding_screen.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/presentation/user_profile_screen.dart';
import 'package:kept/features/shell/presentation/app_shell.dart';
import 'package:kept/features/wishlist/presentation/add_wishlist_item_screen.dart';
import 'package:kept/features/wishlist/presentation/wishlist_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// App navigation graph (G-81).
///
/// The router is created ONCE (keepAlive) — auth/dev-session changes tick a
/// refresh listenable instead of rebuilding the router, so navigation state
/// survives sign-in events (rebuilding used to reset to '/' and skip
/// onboarding).
///
/// Redirect rules:
///  * signed-out → only /sign-in;
///  * signed-in without a profile row → /onboarding (async check, cached by
///    myProfileProvider);
///  * signed-in with a profile → /sign-in and /onboarding bounce to '/'.
/// Backend-less runs (no --dart-define config) skip auth entirely.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier(0);
  ref
    ..onDispose(refresh.dispose)
    ..listen(authStateProvider, (_, __) => refresh.value++)
    ..listen(devSessionProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) async {
      if (!Env.hasSupabaseConfig) return null;

      final devSession = ref.read(devSessionProvider);
      final signedIn =
          ref.read(authStateProvider).valueOrNull != null || devSession;
      final location = state.matchedLocation;
      final onSignIn = location == '/sign-in';
      final onOnboarding = location == '/onboarding';

      if (!signedIn) return onSignIn ? null : '/sign-in';

      // Dev session has no profile machinery — just keep it off /sign-in.
      if (devSession && ref.read(authStateProvider).valueOrNull == null) {
        return onSignIn ? '/' : null;
      }

      try {
        final profile = await ref.read(myProfileProvider.future);
        if (profile == null) return onOnboarding ? null : '/onboarding';
      } catch (_) {
        // Profile check failed (e.g. offline): don't trap the user.
        return onSignIn ? '/' : null;
      }

      if (onSignIn || onOnboarding) return '/';
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
        path: '/invite',
        name: 'invite',
        builder: (context, state) => const InviteScreen(),
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
      GoRoute(
        path: '/users/:uid/gifts',
        name: 'friend-gifts',
        builder: (context, state) => FriendGiftsScreen(
          profileId: state.pathParameters['uid']!,
          label: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: '/users/:uid',
        name: 'user-profile',
        builder: (context, state) => UserProfileScreen(
          profileId: state.pathParameters['uid']!,
          label: state.uri.queryParameters['name'],
        ),
      ),
    ],
  );
}
