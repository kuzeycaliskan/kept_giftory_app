import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/app.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/firebase/firebase_options.dart';
import 'package:kept/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App entry (pixels-first architecture).
///
/// runApp is called IMMEDIATELY — the first frame never waits on any SDK.
/// Supabase/Firebase initialize behind a visible launch screen with hard
/// timeouts; whatever hangs, the user sees UI, never a black screen. This
/// is the structural fix for the startup-hang class of bugs (a hung
/// Firebase.initializeApp once blackscreened the app for good).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A release build without Supabase config is always a build mistake
  // (forgotten --dart-define-from-file=.env). Fail loudly, visibly.
  if (kReleaseMode && !Env.hasSupabaseConfig) {
    runApp(const _ConfigErrorApp());
    return;
  }

  runApp(const _BootstrapGate());
}

/// Shows the launch screen while SDKs initialize, then swaps in the app.
class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate();

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  late final Future<void> _ready = _initialize();

  Future<void> _initialize() async {
    debugPrint('bootstrap: start');
    if (!Env.hasSupabaseConfig) return; // dev backend-less mode

    // Supabase first — the app is unusable without it, but even this gets
    // a hard cap so a pathological environment still reaches the UI (the
    // router then behaves as signed-out/backend-less rather than hanging).
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        // The dashboard still calls this the "anon" key; publishableKey is
        // the newer alias. Keep anonKey until we migrate the naming.
        // ignore: deprecated_member_use
        anonKey: Env.supabaseAnonKey,
      ).timeout(const Duration(seconds: 10));
      debugPrint('bootstrap: supabase done');
    } catch (e) {
      debugPrint('bootstrap: supabase init failed/timed out: $e');
    }

    // Firebase is a degradation (push + crash reporting), never a gate.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 5));
      _wireCrashlytics();
      debugPrint('bootstrap: firebase done');
    } catch (e) {
      debugPrint('bootstrap: firebase init failed/timed out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LaunchScreen();
        }
        debugPrint('bootstrap: runApp');
        return const ProviderScope(child: KeptApp());
      },
    );
  }
}

/// Branded launch frame: paints within the first frames, so startup is
/// never a black screen regardless of what init does.
class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/branding/icon.png',
                    width: 80,
                    height: 80,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Visible, actionable failure for a misbuilt release binary.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Build configuration error.\n\n'
              'Release build without Supabase config — rebuild with:\n'
              'flutter build ipa|appbundle --dart-define-from-file=.env',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Crash reporting (G-05): release builds only — debug noise stays local.
/// No PII is attached: Crashlytics receives anonymous crash/stack data
/// (privacy policy notes the processor).
void _wireCrashlytics() {
  final crashlytics = FirebaseCrashlytics.instance;
  // ignore: avoid_redundant_argument_values
  unawaited(crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode));
  if (kDebugMode) return;

  FlutterError.onError = crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(crashlytics.recordError(error, stack, fatal: true));
    return true;
  };
}
