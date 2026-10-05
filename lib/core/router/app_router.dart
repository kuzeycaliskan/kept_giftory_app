import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/features/activity/presentation/activity_screen.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/auth/presentation/sign_in_screen.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/events/presentation/event_detail_screen.dart';
import 'package:kept/features/events/presentation/event_for_honoree_screen.dart';
import 'package:kept/features/feed/presentation/compose_post_screen.dart';
import 'package:kept/features/feed/presentation/moment_capture.dart';
import 'package:kept/features/feed/presentation/story_viewer_screen.dart';
import 'package:kept/features/friends/presentation/friend_search_screen.dart';
import 'package:kept/features/friends/presentation/friends_screen.dart';
import 'package:kept/features/gifts/presentation/friend_gifts_screen.dart';
import 'package:kept/features/gifts/presentation/gift_detail_screen.dart';
import 'package:kept/features/gifts/presentation/gift_photo_compose_screen.dart';
import 'package:kept/features/gifts/presentation/gifts_screen.dart';
import 'package:kept/features/gifts/presentation/log_external_gift_screen.dart';
import 'package:kept/features/gifts/presentation/log_gift_screen.dart';
import 'package:kept/features/home/presentation/home_screen.dart';
import 'package:kept/features/invite/presentation/invite_screen.dart';
import 'package:kept/features/me/presentation/me_screen.dart';
import 'package:kept/features/onboarding/presentation/onboarding_screen.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/presentation/edit_profile_screen.dart';
import 'package:kept/features/profile/presentation/user_profile_screen.dart';
import 'package:kept/features/safety/presentation/blocked_users_screen.dart';
import 'package:kept/features/settings/presentation/privacy_screen.dart';
import 'package:kept/features/settings/presentation/settings_screen.dart';
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
const _profileGateTimeout = Duration(seconds: 5);

/// Only a change of *who* is signed in re-runs the redirect rules. A stream
/// error or a reload with the same user keeps the previous identity
/// (Riverpod keeps `value` across error/loading), so it is not a tick.
@visibleForTesting
bool authIdentityChanged(
  AsyncValue<String?>? previous,
  AsyncValue<String?> next,
) => previous == null || previous.value != next.value;

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier(0);
  ref
    ..onDispose(refresh.dispose)
    ..listen(authStateProvider, (previous, next) {
      if (authIdentityChanged(previous, next)) refresh.value++;
    })
    ..listen(devSessionProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) async {
      if (!Env.hasSupabaseConfig) return null;

      final devSession = ref.read(devSessionProvider);
      final signedIn = ref.read(authStateProvider).value != null || devSession;
      final location = state.matchedLocation;
      final onSignIn = location == '/sign-in';
      final onOnboarding = location == '/onboarding';

      if (!signedIn) return onSignIn ? null : '/sign-in';

      // Dev session has no profile machinery — just keep it off /sign-in.
      if (devSession && ref.read(authStateProvider).value == null) {
        return onSignIn ? '/' : null;
      }

      try {
        // A profile already loaded answers synchronously: no pending
        // redirect, no blank frame. Only a first load waits — with a hard
        // cap, since while an async redirect is pending go_router paints
        // nothing, and a slow session refresh would mean a blank screen.
        final known = ref.read(myProfileProvider);
        final profile = known.hasValue
            ? known.value
            : await ref
                  .read(myProfileProvider.future)
                  .timeout(_profileGateTimeout);
        if (profile == null) return onOnboarding ? null : '/onboarding';
      } catch (e) {
        // Profile check failed (offline, expired session, timeout): don't
        // trap the user; Home degrades per-section.
        debugPrint('router: profile gate skipped: $e');
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
        routes: [
          GoRoute(
            path: 'search',
            name: 'friend-search',
            builder: (context, state) => const FriendSearchScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/invite',
        name: 'invite',
        builder: (context, state) => const InviteScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'privacy',
            name: 'settings-privacy',
            builder: (context, state) => const PrivacyScreen(),
          ),
          GoRoute(
            path: 'blocked',
            name: 'settings-blocked',
            builder: (context, state) => const BlockedUsersScreen(),
          ),
        ],
      ),
      GoRoute(
        path: composePostRoute,
        name: 'compose-post',
        builder: (context, state) =>
            ComposePostScreen(imageBytes: state.extra! as Uint8List),
      ),
      GoRoute(
        path: '/events/for/:honoreeId',
        name: 'event-for-honoree',
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final date = q['date'];
          return EventForHonoreeScreen(
            honoreeId: state.pathParameters['honoreeId']!,
            kind: q['kind'] == null
                ? EventKind.birthday
                : EventKind.fromWire(q['kind']!),
            date: date == null ? null : DateTime.tryParse(date),
            title: q['title'],
          );
        },
      ),
      GoRoute(
        path: '/events/:id',
        name: 'event-detail',
        builder: (context, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/stories/:authorId',
        name: 'stories',
        builder: (context, state) => StoryViewerScreen(
          initialAuthorId: state.pathParameters['authorId']!,
        ),
      ),
      GoRoute(
        path: '/gifts/log',
        name: 'log-gift',
        builder: (context, state) => LogGiftScreen(
          initialRecipientId: state.uri.queryParameters['recipient'],
          eventId: state.uri.queryParameters['event'],
          claimId: state.uri.queryParameters['claim'],
          initialItem: state.uri.queryParameters['item'],
          initialUrl: state.uri.queryParameters['url'],
        ),
      ),
      GoRoute(
        path: '/gifts/:id/photo',
        name: 'gift-photo',
        builder: (context, state) => GiftPhotoComposeScreen(
          giftId: state.pathParameters['id']!,
          item: state.uri.queryParameters['item'] ?? '',
          imageBytes: state.extra! as Uint8List,
          storyOffered: state.uri.queryParameters['story'] == '1',
        ),
      ),
      GoRoute(
        path: '/gifts/log-external',
        name: 'log-external-gift',
        builder: (context, state) => const LogExternalGiftScreen(),
      ),
      // After the static /gifts/* routes: go_router matches in order.
      GoRoute(
        path: '/gifts/:id',
        name: 'gift-detail',
        builder: (context, state) => GiftDetailScreen(
          giftId: state.pathParameters['id']!,
          counterpartIsGiver: state.uri.queryParameters['side'] != 'recipient',
        ),
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
