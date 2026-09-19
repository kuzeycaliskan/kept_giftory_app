import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/feed/application/post_actions.dart';
import 'package:kept/features/feed/application/post_comment_target.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/feed/domain/story_group.dart';
import 'package:kept/features/feed/presentation/reaction_bar.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:kept/shared/widgets/comments_sheet.dart';
import 'package:kept/shared/widgets/kept_action_sheet.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';
import 'package:kept/shared/widgets/private_media_image.dart';

/// Full-screen story player (G-202): one page per author, posts auto-advance
/// with segment progress; tap right/left to step, hold to pause, swipe for
/// the next author. The stage is deliberately black with white chrome (same
/// exception as the avatar preview) — photos need a neutral dark backdrop.
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({required this.initialAuthorId, super.key});

  final String initialAuthorId;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  PageController? _pages;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  void _closeAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _onGroupFinished(int index, int count) {
    final pages = _pages;
    if (pages == null) return;
    if (index + 1 >= count) {
      Navigator.of(context).pop();
      return;
    }
    pages.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(storyGroupsProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: groups.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, _) {
          _closeAfterFrame();
          return const SizedBox.shrink();
        },
        data: (groups) {
          if (groups.isEmpty) {
            _closeAfterFrame();
            return const SizedBox.shrink();
          }
          final start = groups.indexWhere(
            (g) => g.author.id == widget.initialAuthorId,
          );
          // The author's story vanished (expired/deleted) while we opened.
          if (start < 0) {
            _closeAfterFrame();
            return const SizedBox.shrink();
          }
          final pages = _pages ??= PageController(initialPage: start);
          return PageView.builder(
            controller: pages,
            itemCount: groups.length,
            itemBuilder: (context, index) => _StoryPage(
              key: ValueKey(groups[index].author.id),
              group: groups[index],
              onFinished: () => _onGroupFinished(index, groups.length),
            ),
          );
        },
      ),
    );
  }
}

class _StoryPage extends ConsumerStatefulWidget {
  const _StoryPage({required this.group, required this.onFinished, super.key});

  final StoryGroup group;
  final VoidCallback onFinished;

