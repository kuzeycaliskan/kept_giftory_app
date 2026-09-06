import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/router/app_router.dart';
import 'package:kept/core/theme/app_theme.dart';
import 'package:kept/features/push/application/foreground_notifications.dart';

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
    if (Env.hasSupabaseConfig) unawaited(_hookPushNavigation());
  }

  void _routeFromData(Map<String, dynamic> data) {
    final route = data['route'];
    if (route is String && route.isNotEmpty) {
      ref.read(appRouterProvider).push(route);
    }
  }

  Future<void> _hookPushNavigation() async {
    try {
      // Show foreground notifications (OS suppresses them); route their taps.
      await ForegroundNotifications.initialize(onTap: _routeFromData);
      // Cold start from a notification.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _routeFromData(initial.data);
      // Background → foreground via notification tap.
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _routeFromData(message.data),
      );
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
