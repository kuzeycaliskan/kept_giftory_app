import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/application/post_composer.dart';
import 'package:kept/features/feed/domain/post.dart';
import 'package:kept/features/feed/presentation/moment_capture.dart';

/// Preview + optional caption + Share (G-201). The photo is already taken;
/// this screen never offers a gallery or a retake into the gallery.
class ComposePostScreen extends ConsumerStatefulWidget {
  const ComposePostScreen({required this.imageBytes, this.unboxing, super.key});

  final Uint8List imageBytes;

  /// Set when this moment unboxes a received gift (G-308).
  final UnboxingTarget? unboxing;

  @override
  ConsumerState<ComposePostScreen> createState() => _ComposePostScreenState();
}

class _ComposePostScreenState extends ConsumerState<ComposePostScreen> {
  final _caption = TextEditingController();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(postComposerProvider.notifier)
        .publish(
          bytes: widget.imageBytes,
          caption: _caption.text,
          giftId: widget.unboxing?.giftId,
        );
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.composeShared)));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.composeFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = ref.watch(postComposerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.composeTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KeptSpacing.lg,
                  KeptSpacing.sm,
                  KeptSpacing.lg,
                  0,
                ),
                child: ClipRRect(
                  borderRadius: KeptRadius.cardAll,
                  child: SizedBox.expand(
                    child: Image.memory(
                      widget.imageBytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(KeptSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.unboxing case final unboxing?) ...[
                    _UnboxingContext(item: unboxing.item),
                    const SizedBox(height: KeptSpacing.sm),
                  ],
                  TextField(
                    controller: _caption,
                    enabled: !busy,
                    maxLength: postCaptionMaxLength,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.composeCaptionHint,
                    ),
                  ),
                  const SizedBox(height: KeptSpacing.sm),
                  FilledButton(
                    onPressed: busy ? null : _share,
                    child: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.composeShare),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Says which gift this moment is about and that the photo also stays with
/// the gift's memories (the moment itself is gone in 24h).
class _UnboxingContext extends StatelessWidget {
  const _UnboxingContext({required this.item});

  final String item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Icon(Icons.redeem_outlined, size: 20, color: scheme.primary),
        const SizedBox(width: KeptSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.composeUnboxingOf(item),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.composeUnboxingKept,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
