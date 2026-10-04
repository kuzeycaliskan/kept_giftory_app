import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/gifts/application/gift_photo_controller.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';

/// Where a gift photo lands after the camera: preview, a note for the
/// photo, and — for the recipient of an open gift — "also share as a
/// story" (G-308, on by default). One button, labelled for what it does.
class GiftPhotoComposeScreen extends ConsumerStatefulWidget {
  const GiftPhotoComposeScreen({
    required this.giftId,
    required this.item,
    required this.imageBytes,
    required this.storyOffered,
    super.key,
  });

  final String giftId;
  final String item;
  final Uint8List imageBytes;

  /// Whether the story checkbox is shown at all (recipient, gift open).
  final bool storyOffered;

  /// Route for a captured photo; the bytes travel as `extra`.
  static String route({
    required String giftId,
    required String item,
    required bool storyOffered,
  }) =>
      '/gifts/$giftId/photo?item=${Uri.encodeQueryComponent(item)}'
      '${storyOffered ? '&story=1' : ''}';

  @override
  ConsumerState<GiftPhotoComposeScreen> createState() =>
      _GiftPhotoComposeScreenState();
}

class _GiftPhotoComposeScreenState
    extends ConsumerState<GiftPhotoComposeScreen> {
  final _note = TextEditingController();
  late bool _asStory = widget.storyOffered;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final outcome = await ref
        .read(giftPhotoControllerProvider.notifier)
        .share(
          giftId: widget.giftId,
          bytes: widget.imageBytes,
          note: _note.text,
          asStory: _asStory,
        );
    if (!mounted) return;
    final message = switch (outcome) {
      GiftPhotoOutcome.saved => l10n.giftPhotoSaved,
      GiftPhotoOutcome.shared => l10n.giftPhotoSharedStory,
      GiftPhotoOutcome.storyFailed => l10n.giftPhotoStoryFailed,
      GiftPhotoOutcome.failed => l10n.giftPhotoAddFailed,
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));
    if (outcome != GiftPhotoOutcome.failed) router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final busy = ref.watch(giftPhotoControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.storyOffered ? l10n.giftShareUnboxing : l10n.giftPhotoAdd,
        ),
      ),
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
                  Row(
                    children: [
                      Icon(
                        Icons.redeem_outlined,
                        size: 20,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: KeptSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.item,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KeptSpacing.sm),
                  TextField(
                    controller: _note,
                    enabled: !busy,
                    maxLength: giftPhotoCaptionMaxLength,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.giftPhotoNoteHint,
                    ),
                  ),
                  if (widget.storyOffered)
                    // Says exactly what else happens; off means the photo
                    // and note stay on the gift only.
                    CheckboxListTile(
                      value: _asStory,
                      onChanged: busy
                          ? null
                          : (v) => setState(() => _asStory = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.giftPhotoShareStory),
                      subtitle: Text(l10n.giftPhotoShareStoryHint),
                    ),
                  const SizedBox(height: KeptSpacing.sm),
                  FilledButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _asStory ? l10n.giftPhotoShare : l10n.giftPhotoSave,
                          ),
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
