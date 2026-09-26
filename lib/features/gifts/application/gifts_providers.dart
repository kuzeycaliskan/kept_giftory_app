import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/media/media_providers.dart';
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
  return SupabaseGiftRepository(client, ref.watch(mediaStoreProvider));
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

/// One gift with photos, for the detail screen. Refetched (not read from
/// the list caches) so photo edits show without juggling three lists.
@riverpod
Future<GiftEntry?> giftDetail(
  Ref ref,
  String giftId, {
  required bool counterpartIsGiver,
}) async {
  final result = await ref
      .watch(giftRepositoryProvider)
      .fetchGift(giftId, counterpartIsGiver: counterpartIsGiver);
  return result.when(
    success: (gift) => gift,
    failure: (failure) => throw failure,
  );
}

@riverpod
class GiftsController extends _$GiftsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// The created gift on success (forms attach photos to it), else null.
  /// Records a gift from a non-member (G-212); lands in Received.
  Future<GiftEntry?> logExternal({
    required GiftRelation relation,
    required String item,
    required DateTime giftDate,
    String? note,
    String? linkPreviewId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(giftRepositoryProvider)
        .logExternal(
          relation: relation,
          item: item,
          giftDate: giftDate,
          note: note,
          linkPreviewId: linkPreviewId,
        );
    return result.when(
      success: (gift) {
        state = const AsyncData(null);
        ref.invalidate(receivedGiftsProvider);
        return gift;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
    );
  }

  Future<GiftEntry?> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
    String? linkPreviewId,
    String? eventId,
    String? claimId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(giftRepositoryProvider)
        .log(
          recipientId: recipientId,
          item: item,
          giftDate: giftDate,
          linkPreviewId: linkPreviewId,
          eventId: eventId,
          claimId: claimId,
          isSurprise: isSurprise,
          note: note,
          revealAt: revealAt,
        );
    return result.when(
      success: (gift) {
        state = const AsyncData(null);
        ref.invalidate(givenGiftsProvider);
        return gift;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
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
