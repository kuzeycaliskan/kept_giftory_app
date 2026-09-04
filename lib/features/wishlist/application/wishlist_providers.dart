import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/wishlist/data/dev_wishlist_repository.dart';
import 'package:kept/features/wishlist/data/supabase_wishlist_repository.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wishlist_providers.g.dart';

@Riverpod(keepAlive: true)
WishlistRepository wishlistRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyWishlistRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    // keepAlive → the in-memory dev list survives across screens.
    return DevWishlistRepository();
  }
  return SupabaseWishlistRepository(client);
}

@riverpod
Future<List<WishlistItem>> myWishlist(Ref ref) async {
  final result = await ref.watch(wishlistRepositoryProvider).fetchMine();
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

/// A friend's wishlist; RLS decides what the caller may see.
@riverpod
Future<List<WishlistItem>> friendWishlist(Ref ref, String profileId) async {
  final result =
      await ref.watch(wishlistRepositoryProvider).fetchFor(profileId);
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

@riverpod
class WishlistController extends _$WishlistController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// True on success (form pops on true).
  Future<bool> add({
    required String title,
    String? note,
    String? url,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(wishlistRepositoryProvider)
        .add(title: title, note: note, url: url);
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        ref.invalidate(myWishlistProvider);
        return true;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }

  Future<void> delete(String itemId) async {
    state = const AsyncLoading();
    final result = await ref.read(wishlistRepositoryProvider).delete(itemId);
    result.when(
      success: (_) {
        state = const AsyncData(null);
        ref.invalidate(myWishlistProvider);
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
      },
    );
  }
}
