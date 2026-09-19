import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/presentation/reaction_bar.dart';
import 'package:kept/features/gifts/application/gift_comment_target.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:kept/shared/widgets/comments_sheet.dart';

/// Reaction pill (left) + comment pill (right) for a gift — the same row on
/// the detail screen and Home cards. The comments sheet carries the
/// reaction summary and the "who reacted" list.
class GiftReactionRow extends ConsumerWidget {
  const GiftReactionRow({
    required this.gift,
    required this.myId,
    required this.onReact,
    super.key,
  });

  final GiftEntry gift;
  final String? myId;
  final ValueChanged<ReactionKind> onReact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ReactionButton(reactions: gift.reactions, myId: myId, onReact: onReact),
        const SizedBox(width: KeptSpacing.sm),
        Expanded(
          child: CommentPill(
            count: gift.commentCount,
            onTap: () => showCommentsSheet(
              context,
              target: GiftCommentTarget(
                ref.read(giftRepositoryProvider),
                gift,
                onChanged: () => ref
                  ..invalidate(givenGiftsProvider)
                  ..invalidate(receivedGiftsProvider)
                  ..invalidate(friendGiftHistoryProvider)
                  ..invalidate(giftDetailProvider)
                  ..invalidate(homeEventsProvider),
              ),
              viewerId: myId,
              reactions: gift.reactions,
              onReactionsTap: () =>
                  showReactorsSheet(context, reactions: gift.reactions),
            ),
          ),
        ),
      ],
    );
  }
}
