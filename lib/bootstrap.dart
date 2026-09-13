import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/app.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/firebase/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App entry pipeline: bindings → Supabase + Firebase init (if configured)
/// → run app.
///
/// Supabase is initialized only when credentials are provided via
/// `--dart-define`, so the skeleton runs without a backend during early dev.
/// Firebase (FCM, G-61) fails soft: a missing/broken config logs and the app
/// runs without push rather than crashing.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Backend-less mode is a DEV convenience only. A release build without
  // Supabase config is always a build mistake (forgotten
  // --dart-define-from-file=.env) — fail loudly instead of shipping a
  // hollow app to TestFlight/stores.
  if (kReleaseMode && !Env.hasSupabaseConfig) {
    throw StateError(
      'Release build without Supabase config. '
      'Build with: flutter build ipa|appbundle --dart-define-from-file=.env',
    );
  }

  if (Env.hasSupabaseConfig) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // The Supabase dashboard still issues an "anon" key; `publishableKey` is
      // the newer alias. Keep `anonKey` until we migrate the naming.
      // ignore: deprecated_member_use
      anonKey: Env.supabaseAnonKey,
    );
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _wireCrashlytics();
    } catch (e) {
      // Push/crash reporting are degradations, not hard dependencies.
      debugPrint('Firebase init failed — continuing without push: $e');
    }
  }

  runApp(const ProviderScope(child: KeptApp()));
}

/// Crash reporting (G-05): release builds only — debug noise stays local.
/// No PII is attached: Crashlytics receives anonymous crash/stack data
/// (privacy policy notes the processor).
void _wireCrashlytics() {
  final crashlytics = FirebaseCrashlytics.instance;
  // ignore: avoid_redundant_argument_values
  unawaited(crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode));
  if (kDebugMode) return;

  // Flutter framework errors (build/layout/gesture).
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  // Uncaught async/zone errors.
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(crashlytics.recordError(error, stack, fatal: true));
    return true;
  };
}
