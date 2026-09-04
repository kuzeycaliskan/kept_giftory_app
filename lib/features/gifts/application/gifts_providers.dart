import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/gifts/data/dev_gift_repository.dart';
import 'package:kept/features/gifts/data/supabase_gift_repository.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gifts_providers.g.dart';

@Riverpod(keepAlive: true)
GiftRepository giftRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyGiftRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return DevGiftRepository();
  }
  return SupabaseGiftRepository(client);
}

@riverpod
Future<List<GiftEntry>> givenGifts(Ref ref) async {
  final result = await ref.watch(giftRepositoryProvider).fetchGiven();
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

@riverpod
Future<List<GiftEntry>> receivedGifts(Ref ref) async {
  final result = await ref.watch(giftRepositoryProvider).fetchReceived();
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

/// A friend's gift history (G-52); RLS applies visibility + surprise rules.
@riverpod
Future<List<GiftEntry>> friendGiftHistory(Ref ref, String profileId) async {
  final result = await ref.watch(giftRepositoryProvider).fetchFor(profileId);
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

@riverpod
class GiftsController extends _$GiftsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// True on success (form pops on true).
  Future<bool> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(giftRepositoryProvider).log(
          recipientId: recipientId,
          item: item,
          giftDate: giftDate,
          isSurprise: isSurprise,
          note: note,
          revealAt: revealAt,
        );
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        ref.invalidate(givenGiftsProvider);
        return true;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }

  Future<void> delete(String giftId) async {
    state = const AsyncLoading();
    final result = await ref.read(giftRepositoryProvider).delete(giftId);
    result.when(
      success: (_) {
        state = const AsyncData(null);
        ref.invalidate(givenGiftsProvider);
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
      },
    );
  }
}
