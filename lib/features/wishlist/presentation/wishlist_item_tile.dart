import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// One wishlist entry: the product card when a preview is attached (G-211),
/// otherwise the plain tile. Shared by the wishlist screen and the event's
/// gift-ideas section so an item looks the same everywhere.
class WishlistItemTile extends StatelessWidget {
  const WishlistItemTile({required this.item, super.key});

  final WishlistItem item;

  Future<void> _openLink(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.legalOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = item.preview;
    if (preview != null) {
      final link = preview.url ?? item.url;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: LinkPreviewCard(
          preview: preview,
          onTap: link == null ? null : () => _openLink(context, link),
        ),
      );
    }
    final subtitleParts = [
      if (item.note != null) item.note!,
      if (item.url != null) item.url!,
    ];
    return ListTile(
      leading: const Icon(Icons.card_giftcard_outlined),
      title: Text(item.title),
      subtitle: subtitleParts.isEmpty
          ? null
          : Text(
              subtitleParts.join('\n'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      onTap: item.url == null ? null : () => _openLink(context, item.url!),
    );
  }
}
