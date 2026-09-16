import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/media/media_providers.dart';

/// Renders an object from a private bucket (posts). Resolves the path through
/// MediaStore — the widget never builds URLs or touches tokens — and covers
/// the loading / error states so callers don't repeat them.
class PrivateMediaImage extends ConsumerWidget {
  const PrivateMediaImage({
    required this.bucket,
    required this.path,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    super.key,
  });

  final String bucket;
  final String path;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref
        .watch(mediaStoreProvider)
        .privateSource(bucket: bucket, path: path);
    if (source == null) return const _Unavailable();
    return Image.network(
      source.uri.toString(),
      headers: source.headers,
      fit: fit,
      semanticLabel: semanticLabel,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stack) => const _Unavailable(),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            context.l10n.storyImageError,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
