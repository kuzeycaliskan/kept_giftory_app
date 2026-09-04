import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/profile/data/supabase_profile_repository.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    SupabaseProfileRepository(ref.watch(supabaseClientProvider));

/// The signed-in user's profile; null while onboarding is incomplete.
@riverpod
Future<Profile?> myProfile(Ref ref) async {
  final result = await ref.watch(profileRepositoryProvider).fetchMyProfile();
  return result.when(
    success: (profile) => profile,
    failure: (failure) => throw failure,
  );
}
