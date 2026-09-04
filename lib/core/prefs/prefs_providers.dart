import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'prefs_providers.g.dart';

/// Local (device-only) preferences — UI niceties like "don't show again".
/// Anything with product meaning belongs in Postgres, not here.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();

/// Preference keys live here so they're greppable and collision-free.
abstract final class PrefKeys {
  static const hideSurpriseOffWarning = 'hide_surprise_off_warning';
}
