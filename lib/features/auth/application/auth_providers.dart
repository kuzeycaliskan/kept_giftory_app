import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/data/supabase_auth_repository.dart';
import 'package:kept/features/auth/domain/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    SupabaseAuthRepository(ref.watch(supabaseClientProvider));

/// Reactive auth state: user id or null. Drives router redirects.
@Riverpod(keepAlive: true)
Stream<String?> authState(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges();
