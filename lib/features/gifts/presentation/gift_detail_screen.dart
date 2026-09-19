import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/gifts/application/gift_photo_controller.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/presentation/log_external_gift_screen.dart'
    show giftRelationLabel;
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';
import 'package:kept/shared/widgets/media_gallery_viewer.dart';
import 'package:kept/shared/widgets/private_media_image.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gift detail (G-204): big photo pager on top, then the facts. Either party
/// may add photos (camera only, cap 3); an uploader removes their own.
/// Visibility is the gift row's — RLS decides whether this loads at all.
class GiftDetailScreen extends ConsumerStatefulWidget {
  const GiftDetailScreen({
    required this.giftId,
    required this.counterpartIsGiver,
    super.key,
  });

  final String giftId;

  /// Which party to show as "the other one": the giver on received/history
  /// surfaces, the recipient on the given tab.
  final bool counterpartIsGiver;

  @override
  ConsumerState<GiftDetailScreen> createState() => _GiftDetailScreenState();
}

class _GiftDetailScreenState extends ConsumerState<GiftDetailScreen> {
  Future<void> _addPhoto(GiftEntry gift) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(giftPhotoControllerProvider.notifier);
    final bytes = await controller.capture();
    if (bytes == null) return;
    final attached = await controller.attach(
      giftId: gift.id,
      captures: [bytes],
    );
    if (attached == 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.giftPhotoAddFailed)));
    }
  }

  Future<void> _removePhoto(GiftPhoto photo) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref
        .read(giftPhotoControllerProvider.notifier)
        .remove(photo);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.giftPhotoRemoved : l10n.giftPhotoRemoveFailed),
      ),
    );
  }

  /// Tap a card → full-screen, swipe across all photos; own photos can be
  /// removed from there.
  Future<void> _openGallery(GiftEntry gift, int index, String? myId) {
    return showMediaGallery(
      context,
      initialIndex: index,
      removeLabel: context.l10n.giftPhotoRemove,
      items: [
        for (final photo in gift.photos)
          GalleryItem(
            bucket: giftMediaBucket,
            path: photo.mediaPath,
            onRemove: photo.uploaderId == myId
                ? () => _removePhoto(photo)
                : null,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gift = ref.watch(
      giftDetailProvider(
        widget.giftId,
        counterpartIsGiver: widget.counterpartIsGiver,
      ),
    );
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    final busy = ref.watch(giftPhotoControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.giftDetailTitle)),
      body: gift.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.giftsError)),
        data: (gift) {
          if (gift == null) {
            return Center(child: Text(l10n.giftDetailMissing));
          }
          final canAdd =
              gift.isParty(myId) && gift.photos.length < giftPhotoCap;
          return ListView(
            padding: const EdgeInsets.all(KeptSpacing.lg),
            children: [
              _PhotoCards(
                photos: gift.photos,
                onOpen: (i) => _openGallery(gift, i, myId),
                onAdd: canAdd && !busy ? () => _addPhoto(gift) : null,
                showAddSlot: canAdd,
              ),
              const SizedBox(height: KeptSpacing.xl),
              _Facts(gift: gift),
            ],
          );
        },
      ),
    );
  }
}

/// Three equal cards side by side: photos, then (for a party under the cap)
/// one camera card, then quiet empty slots so the row keeps its shape.
class _PhotoCards extends StatelessWidget {
  const _PhotoCards({
    required this.photos,
    required this.onOpen,
    required this.onAdd,
    required this.showAddSlot,
  });

  final List<GiftPhoto> photos;
  final ValueChanged<int> onOpen;
  final VoidCallback? onAdd;
  final bool showAddSlot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final slots = <Widget>[
      for (var i = 0; i < photos.length; i++)
        _PhotoCard(
          onTap: () => onOpen(i),
          child: PrivateMediaImage(
            bucket: giftMediaBucket,
            path: photos[i].mediaPath,
            fit: BoxFit.cover,
            compact: true,
          ),
        ),
      if (showAddSlot && photos.length < giftPhotoCap)
        _PhotoCard(
          onTap: onAdd,
          child: ColoredBox(
            color: scheme.surfaceContainerHighest,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera_outlined, color: scheme.primary),
                const SizedBox(height: KeptSpacing.xs),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KeptSpacing.xs,
                  ),
                  child: Text(
                    l10n.giftPhotoAdd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: scheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
    if (slots.isEmpty) {
      slots.add(
        _PhotoCard(
          onTap: null,
          child: ColoredBox(
            color: scheme.surfaceContainerLow,
            child: Center(
              child: Text(
                l10n.giftDetailNoPhotos,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }
    while (slots.length < giftPhotoCap) {
      slots.add(
        _PhotoCard(
          onTap: null,
          child: ColoredBox(color: scheme.surfaceContainerLow),
        ),
      );
    }
    return Row(
      children: [
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) const SizedBox(width: KeptSpacing.sm),
          Expanded(child: slots[i]),
        ],
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: KeptRadius.cardAll,
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.gift});

  final GiftEntry gift;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final counterpart = gift.giverRelation != null
        ? l10n.giftFromRelation(giftRelationLabel(context, gift.giverRelation!))
        : (gift.counterpartLabel ?? l10n.giftAnonymousGiver);
    final date = DateFormat.yMMMd(locale).format(gift.giftDate);
    final preview = gift.preview;
    final note = gift.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gift.item,
          style: theme.textTheme.titleLarge,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: KeptSpacing.xs),
        Text(
          '$counterpart · $date',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (gift.isPendingSurprise)
          Padding(
            padding: const EdgeInsets.only(top: KeptSpacing.sm),
            child: Chip(
              label: Text(l10n.giftSurpriseBadge),
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (note != null && note.isNotEmpty) ...[
          const SizedBox(height: KeptSpacing.lg),
          Text(note, style: theme.textTheme.bodyLarge),
        ],
        if (preview != null) ...[
          const SizedBox(height: KeptSpacing.lg),
          LinkPreviewCard(
            preview: preview,
            onTap: preview.url == null
                ? null
                : () => launchUrl(
                    Uri.parse(preview.url!),
                    mode: LaunchMode.externalApplication,
                  ),
          ),
        ],
      ],
    );
  }
}
