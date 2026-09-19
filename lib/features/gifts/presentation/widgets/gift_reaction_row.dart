import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/presentation/reaction_bar.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/shared/domain/reaction.dart';

/// Reaction pill for a gift (light surfaces) plus a "who reacted" link
/// when there is anyone to list. Used by the detail screen and Home cards.
class GiftReactionRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Left: the reaction pill. Right: who reacted (comments land here next).
    return Row(
      children: [
        ReactionButton(reactions: gift.reactions, myId: myId, onReact: onReact),
        const SizedBox(width: KeptSpacing.sm),
        if (gift.reactions.isNotEmpty)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    showReactorsSheet(context, reactions: gift.reactions),
                child: Text(context.l10n.reactionsWhoReacted),
              ),
            ),
          ),
      ],
    );
  }
}
