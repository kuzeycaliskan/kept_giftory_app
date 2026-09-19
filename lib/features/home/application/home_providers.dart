import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/home/data/dev_home_repository.dart';
import 'package:kept/features/home/data/supabase_home_repository.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyHomeRepository();
  final client = ref.watch(supabaseClientProvider);
  // Debug-only bypass: no real session but dev mode on → sample data so Home
  // is testable before OAuth config lands (G-11).
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return DevHomeRepository();
  }
  return SupabaseHomeRepository(client);
}

/// Upper Home section: friends' upcoming birthdays (real data).
@riverpod
Future<List<UpcomingBirthday>> upcomingBirthdays(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).upcomingBirthdays();
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

/// Middle Home section: friends' latest wishlist additions (G-82).
@riverpod
Future<List<FriendWishlistItem>> friendWishlistFeed(Ref ref) async {
  final result = await ref
      .watch(homeRepositoryProvider)
      .recentFriendWishlistItems();
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

/// Lower Home section: my real social events (G-82; feed proper is V2/G-210).
@riverpod
Future<List<HomeEvent>> homeEvents(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).recentEvents();
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

/// "A surprise is coming" card data (G-210); null = nothing pending.
@riverpod
Future<SurpriseTeaser?> surpriseTeaser(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).surpriseTeaser();
  return result.when(
    success: (teaser) => teaser,
    failure: (failure) => throw failure,
  );
}
