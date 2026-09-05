import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/prefs/prefs_providers.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/push/data/supabase_push_token_repository.dart';
import 'package:kept/features/push/domain/push_token_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_providers.g.dart';

@Riverpod(keepAlive: true)
PushTokenRepository pushTokenRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const NoopPushTokenRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return const NoopPushTokenRepository();
  }
  return SupabasePushTokenRepository(client);
}

/// Whether the Home priming card should show: signed-in real session, push
/// permission not granted yet, and the user hasn't dismissed the card.
@riverpod
Future<bool> shouldShowPushPriming(Ref ref) async {
  if (!Env.hasSupabaseConfig) return false;
  final client = ref.watch(supabaseClientProvider);
  if (client.auth.currentUser == null) return false;

  final status =
      (await FirebaseMessaging.instance.getNotificationSettings())
          .authorizationStatus;

  // Never asked → always offer: "Later" isn't a real decision yet, so the
  // dismissal flag doesn't suppress the card here.
  if (status == AuthorizationStatus.notDetermined) return true;

  // Actively denied → respect the dismissal (re-enable via settings, G-85).
  if (status == AuthorizationStatus.denied) {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return !(prefs.getBool(PrefKeys.pushPrimingDismissed) ?? false);
  }

  return false; // authorized / provisional
}

/// Silent token sync: when permission is already granted, keep the stored
/// token fresh on app start (covers FCM rotation, reinstalls, and the case
/// where the first registration failed — e.g. iOS before the APNs
/// entitlement existed). Watched fire-and-forget from Home.
@Riverpod(keepAlive: true)
Future<void> pushTokenSync(Ref ref) async {
  if (!Env.hasSupabaseConfig) return;
  final client = ref.watch(supabaseClientProvider);
  if (client.auth.currentUser == null) return;
  try {
    final settings =
        await FirebaseMessaging.instance.getNotificationSettings();
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!granted) {
      debugPrint('pushTokenSync: permission not granted '
          '(${settings.authorizationStatus})');
      return;
    }
    await ref.read(pushSetupProvider.notifier).syncToken();
    FirebaseMessaging.instance
        .onTokenRefresh
        .listen((_) => ref.read(pushSetupProvider.notifier).syncToken());
  } catch (e) {
    // Push is a degradation; never let it break Home.
    debugPrint('pushTokenSync failed: $e');
  }
}

/// Push setup actions driven by the priming card (G-61): soft-ask happened in
/// UI, this triggers the OS prompt and registers the token on success.
@riverpod
class PushSetup extends _$PushSetup {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns true when permission was granted. Token storage is best-effort
  /// here — the card must dismiss on a permission answer no matter what, and
  /// pushTokenSync self-heals a failed first registration on next launch.
  Future<bool> enable() async {
    state = const AsyncLoading();
    var granted = false;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (granted) {
        // Fire-and-forget: token sync polls for the APNs token (up to ~10s on
        // iOS) — never block the card dismissal on it.
        unawaited(syncToken());
        messaging.onTokenRefresh.listen((_) => syncToken());
      }
    } finally {
      await _markDismissed();
      state = const AsyncData(null);
      ref.invalidate(shouldShowPushPrimingProvider);
    }
    return granted;
  }

  /// "Later": hide the card without prompting; re-enable lives in G-63/G-85.
  Future<void> dismiss() async {
    await _markDismissed();
    ref.invalidate(shouldShowPushPrimingProvider);
  }

  Future<void> _markDismissed() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PrefKeys.pushPrimingDismissed, true);
  }

  /// Fetch the current FCM token and upsert it for the signed-in user.
  ///
  /// iOS quirk: FCM can't mint a token until Apple delivers the APNs token,
  /// which arrives asynchronously after launch — poll briefly before asking.
  Future<void> syncToken() async {
    final messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      for (var attempt = 0; attempt < 10; attempt++) {
        if (await messaging.getAPNSToken() != null) break;
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      if (await messaging.getAPNSToken() == null) {
        debugPrint('pushTokenSync: APNs token never arrived');
        return;
      }
    }
    final token = await messaging.getToken();
    debugPrint('pushTokenSync: fcm token ${token == null ? 'NULL' : 'ok'}');
    if (token == null) return;
    final result = await ref.read(pushTokenRepositoryProvider).register(
          token: token,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
    result.when(
      success: (_) => debugPrint('pushTokenSync: registered'),
      failure: (f) => debugPrint('pushTokenSync: register failed: $f'),
    );
  }
}
