import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// The app-wide [SupabaseClient].
///
/// UI must NOT use this directly — data access goes through repositories
/// (CLAUDE.md §3). Repository implementations depend on this provider so the
/// backend stays swappable (self-host escape hatch).
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
