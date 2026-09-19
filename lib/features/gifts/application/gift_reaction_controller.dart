import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gift_reaction_controller.g.dart';

/// Reactions on gifts (G-210 slice 2): same rule as moments — tapping the
/// kind you already chose clears it, any other kind sets it.
@riverpod
class GiftReactionController extends _$GiftReactionController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> react(
    GiftEntry gift,
    ReactionKind kind, {
    required String? myId,
  }) async {
    final repository = ref.read(giftRepositoryProvider);
    final result = gift.reactionOf(myId) == kind
        ? await repository.clearReaction(gift.id)
        : await repository.setReaction(gift.id, kind);
    return result.when(
      success: (_) {
        // Gifts show on every surface; refresh them all.
        ref
          ..invalidate(givenGiftsProvider)
          ..invalidate(receivedGiftsProvider)
          ..invalidate(friendGiftHistoryProvider)
          ..invalidate(giftDetailProvider)
          ..invalidate(homeEventsProvider);
        return true;
      },
      failure: (Failure failure) {
        debugPrint('gift reaction failed: $failure');
        return false;
      },
    );
  }
}
