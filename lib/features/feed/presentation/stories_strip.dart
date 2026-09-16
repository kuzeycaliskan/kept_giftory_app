import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/feed/domain/story_group.dart';
import 'package:kept/features/feed/presentation/moment_capture.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';

/// Horizontal ring row at the top of Home (G-202): the viewer's own story
/// (or a camera ring when they have none), then friends' live stories.
/// Unseen stories get the accent ring; watched ones fade to the outline.
class StoriesStrip extends ConsumerWidget {
  const StoriesStrip({super.key});

  static const double _ringRadius = 28;
  static const double _itemWidth = 76;
  static const double _height = 104;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(storyGroupsProvider);
    return SizedBox(
      height: _height,
      child: groups.when(
        loading: () => const _StripPlaceholder(),
        error: (error, _) =>
            _StripError(onRetry: () => ref.invalidate(storyGroupsProvider)),
        data: (groups) => _StripContent(groups: groups),
      ),
    );
  }
}

class _StripContent extends ConsumerWidget {
  const _StripContent({required this.groups});

  final List<StoryGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final me = ref.watch(myProfileProvider).valueOrNull;
    final seen = ref.watch(seenPostsProvider);
    final own = groups.where((g) => g.author.id == me?.id).firstOrNull;
    final friends = groups.where((g) => g.author.id != me?.id).toList();

    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _OwnRing(
          group: own,
          label: me?.displayName ?? me?.username ?? l10n.storiesYou,
          avatarValue: me?.avatarUrl,
        ),
        if (friends.isEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: KeptSpacing.sm,
              right: KeptSpacing.lg,
            ),
            child: SizedBox(
              width: 200,
              child: Center(
                child: Text(
                  l10n.storiesEmptyHint,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          for (final group in friends)
            _StoryRing(
              label: group.author.displayName ?? group.author.username,
              avatarValue: group.author.avatarUrl,
              unseen: group.hasUnseen(seen),
              onTap: () => context.push('/stories/${group.author.id}'),
            ),
      ],
    );
  }
}

/// First slot: own story when it exists (tap = watch, badge = add another),
/// otherwise a camera ring that starts a capture.
class _OwnRing extends ConsumerWidget {
  const _OwnRing({
    required this.group,
    required this.label,
    required this.avatarValue,
  });

  final StoryGroup? group;
  final String label;
  final String? avatarValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final own = group;
    if (own == null) {
      return _RingSlot(
        label: l10n.storiesAddHint,
        semanticsLabel: l10n.storiesAddHint,
        onTap: () => captureMoment(context, ref),
        child: CircleAvatar(
          radius: StoriesStrip._ringRadius,
          backgroundColor: scheme.surfaceContainerHighest,
          child: Icon(Icons.photo_camera_outlined, color: scheme.primary),
        ),
      );
    }
    return _RingSlot(
      label: l10n.storiesYou,
      semanticsLabel: l10n.storiesYou,
      onTap: () => context.push('/stories/${own.author.id}'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _Ring(
            unseen: false,
            child: KeptAvatar(
              label: label,
              avatarValue: avatarValue,
              radius: StoriesStrip._ringRadius,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: scheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => captureMoment(context, ref),
                child: Padding(
                  padding: const EdgeInsets.all(KeptSpacing.xs),
                  child: Icon(Icons.add, size: 16, color: scheme.onPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  const _StoryRing({
    required this.label,
    required this.avatarValue,
    required this.unseen,
    required this.onTap,
  });

  final String label;
  final String? avatarValue;
  final bool unseen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _RingSlot(
      label: label,
      semanticsLabel: label,
      onTap: onTap,
      child: _Ring(
        unseen: unseen,
        child: KeptAvatar(
          label: label,
          avatarValue: avatarValue,
          radius: StoriesStrip._ringRadius,
        ),
      ),
    );
  }
}

/// Accent ring = unseen; outline ring = already watched.
class _Ring extends StatelessWidget {
  const _Ring({required this.unseen, required this.child});

  final bool unseen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: unseen ? scheme.primary : scheme.outlineVariant,
          width: 2.5,
        ),
      ),
      child: child,
    );
  }
}

/// Fixed-width tappable column: ring above, one-line label below.
class _RingSlot extends StatelessWidget {
  const _RingSlot({
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
    required this.child,
  });

  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        borderRadius: KeptRadius.cardAll,
        onTap: onTap,
        child: SizedBox(
          width: StoriesStrip._itemWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
              const SizedBox(height: KeptSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: KeptSpacing.xs),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StripPlaceholder extends StatelessWidget {
  const _StripPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          SizedBox(
            width: StoriesStrip._itemWidth,
            child: Center(
              child: CircleAvatar(
                radius: StoriesStrip._ringRadius,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
      ],
    );
  }
}

class _StripError extends StatelessWidget {
  const _StripError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        const SizedBox(width: KeptSpacing.lg),
        Icon(Icons.error_outline, color: scheme.onSurfaceVariant),
        const SizedBox(width: KeptSpacing.md),
        Expanded(
          child: Text(
            context.l10n.storiesError,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          tooltip: context.l10n.commonRetry,
          icon: const Icon(Icons.refresh),
          onPressed: onRetry,
        ),
      ],
    );
  }
}
