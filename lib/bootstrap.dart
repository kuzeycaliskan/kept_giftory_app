import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/app.dart';
import 'package:kept/core/env/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App entry pipeline: bindings → Supabase init (if configured) → run app.
///
/// Supabase is initialized only when credentials are provided via
/// `--dart-define`, so the skeleton runs without a backend during early dev.
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
  }

  runApp(const ProviderScope(child: KeptApp()));
}
