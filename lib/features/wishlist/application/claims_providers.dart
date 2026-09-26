import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/wishlist/data/supabase_claims_repository.dart';
import 'package:kept/features/wishlist/domain/claims_repository.dart';
import 'package:kept/features/wishlist/domain/wishlist_claim.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'claims_providers.g.dart';

@Riverpod(keepAlive: true)
ClaimsRepository claimsRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyClaimsRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return const EmptyClaimsRepository();
  }
  return SupabaseClaimsRepository(client);
}

/// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
@riverpod
Future<Map<String, WishlistClaim>> wishlistClaims(
  Ref ref,
  String ownerId,
) async {
  final result = await ref
      .watch(claimsRepositoryProvider)
      .fetchForOwner(ownerId);
  return result.when(success: (m) => m, failure: (f) => throw f);
}

/// Mutations on claims and pledges. Each method returns the failure (null
/// on success) so the row can explain a lost race in place; the list for
/// that owner is refreshed either way — the server is the truth.
@riverpod
class ClaimsController extends _$ClaimsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Failure?> claim(
    String ownerId,
    String itemId, {
    required ClaimKind kind,
    double? targetAmount,
  }) => _run(
    ownerId,
    () => ref
        .read(claimsRepositoryProvider)
        .claim(itemId, kind: kind, targetAmount: targetAmount),
  );

  /// Solo reservation that continues into the gift form: the claim row is
  /// needed for the form, so this returns it (null on failure; the state
  /// carries the failure).
  Future<WishlistClaim?> claimForGift(String ownerId, String itemId) async {
    state = const AsyncLoading();
    final result = await ref
        .read(claimsRepositoryProvider)
        .claim(itemId, kind: ClaimKind.solo);
    ref.invalidate(wishlistClaimsProvider(ownerId));
    return result.when(
      success: (claim) {
        state = const AsyncData(null);
        return claim;
      },
      failure: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
    );
  }

  Future<Failure?> release(String ownerId, String claimId) =>
      _run(ownerId, () => ref.read(claimsRepositoryProvider).release(claimId));

  Future<Failure?> makeShared(
    String ownerId,
    String claimId, {
    double? targetAmount,
  }) => _run(
    ownerId,
    () => ref
        .read(claimsRepositoryProvider)
        .makeShared(claimId, targetAmount: targetAmount),
  );

  Future<Failure?> pledge(String ownerId, String claimId, double amount) =>
      _run(
        ownerId,
        () => ref.read(claimsRepositoryProvider).pledge(claimId, amount),
      );

  Future<Failure?> withdrawPledge(
    String ownerId,
    String claimId,
    String userId,
  ) => _run(
    ownerId,
    () => ref.read(claimsRepositoryProvider).withdrawPledge(claimId, userId),
  );

  Future<Failure?> _run(
    String ownerId,
    Future<Result<Object?>> Function() action,
  ) async {
    state = const AsyncLoading();
    final result = await action();
    ref.invalidate(wishlistClaimsProvider(ownerId));
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return null;
      },
      failure: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
    );
  }
}
