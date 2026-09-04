import 'package:kept/core/error/result.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/domain/wishlist_repository.dart';

/// Debug-only in-memory wishlist so the dev session is fully walkable:
/// adds and deletes actually mutate the visible list. Never used in release.
class DevWishlistRepository implements WishlistRepository {
  DevWishlistRepository();

  static const _me = 'dev-me';

  final List<WishlistItem> _items = [
    const WishlistItem(id: 'dev-w1', ownerId: _me, title: 'Kindle'),
    const WishlistItem(
      id: 'dev-w2',
      ownerId: _me,
      title: 'Tennis racket',
      note: 'Head, grip 2',
    ),
  ];

  final Map<String, List<WishlistItem>> _friends = {
    'dev-ali': const [
      WishlistItem(id: 'dev-wa1', ownerId: 'dev-ali', title: 'Ski goggles'),
      WishlistItem(
        id: 'dev-wa2',
        ownerId: 'dev-ali',
        title: 'Coffee grinder',
        url: 'https://example.com/grinder',
      ),
    ],
    'dev-zeynep': const [
      WishlistItem(
        id: 'dev-wz1',
        ownerId: 'dev-zeynep',
        title: 'Wireless earbuds',
      ),
    ],
  };

  int _nextId = 0;

  @override
  Future<Result<List<WishlistItem>>> fetchMine() async =>
      Success(List.unmodifiable(_items));

  @override
  Future<Result<List<WishlistItem>>> fetchFor(String profileId) async =>
      Success(_friends[profileId] ?? const []);

  @override
  Future<Result<WishlistItem>> add({
    required String title,
    String? note,
    String? url,
  }) async {
    final item = WishlistItem(
      id: 'dev-new-${_nextId++}',
      ownerId: _me,
      title: title.trim(),
      note: note,
      url: url,
    );
    _items.add(item);
    return Success(item);
  }

  @override
  Future<Result<void>> delete(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    return const Success(null);
  }
}

/// Backend-less fallback (no --dart-define config).
class EmptyWishlistRepository implements WishlistRepository {
  const EmptyWishlistRepository();

  @override
  Future<Result<List<WishlistItem>>> fetchMine() async => const Success([]);

  @override
  Future<Result<List<WishlistItem>>> fetchFor(String profileId) async =>
      const Success([]);

  @override
  Future<Result<WishlistItem>> add({
    required String title,
    String? note,
    String? url,
  }) async =>
      Success(WishlistItem(id: 'noop', ownerId: 'noop', title: title));

  @override
  Future<Result<void>> delete(String itemId) async => const Success(null);
}
