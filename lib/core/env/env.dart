/// Compile-time environment configuration, injected via `--dart-define`.
///
/// Never hard-code secrets. Only the Supabase anon key ships in the client
/// (it is RLS-gated); service-role keys live only in Edge Functions.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Google OAuth client ids (G-11). Empty until created in Google Cloud;
  /// native Google sign-in needs the WEB client id as `serverClientId` so the
  /// resulting idToken is accepted by Supabase.
  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String googleIosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  /// Whether Supabase credentials were provided at build time.
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