  @override
  ConsumerState<_StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<_StoryPage>
    with SingleTickerProviderStateMixin {
  static const _postDuration = Duration(seconds: 5);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _postDuration,
  )..addStatusListener(_onStatus);

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _show(0);
  }

  @override
  void didUpdateWidget(covariant _StoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A post was deleted underneath us: clamp instead of indexing past the end.
    if (_index >= widget.group.posts.length) {
      _show(widget.group.posts.length - 1);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _next();
  }

  void _show(int index) {
    setState(() => _index = index);
    final post = widget.group.posts[index];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(seenPostsProvider.notifier).markSeen(post.id);
    });
    _progress
      ..reset()
      ..forward();
  }

  void _next() {
    if (_index + 1 < widget.group.posts.length) {
      _show(_index + 1);
    } else {
      widget.onFinished();
    }
  }

  void _previous() => _show(_index > 0 ? _index - 1 : 0);

  /// The story pauses while the comments sheet is open.
  Future<void> _openComments(Post post, String? myId) async {
    _progress.stop();
    await showCommentsSheet(
      context,
      target: PostCommentTarget(
        ref.read(feedRepositoryProvider),
        post,
        onChanged: () => ref.invalidate(storyGroupsProvider),
      ),
      viewerId: myId,
      reactions: post.reactions,
      onReactionsTap: () =>
          showReactorsSheet(context, reactions: post.reactions),
    );
    if (mounted) unawaited(_progress.forward());
  }

  Future<void> _react(Post post, ReactionKind kind, String? myId) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final ok = await ref
        .read(postActionsProvider.notifier)
        .react(post, kind, myId: myId);
    if (!ok && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reactionFailed)));
    }
  }

  Future<void> _deleteCurrent() async {
    final l10n = context.l10n;
    final post = widget.group.posts[_index];
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    _progress.stop();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.storyDeleteConfirmTitle),
        content: Text(l10n.storyDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.storyDelete),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      unawaited(_progress.forward());
      return;
    }

    final ok = await ref.read(postActionsProvider.notifier).delete(post);
    if (!mounted) return;
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.storyDeleteFailed)));
      unawaited(_progress.forward());
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.storyDeleted)));
    // Last post of my story → nothing left to show here.
    if (widget.group.posts.length <= 1) navigator.pop();
  }

  Future<void> _showActions() async {
    _progress.stop();
    var picked = false;
    await showKeptActionSheet(
      context,
      actions: [
        KeptSheetAction(
          icon: Icons.delete_outline,
          label: context.l10n.storyDelete,
          destructive: true,
          onTap: () {
            picked = true;
            unawaited(_deleteCurrent());
          },
        ),
      ],
    );
    // Dismissed without choosing: resume. (Delete manages its own resume.)
    if (!picked && mounted) unawaited(_progress.forward());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final group = widget.group;
    final post = group.posts[_index];
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    final isMine = myId == post.authorId;
    final label = group.author.displayName ?? group.author.username;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final width = MediaQuery.sizeOf(context).width;
        if (details.localPosition.dx < width / 3) {
          _previous();
        } else {
          _next();
        }
      },
      onLongPressStart: (_) => _progress.stop(),
      onLongPressEnd: (_) => _progress.forward(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PrivateMediaImage(
            bucket: postsBucket,
            path: post.mediaPath,
            semanticLabel: label,
          ),
          // Bottom stack: caption (if any) above the reaction row. The row
          // absorbs its own taps so reacting never steps the story.
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomPanel(
              caption: post.caption,
              child: GestureDetector(
                onTap: () {},
                onLongPress: () {},
                child: Row(
                  children: [
                    if (isMine)
                      ReactionSummary(
                        post: post,
                        onSheetOpened: _progress.stop,
                        onSheetClosed: () {
                          if (mounted) unawaited(_progress.forward());
                        },
                      )
                    else
                      ReactionButton(
                        reactions: post.reactions,
                        myId: myId,
                        onDark: true,
                        onReact: (kind) => _react(post, kind, myId),
                      ),
                    const SizedBox(width: KeptSpacing.sm),
                    Expanded(
                      child: CommentPill(
                        count: post.commentCount,
                        onDark: true,
                        onTap: () => _openComments(post, myId),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KeptSpacing.sm,
                    KeptSpacing.sm,
                    KeptSpacing.sm,
                    0,
                  ),
                  child: _SegmentBar(
                    count: group.posts.length,
                    current: _index,
                    progress: _progress,
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: KeptSpacing.md),
                    KeptAvatar(
                      label: label,
                      avatarValue: group.author.avatarUrl,
                      radius: 16,
                    ),
                    const SizedBox(width: KeptSpacing.sm),
                    Expanded(
                      child: Text(
                        '$label · ${_age(l10n, post.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                    if (isMine)
                      IconButton(
                        tooltip: l10n.storyMoreActions,
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        onPressed: _showActions,
                      ),
                    CloseButton(
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Just now" / "12m" / "3h" — coarse on purpose; the post is gone in 24h.
String _age(AppLocalizations l10n, DateTime createdAt) {
  final elapsed = DateTime.now().difference(createdAt);
  if (elapsed.inMinutes < 1) return l10n.storyJustNow;
  if (elapsed.inHours < 1) return l10n.storyMinutesAgo(elapsed.inMinutes);
  return l10n.storyHoursAgo(elapsed.inHours);
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.count,
    required this.current,
    required this.progress,
  });

  final int count;
  final int current;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < count; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: LinearProgressIndicator(
                  value: i < current
                      ? 1
                      : i == current
                      ? progress.value
                      : 0,
                  minHeight: 3,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.caption, required this.child});

  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        KeptSpacing.lg,
        KeptSpacing.xxl,
        KeptSpacing.lg,
        KeptSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (caption case final text?) ...[
              Text(
                text,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: KeptSpacing.md),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
