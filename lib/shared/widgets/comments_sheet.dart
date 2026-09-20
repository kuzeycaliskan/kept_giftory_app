import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/presentation/reaction_bar.dart'
    show reactionDigest;
import 'package:kept/shared/domain/comment.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:kept/shared/widgets/kept_action_sheet.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';

/// The "Yorum yaz…" pill at the right of a reaction row. Shows the count
/// when there is one; tap opens [showCommentsSheet]. [onDark] = white chrome.
class CommentPill extends StatelessWidget {
  const CommentPill({
    required this.count,
    required this.onTap,
    this.onDark = false,
    super.key,
  });

  final int count;
  final VoidCallback onTap;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final foreground = onDark ? Colors.white : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      label: count > 0
          ? l10n.commentsCount(count)
          : l10n.commentsWritePlaceholder,
      child: Material(
        color: onDark ? Colors.white24 : scheme.surfaceContainerHighest,
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
              children: [
                Icon(Icons.mode_comment_outlined, size: 20, color: foreground),
                const SizedBox(width: KeptSpacing.sm),
                Expanded(
                  child: Text(
                    count > 0
                        ? l10n.commentsCount(count)
                        : l10n.commentsWritePlaceholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet: comment list (author, time, body), composer at the bottom,
/// long-press → delete when allowed. Optional reactions summary line at the
/// top (tap → who reacted).
Future<void> showCommentsSheet(
  BuildContext context, {
  required CommentTarget target,
  required String? viewerId,
  List<Reaction> reactions = const [],
  VoidCallback? onReactionsTap,
  ValueChanged<Comment>? onReport,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      // Keep the composer above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: _CommentsSheet(
          target: target,
          viewerId: viewerId,
          reactions: reactions,
          onReactionsTap: onReactionsTap,
          onReport: onReport,
        ),
      ),
    ),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.target,
    required this.viewerId,
    required this.reactions,
    required this.onReactionsTap,
    required this.onReport,
  });

  final CommentTarget target;
  final String? viewerId;
  final List<Reaction> reactions;
  final VoidCallback? onReactionsTap;

  /// Report flow for someone else's comment (G-209); null = not offered.
  final ValueChanged<Comment>? onReport;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _input = TextEditingController();
  late Future<List<Comment>> _comments = widget.target.load();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _reload() {
    final next = widget.target.load();
    // Block body: an arrow would hand setState the Future as return value.
    setState(() {
      _comments = next;
    });
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await widget.target.add(body);
      _input.clear();
      _reload();
    } catch (e) {
      debugPrint('comment add failed: $e');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.commentsSendFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Long-press menu: delete when allowed, report when it's not mine.
  Future<void> _actions(Comment comment) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final canDelete = widget.target.canDelete(comment, widget.viewerId);
    final canReport =
        widget.onReport != null && comment.authorId != widget.viewerId;
    if (!canDelete && !canReport) return;
    await showKeptActionSheet(
      context,
      actions: [
        if (canReport)
          KeptSheetAction(
            icon: Icons.flag_outlined,
            label: l10n.reportAction,
            onTap: () => widget.onReport!(comment),
          ),
        if (canDelete)
          KeptSheetAction(
            icon: Icons.delete_outline,
            label: l10n.commentsDelete,
            destructive: true,
            onTap: () async {
              try {
                await widget.target.remove(comment);
                if (mounted) _reload();
              } catch (e) {
                debugPrint('comment delete failed: $e');
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.commentsDeleteFailed)),
                );
              }
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final reactionSummary = _reactionSummary(widget.reactions);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KeptSpacing.lg,
            0,
            KeptSpacing.lg,
            KeptSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.commentsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              // Digest is at most five glyphs + a number: intrinsic width,
              // flush right; the title absorbs whatever is left.
              if (reactionSummary != null)
                TextButton(
                  onPressed: widget.onReactionsTap,
                  child: Text(reactionSummary, maxLines: 1, softWrap: false),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<List<Comment>>(
            future: _comments,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(l10n.commentsLoadError));
              }
              final comments = snapshot.data;
              if (comments == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (comments.isEmpty) {
                return Center(
                  child: Text(
                    l10n.commentsEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: KeptSpacing.sm),
                itemCount: comments.length,
                itemBuilder: (context, i) {
                  final c = comments[i];
                  final name =
                      c.user?.displayName ??
                      c.user?.username ??
                      l10n.giftAnonymousGiver;
                  final actionable =
                      widget.target.canDelete(c, widget.viewerId) ||
                      (widget.onReport != null &&
                          c.authorId != widget.viewerId);
                  return ListTile(
                    leading: KeptAvatar(
                      label: name,
                      avatarValue: c.user?.avatarUrl,
                      radius: 18,
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: KeptSpacing.sm),
                        Text(
                          _age(l10n, c.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(c.body),
                    onLongPress: actionable ? () => _actions(c) : null,
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              KeptSpacing.lg,
              KeptSpacing.sm,
              KeptSpacing.sm,
              KeptSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    maxLength: commentMaxLength,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.commentsWritePlaceholder,
                      counterText: '',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commentsSend,
                  icon: const Icon(Icons.send),
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String? _reactionSummary(List<Reaction> reactions) {
  if (reactions.isEmpty) return null;
  final counts = <ReactionKind, int>{};
  for (final kind in ReactionKind.values) {
    final n = reactions.where((r) => r.kind == kind).length;
    if (n > 0) counts[kind] = n;
  }
  return reactionDigest(counts);
}

/// Coarse relative time: just now / minutes / hours / days.
String _age(AppLocalizations l10n, DateTime at) {
  final elapsed = DateTime.now().difference(at);
  if (elapsed.inMinutes < 1) return l10n.storyJustNow;
  if (elapsed.inHours < 1) return l10n.storyMinutesAgo(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.storyHoursAgo(elapsed.inHours);
  return l10n.commentsDaysAgo(elapsed.inDays);
}
