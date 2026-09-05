import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
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

  final prefs = await ref.watch(sharedPreferencesProvider.future);
  if (prefs.getBool(PrefKeys.pushPrimingDismissed) ?? false) return false;

  final settings =
      await FirebaseMessaging.instance.getNotificationSettings();
  return settings.authorizationStatus == AuthorizationStatus.notDetermined ||
      settings.authorizationStatus == AuthorizationStatus.denied;
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
    if (!granted) return;
    await ref.read(pushSetupProvider.notifier).syncToken();
    FirebaseMessaging.instance
        .onTokenRefresh
        .listen((_) => ref.read(pushSetupProvider.notifier).syncToken());
  } catch (_) {
    // Push is a degradation; never let it break Home.
  }
}

/// Push setup actions driven by the priming card (G-61): soft-ask happened in
/// UI, this triggers the OS prompt and registers the token on success.
@riverpod
class PushSetup extends _$PushSetup {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns true when permission was granted and the token stored.
  Future<bool> enable() async {
    state = const AsyncLoading();
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (granted) {
        await syncToken();
        // Keep the stored token fresh across FCM rotations.
        messaging.onTokenRefresh.listen((_) => syncToken());
      }
      await _markDismissed();
      state = const AsyncData(null);
      ref.invalidate(shouldShowPushPrimingProvider);
      return granted;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
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
  Future<void> syncToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await ref.read(pushTokenRepositoryProvider).register(
          token: token,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
  }
}
