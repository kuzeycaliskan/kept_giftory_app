import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/router/app_router.dart';
import 'package:kept/core/theme/app_theme.dart';

/// Root application widget. Wires the router, theme, localization and push
/// tap-routing; all app-wide config lives here.
class KeptApp extends ConsumerStatefulWidget {
  const KeptApp({super.key});

  @override
  ConsumerState<KeptApp> createState() => _KeptAppState();
}

class _KeptAppState extends ConsumerState<KeptApp> {
  @override
  void initState() {
    super.initState();
    // Notification taps carry a `route` in data (G-62) — navigate there.
    // Backend-less runs (tests, early dev) have no Firebase: skip entirely.
    if (Env.hasSupabaseConfig) _hookPushNavigation();
  }

  void _hookPushNavigation() {
    void goTo(RemoteMessage message) {
      final route = message.data['route'];
      if (route is String && route.isNotEmpty) {
        ref.read(appRouterProvider).push(route);
      }
    }

    try {
      // Cold start from a notification.
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) goTo(message);
      });
      // Background → foreground via notification tap.
      FirebaseMessaging.onMessageOpenedApp.listen(goTo);
    } catch (e) {
      debugPrint('Push navigation hook failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
