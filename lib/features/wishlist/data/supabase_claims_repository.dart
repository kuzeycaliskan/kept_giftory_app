import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/wishlist/domain/claims_repository.dart';
import 'package:kept/features/wishlist/domain/wishlist_claim.dart';
import 'package:kept/shared/data/profile_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClaimsRepository implements ClaimsRepository {
  SupabaseClaimsRepository(this._client);

  final SupabaseClient _client;

  static const _claims = 'wishlist_claims';
  static const _pledges = 'claim_pledges';
  static const _select =
      'id, item_id, owner_id, claimer_id, kind, target_amount, '
      'pledges:claim_pledges(user_id, amount)';

  String get _me => _client.auth.currentUser?.id ?? '';

  @override
  Future<Result<Map<String, WishlistClaim>>> fetchForOwner(
    String ownerId,
  ) async {
    try {
      final rows = await _client
          .from(_claims)
          .select(_select)
          .eq('owner_id', ownerId);
      final ids = <String>{
        for (final row in rows) row['claimer_id'] as String,
        for (final row in rows)
          for (final p in (row['pledges'] as List<dynamic>? ?? const []))
            (p as Map<String, dynamic>)['user_id'] as String,
      };
      final cards = await fetchProfileCards(_client, ids);
      return Success({
        for (final row in rows)
          row['item_id'] as String: _claimFromRow(row, cards),
      });
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<WishlistClaim>> claim(
    String itemId, {
    required ClaimKind kind,
    double? targetAmount,
  }) async {
    try {
      final row = await _client
          .from(_claims)
          .insert({
            'item_id': itemId,
            'claimer_id': _me,
            'kind': kind.name,
            if (targetAmount != null) 'target_amount': targetAmount,
          })
          .select(_select)
          .single();
      return Success(_claimFromRow(row, const {}));
    } on PostgrestException catch (e) {
      // 23505 = the item's single claim slot is taken.
      if (e.code == '23505') return const ResultFailure(ConflictFailure());
      if (e.code == '42501') return const ResultFailure(PermissionFailure());
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> release(String claimId) =>
      _run(() => _client.from(_claims).delete().eq('id', claimId));

  @override
  Future<Result<void>> makeShared(String claimId, {double? targetAmount}) =>
      _run(
        () => _client
            .from(_claims)
            .update({
              'kind': ClaimKind.shared.name,
              'target_amount': targetAmount,
            })
            .eq('id', claimId),
      );

  @override
  Future<Result<void>> pledge(String claimId, double amount) => _run(
    () => _client.from(_pledges).upsert({
      'claim_id': claimId,
      'user_id': _me,
      'amount': amount,
    }, onConflict: 'claim_id,user_id'),
  );

  @override
  Future<Result<void>> withdrawPledge(String claimId, String userId) => _run(
    () => _client
        .from(_pledges)
        .delete()
        .eq('claim_id', claimId)
        .eq('user_id', userId),
  );

  Future<Result<void>> _run(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } on PostgrestException catch (e) {
      if (e.code == '42501') return const ResultFailure(PermissionFailure());
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  static WishlistClaim _claimFromRow(
    Map<String, dynamic> row,
    Map<String, ProfileCard> cards,
  ) {
    final pledges = (row['pledges'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final claimerId = row['claimer_id'] as String;
    return WishlistClaim(
      id: row['id'] as String,
      itemId: row['item_id'] as String,
      ownerId: row['owner_id'] as String,
      claimerId: claimerId,
      kind: ClaimKind.values.byName(row['kind'] as String),
      targetAmount: _amount(row['target_amount']),
      claimer: cards[claimerId],
      pledges: [
        for (final p in pledges)
          Pledge(
            userId: p['user_id'] as String,
            amount: _amount(p['amount']) ?? 0,
            user: cards[p['user_id'] as String],
          ),
      ],
    );
  }

  /// numeric(12,2) arrives as a string or number depending on the path.
  static double? _amount(Object? raw) => switch (raw) {
    null => null,
    final num n => n.toDouble(),
    final String s => double.tryParse(s),
    _ => null,
  };
}

/// Backend-less runs (no --dart-define config) and the dev session: the
/// friend's list renders without reservation controls.
class EmptyClaimsRepository implements ClaimsRepository {
  const EmptyClaimsRepository();

  static const _offline = ResultFailure<Never>(
    NetworkFailure('No backend configured'),
  );

  @override
  Future<Result<Map<String, WishlistClaim>>> fetchForOwner(
    String ownerId,
  ) async => const Success({});

  @override
  Future<Result<WishlistClaim>> claim(
    String itemId, {
    required ClaimKind kind,
    double? targetAmount,
  }) async => _offline;

  @override
  Future<Result<void>> release(String claimId) async => _offline;

  @override
  Future<Result<void>> makeShared(
    String claimId, {
    double? targetAmount,
  }) async => _offline;

  @override
  Future<Result<void>> pledge(String claimId, double amount) async => _offline;

  @override
  Future<Result<void>> withdrawPledge(String claimId, String userId) async =>
      _offline;
}
