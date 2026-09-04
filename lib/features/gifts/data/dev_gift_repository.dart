import 'package:kept/core/error/result.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';

/// Debug-only in-memory gifts so the dev session is fully walkable.
class DevGiftRepository implements GiftRepository {
  DevGiftRepository();

  final List<GiftEntry> _given = [
    GiftEntry(
      id: 'dev-g1',
      item: 'AirPods',
      giftDate: DateTime.now().subtract(const Duration(days: 90)),
      isSurprise: false,
      counterpartId: 'dev-ali',
      counterpartLabel: 'Ali',
    ),
    GiftEntry(
      id: 'dev-g2',
      item: 'Secret watch',
      giftDate: DateTime.now().subtract(const Duration(days: 2)),
      isSurprise: true,
      revealAt: DateTime.now().add(const Duration(days: 5)),
      counterpartId: 'dev-zeynep',
      counterpartLabel: 'Zeynep',
    ),
  ];

  final List<GiftEntry> _received = [
    GiftEntry(
      id: 'dev-r1',
      item: 'Board game',
      giftDate: DateTime.now().subtract(const Duration(days: 30)),
      isSurprise: false,
      counterpartId: 'dev-mert',
      counterpartLabel: 'Mert',
    ),
  ];

  int _nextId = 0;

  @override
  Future<Result<List<GiftEntry>>> fetchGiven() async =>
      Success(List.unmodifiable(_given));

  @override
  Future<Result<List<GiftEntry>>> fetchReceived() async =>
      Success(List.unmodifiable(_received));

  @override
  Future<Result<List<GiftEntry>>> fetchFor(String profileId) async => Success([
        for (final g in _given)
          if (g.counterpartId == profileId && !g.isPendingSurprise) g,
      ]);

  @override
  Future<Result<GiftEntry>> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
  }) async {
    final entry = GiftEntry(
      id: 'dev-new-${_nextId++}',
      item: item.trim(),
      note: note,
      giftDate: giftDate,
      isSurprise: isSurprise,
      revealAt: revealAt,
      counterpartId: recipientId,
      counterpartLabel: recipientId.replaceFirst('dev-', ''),
    );
    _given.insert(0, entry);
    return Success(entry);
  }

  @override
  Future<Result<void>> delete(String giftId) async {
    _given.removeWhere((g) => g.id == giftId);
    return const Success(null);
  }
}

/// Backend-less fallback (no --dart-define config).
class EmptyGiftRepository implements GiftRepository {
  const EmptyGiftRepository();

  @override
  Future<Result<List<GiftEntry>>> fetchGiven() async => const Success([]);

  @override
  Future<Result<List<GiftEntry>>> fetchReceived() async => const Success([]);

  @override
  Future<Result<List<GiftEntry>>> fetchFor(String profileId) async =>
      const Success([]);

  @override
  Future<Result<GiftEntry>> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
  }) async =>
      Success(
        GiftEntry(
          id: 'noop',
          item: item,
          giftDate: giftDate,
          isSurprise: isSurprise,
        ),
      );

  @override
  Future<Result<void>> delete(String giftId) async => const Success(null);
}
