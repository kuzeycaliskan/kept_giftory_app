import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/shared/domain/reaction.dart';
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

/// Five kinds, the viewer's choice highlighted, counts beside each kind
/// that has any. [onDark] = white chrome for the story stage; otherwise
/// theme surface colours (gift detail, Home cards).
class ReactionBar extends StatelessWidget {
  const ReactionBar({
    required this.reactions,
    required this.myId,
    required this.onReact,
    this.onDark = true,
    super.key,
  });

  /// Convenience for moments.
  ReactionBar.forPost({
    required Post post,
    required this.myId,
    required this.onReact,
    super.key,
  }) : reactions = post.reactions,
       onDark = true;

  final List<Reaction> reactions;
  final String? myId;
  final ValueChanged<ReactionKind> onReact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final mine = reactions.where((r) => r.userId == myId).firstOrNull?.kind;
    final counts = <ReactionKind, int>{for (final r in reactions) r.kind: 0};
    for (final r in reactions) {
      counts[r.kind] = (counts[r.kind] ?? 0) + 1;
    }
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
              onDark: onDark,
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
    required this.onDark,
    required this.onTap,
  });

  final String glyph;
  final String label;
  final int count;
  final bool selected;
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = selected
        ? scheme.primary
        : onDark
        ? Colors.white24
        : scheme.surfaceContainerHighest;
    final foreground = selected
        ? scheme.onPrimary
        : onDark
        ? Colors.white
        : scheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: count > 0 ? '$label $count' : label,
      child: Material(
        color: background,
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
                    ).textTheme.labelMedium?.copyWith(color: foreground),
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

/// "Who reacted" list, shared by moments and gifts.
Future<void> showReactorsSheet(
  BuildContext context, {
  required List<Reaction> reactions,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
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
          for (final r in reactions)
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
    onSheetOpened?.call();
    await showReactorsSheet(context, reactions: post.reactions);
    onSheetClosed?.call();
  }
}
