import 'package:flutter/material.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';

/// Product card for a fetched link preview (G-211): thumbnail + title +
/// site/price. Optional [onRemove] renders the dismiss control (forms);
/// list rows omit it and pass [onTap] to open the link instead.
class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({
    required this.preview,
    this.onRemove,
    this.onTap,
    super.key,
  });

  final LinkPreview preview;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = [
      if (preview.site != null) preview.site!,
      if (preview.price != null) preview.price!,
    ].join(' · ');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: KeptRadius.cardAll,
        child: Padding(
          padding: const EdgeInsets.all(KeptSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: KeptRadius.controlAll,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: preview.imagePath == null
                      ? ColoredBox(
                          color: scheme.surfaceContainerLow,
                          child: Icon(
                            Icons.link,
                            color: scheme.onSurfaceVariant,
                          ),
                        )
                      : Image.network(
                          Env.linkPreviewImageUrl(preview.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: scheme.surfaceContainerLow,
                            child: Icon(
                              Icons.link,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: KeptSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview.title ?? preview.url ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  tooltip: context.l10n.linkPreviewRemove,
                  icon: const Icon(Icons.close),
                  onPressed: onRemove,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact 40dp thumbnail for list-tile leadings (gift rows).
class LinkPreviewThumb extends StatelessWidget {
  const LinkPreviewThumb({required this.preview, super.key});

  final LinkPreview preview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Icon(Icons.link, color: scheme.onSurfaceVariant, size: 20),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 40,
        height: 40,
        child: preview.imagePath == null
            ? fallback
            : Image.network(
                Env.linkPreviewImageUrl(preview.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
