import 'package:firebase_core/firebase_core.dart';
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
    } catch (e) {
      // Push is a degradation, not a hard dependency.
      debugPrint('Firebase init failed — continuing without push: $e');
    }
  }

  runApp(const ProviderScope(child: KeptApp()));
}
