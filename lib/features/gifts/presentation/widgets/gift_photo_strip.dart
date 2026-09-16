import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/shared/widgets/private_media_image.dart';

/// Up to three small square thumbnails of a gift's photos (G-204), used on
/// gift rows. Purely decorative preview — the detail screen shows them big.
class GiftPhotoStrip extends StatelessWidget {
  const GiftPhotoStrip({required this.photos, this.size = 32, super.key});

  final List<GiftPhoto> photos;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final photo in photos.take(giftPhotoCap))
          Padding(
            padding: const EdgeInsets.only(right: KeptSpacing.xs),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KeptRadius.control / 2),
              child: SizedBox(
                width: size,
                height: size,
                child: PrivateMediaImage(
                  bucket: giftMediaBucket,
                  path: photo.mediaPath,
                  fit: BoxFit.cover,
                  compact: true,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Pending captures inside the log forms: thumbnails with a remove badge and
/// the "take a photo" action while under the cap.
class PendingPhotoPicker extends StatelessWidget {
  const PendingPhotoPicker({
    required this.captures,
    required this.onCapture,
    required this.onRemove,
    required this.enabled,
    required this.captureLabel,
    required this.capHint,
    super.key,
  });

  final List<Uint8List> captures;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;
  final bool enabled;
  final String captureLabel;
  final String capHint;

  static const double _thumb = 72;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final atCap = captures.length >= giftPhotoCap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (captures.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: KeptSpacing.sm),
            child: Wrap(
              spacing: KeptSpacing.sm,
              children: [
                for (var i = 0; i < captures.length; i++)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: KeptRadius.controlAll,
                        child: Image.memory(
                          captures[i],
                          width: _thumb,
                          height: _thumb,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Material(
                          color: scheme.surface,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: enabled ? () => onRemove(i) : null,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: enabled && !atCap ? onCapture : null,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(captureLabel),
            ),
            const SizedBox(width: KeptSpacing.md),
            Expanded(
              child: Text(
                capHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
