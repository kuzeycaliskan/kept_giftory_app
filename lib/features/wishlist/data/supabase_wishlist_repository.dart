import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [WishlistRepository].
class SupabaseWishlistRepository implements WishlistRepository {
  SupabaseWishlistRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'wishlist_items';

  @override
  Future<Result<List<WishlistItem>>> fetchMine() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    return _fetchFor(userId);
  }

  @override
  Future<Result<List<WishlistItem>>> fetchFor(String profileId) =>
      _fetchFor(profileId);

  Future<Result<List<WishlistItem>>> _fetchFor(String ownerId) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('owner_id', ownerId)
          .order('created_at');
      return Success(rows.map(WishlistItem.fromJson).toList());
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<WishlistItem>> add({
    required String title,
    String? note,
    String? url,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed.length > 200) {
      return const ResultFailure(ValidationFailure('Invalid title'));
    }
    try {
      final row = await _client
          .from(_table)
          .insert({
            'owner_id': userId,
            'title': trimmed,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            if (url != null && url.trim().isNotEmpty) 'url': url.trim(),
          })
          .select()
          .single();
      return Success(WishlistItem.fromJson(row));
    } on PostgrestException catch (e) {
      // 23514 = check constraint (title length) → validation, not network.
      if (e.code == '23514') {
        return const ResultFailure(ValidationFailure('Invalid title'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String itemId) async {
    try {
      await _client.from(_table).delete().eq('id', itemId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
