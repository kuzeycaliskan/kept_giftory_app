import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/profile/data/dev_profile_repository.dart';
import 'package:kept/features/profile/data/supabase_profile_repository.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyProfileRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return const DevProfileRepository();
  }
  return SupabaseProfileRepository(client);
}

/// The signed-in user's profile; null while onboarding is incomplete.
@riverpod
Future<Profile?> myProfile(Ref ref) async {
  final result = await ref.watch(profileRepositoryProvider).fetchMyProfile();
  return result.when(
    success: (profile) => profile,
    failure: (failure) => throw failure,
  );
}

/// Another user's profile; null when RLS hides it (G-84).
@riverpod
Future<Profile?> userProfile(Ref ref, String profileId) async {
  final result =
      await ref.watch(profileRepositoryProvider).fetchProfile(profileId);
  return result.when(
    success: (profile) => profile,
    failure: (failure) => throw failure,
  );
}
