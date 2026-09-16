import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/presentation/log_external_gift_screen.dart';
import 'package:kept/features/gifts/presentation/widgets/gift_photo_strip.dart';

/// House gift row (design.md §4): a consistent 48dp rounded leading — the
/// product image when a preview is attached, otherwise a neutral tile with
/// the direction icon — plus price as trailing when known (surprise chip
/// wins). Used by the Gifts tabs and the friend-history screen.
class GiftListTile extends StatelessWidget {
  const GiftListTile({
    required this.gift,
    required this.directionIcon,
    required this.counterpartIsGiver,
    this.showSurpriseBadge = false,
    super.key,
  });

  final GiftEntry gift;
  final IconData directionIcon;
  final bool showSurpriseBadge;

  /// Forwarded to the detail route so it resolves the same counterpart.
  final bool counterpartIsGiver;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    // Three giver states (G-212): member label · external relation ·
    // deleted-member fallback. Rendered distinctly by design.
    final counterpart = gift.giverRelation != null
        ? l10n.giftFromRelation(giftRelationLabel(context, gift.giverRelation!))
        : (gift.counterpartLabel ?? l10n.giftAnonymousGiver);
    final date = DateFormat.yMMMd(locale).format(gift.giftDate);
    final preview = gift.preview;

    final Widget leading = ClipRRect(
      borderRadius: BorderRadius.circular(KeptRadius.control),
      child: SizedBox(
        width: 48,
        height: 48,
        child: preview?.imagePath != null
            ? Image.network(
                Env.linkPreviewImageUrl(preview!.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _IconBox(icon: directionIcon, scheme: scheme),
              )
            : _IconBox(
                icon: gift.giverRelation != null
                    ? Icons.family_restroom_outlined
                    : directionIcon,
                scheme: scheme,
              ),
      ),
    );

    final Widget? trailing = showSurpriseBadge && gift.isPendingSurprise
        ? Chip(
            label: Text(l10n.giftSurpriseBadge),
            visualDensity: VisualDensity.compact,
          )
        : (preview?.price != null
              ? Text(
                  preview!.price!,
                  style: Theme.of(context).textTheme.titleSmall,
                )
              : null);

    final hasPhotos = gift.photos.isNotEmpty;
    return ListTile(
      leading: leading,
      title: Text(gift.item, maxLines: 1, overflow: TextOverflow.ellipsis),
      isThreeLine: hasPhotos,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$counterpart · $date',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasPhotos)
            Padding(
              padding: const EdgeInsets.only(top: KeptSpacing.xs),
              child: GiftPhotoStrip(photos: gift.photos),
            ),
        ],
      ),
      trailing: trailing,
      // Everything (photos, link, note) lives on the detail screen.
      onTap: () => context.push(
        '/gifts/${gift.id}?side=${counterpartIsGiver ? 'giver' : 'recipient'}',
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.scheme});

  final IconData icon;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Icon(icon, color: scheme.onSurfaceVariant, size: 22),
    );
  }
}
