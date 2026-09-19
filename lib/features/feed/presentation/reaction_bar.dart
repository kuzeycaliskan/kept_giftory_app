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

/// One pill (product decision 2026-09-19): tap = heart / un-react, hold =
/// the picker with all five kinds pops up above it. Shows the viewer's own
/// kind when set (accent fill, brief pop) or a heart outline, plus the
/// total count. The glyph lives in a fixed box so the pill never changes
/// height between states. [onDark] = white chrome for the story stage.
class ReactionButton extends StatefulWidget {
  const ReactionButton({
    required this.reactions,
    required this.myId,
    required this.onReact,
    this.onDark = false,
    super.key,
  });

  final List<Reaction> reactions;
  final String? myId;

  /// Same toggle contract as the controllers: the kind already chosen
  /// clears, any other kind sets.
  final ValueChanged<ReactionKind> onReact;
  final bool onDark;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  final _link = LayerLink();
  final _picker = OverlayPortalController();

  ReactionKind? get _mine =>
      widget.reactions.where((r) => r.userId == widget.myId).firstOrNull?.kind;

  void _tap() => widget.onReact(_mine ?? ReactionKind.heart);

  void _pick(ReactionKind kind) {
    _picker.hide();
    widget.onReact(kind);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = _mine;
    final count = widget.reactions.length;
    final selected = mine != null;
    final background = selected
        ? scheme.primary
        : widget.onDark
        ? Colors.white24
        : scheme.surfaceContainerHighest;
    final foreground = selected
        ? scheme.onPrimary
        : widget.onDark
        ? Colors.white
        : scheme.onSurface;
    final l10n = context.l10n;

    return OverlayPortal(
      controller: _picker,
      overlayChildBuilder: (context) => Stack(
        children: [
          // Tap anywhere else → close.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _picker.hide,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            followerAnchor: Alignment.bottomLeft,
            offset: const Offset(0, -KeptSpacing.sm),
            child: _ReactionPicker(selected: mine, onPick: _pick),
          ),
        ],
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: Semantics(
          button: true,
          selected: selected,
          label: selected
              ? '${reactionLabel(context, mine)} $count'
              : l10n.reactionHeart,
          child: Material(
            color: background,
            borderRadius: KeptRadius.pillAll,
            child: InkWell(
              borderRadius: KeptRadius.pillAll,
              onTap: _tap,
              onLongPress: _picker.show,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KeptSpacing.md,
                  vertical: KeptSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Glyph(kind: mine, color: foreground),
                    if (count > 0) ...[
                      const SizedBox(width: KeptSpacing.xs),
                      Text(
                        '$count',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: foreground),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fixed 22dp box: emoji and icon share one footprint, so reacting never
/// changes the pill's height. A fresh kind pops (1.35 → 1) via a transform,
/// which does not touch layout.
class _Glyph extends StatelessWidget {
  const _Glyph({required this.kind, required this.color});

  final ReactionKind? kind;
  final Color color;

  static const double _box = 22;

  @override
  Widget build(BuildContext context) {
    final kind = this.kind;
    return SizedBox.square(
      dimension: _box,
      child: kind == null
          ? Icon(Icons.favorite_border, size: 20, color: color)
          : TweenAnimationBuilder<double>(
              key: ValueKey(kind),
              tween: Tween(begin: 1.35, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Center(
                child: Text(
                  reactionGlyph(kind),
                  style: const TextStyle(fontSize: 17, height: 1),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                ),
              ),
            ),
    );
  }
}

/// The five kinds in a floating pill above the button.
class _ReactionPicker extends StatelessWidget {
  const _ReactionPicker({required this.selected, required this.onPick});

  final ReactionKind? selected;
  final ValueChanged<ReactionKind> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: KeptRadius.pillAll,
      elevation: 4,
      shadowColor: scheme.shadow,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KeptSpacing.sm,
          vertical: KeptSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final kind in ReactionKind.values)
              Semantics(
                button: true,
                selected: kind == selected,
                label: reactionLabel(context, kind),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onPick(kind),
                  child: Container(
                    padding: const EdgeInsets.all(KeptSpacing.sm),
                    decoration: kind == selected
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.primaryContainer,
                          )
                        : null,
                    child: Text(
                      reactionGlyph(kind),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
              ),
          ],
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
    return Material(
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
    );
  }

  Future<void> _showReactors(BuildContext context) async {
    onSheetOpened?.call();
    await showReactorsSheet(context, reactions: post.reactions);
    onSheetClosed?.call();
  }
}
