import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/feed/domain/reaction.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';

/// Glyph per kind. Reactions are the one place emoji are the content itself
/// (design.md: never as icons or decoration).
String reactionGlyph(ReactionKind kind) => switch (kind) {
  ReactionKind.heart => '❤️',
  ReactionKind.congrats => '🎉',
  ReactionKind.like => '👍',
  ReactionKind.ok => '👌',
  ReactionKind.wow => '😮',
};

String reactionLabel(BuildContext context, ReactionKind kind) {
  final l10n = context.l10n;
  return switch (kind) {
    ReactionKind.heart => l10n.reactionHeart,
    ReactionKind.congrats => l10n.reactionCongrats,
    ReactionKind.like => l10n.reactionLike,
    ReactionKind.ok => l10n.reactionOk,
    ReactionKind.wow => l10n.reactionWow,
  };
}

/// Viewer-side bar under a friend's moment: five kinds, the viewer's choice
/// highlighted, counts beside each kind that has any. Sits on the dark
/// story stage, hence white chrome (same exception as the viewer).
class ReactionBar extends StatelessWidget {
  const ReactionBar({
    required this.post,
    required this.myId,
    required this.onReact,
    super.key,
  });

  final Post post;
  final String? myId;
  final ValueChanged<ReactionKind> onReact;

  @override
  Widget build(BuildContext context) {
    final mine = post.reactionOf(myId);
    final counts = post.reactionCounts;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final kind in ReactionKind.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KeptSpacing.xs),
            child: _ReactionChip(
              glyph: reactionGlyph(kind),
              label: reactionLabel(context, kind),
              count: counts[kind] ?? 0,
              selected: mine == kind,
              onTap: () => onReact(kind),
            ),
          ),
      ],
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.glyph,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String glyph;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: count > 0 ? '$label $count' : label,
      child: Material(
        color: selected ? scheme.primary : Colors.white24,
        borderRadius: KeptRadius.pillAll,
        child: InkWell(
          borderRadius: KeptRadius.pillAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KeptSpacing.md,
              vertical: KeptSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(glyph, style: const TextStyle(fontSize: 20)),
                if (count > 0) ...[
                  const SizedBox(width: KeptSpacing.xs),
                  Text(
                    '$count',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Author-side summary under their own moment: "❤️ 3 · 🎉 1", tap for the
/// list of who reacted. Nothing to show → quiet hint.
class ReactionSummary extends StatelessWidget {
  const ReactionSummary({
    required this.post,
    this.onSheetOpened,
    this.onSheetClosed,
    super.key,
  });

  final Post post;

  /// The story player pauses while the list is open and resumes after.
  final VoidCallback? onSheetOpened;
  final VoidCallback? onSheetClosed;

  @override
  Widget build(BuildContext context) {
    final counts = post.reactionCounts;
    final l10n = context.l10n;
    final text = counts.isEmpty
        ? l10n.reactionsEmpty
        : counts.entries
              .map((e) => '${reactionGlyph(e.key)} ${e.value}')
              .join(' · ');
    return Center(
      child: Material(
        color: Colors.white24,
        borderRadius: KeptRadius.pillAll,
        child: InkWell(
          borderRadius: KeptRadius.pillAll,
          onTap: counts.isEmpty ? null : () => _showReactors(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KeptSpacing.lg,
              vertical: KeptSpacing.sm,
            ),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReactors(BuildContext context) async {
    final l10n = context.l10n;
    onSheetOpened?.call();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KeptSpacing.lg,
                0,
                KeptSpacing.lg,
                KeptSpacing.sm,
              ),
              child: Text(
                l10n.reactionsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final r in post.reactions)
              ListTile(
                leading: KeptAvatar(
                  label: r.user?.displayName ?? r.user?.username ?? '?',
                  avatarValue: r.user?.avatarUrl,
                ),
                title: Text(
                  r.user?.displayName ??
                      r.user?.username ??
                      l10n.giftAnonymousGiver,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  reactionGlyph(r.kind),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
          ],
        ),
      ),
    );
    onSheetClosed?.call();
  }
}
