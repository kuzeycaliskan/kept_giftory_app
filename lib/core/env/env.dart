/// Compile-time environment configuration, injected via `--dart-define`.
///
/// Never hard-code secrets. Only the Supabase anon key ships in the client
/// (it is RLS-gated); service-role keys live only in Edge Functions.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Whether Supabase credentials were provided at build time.
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
