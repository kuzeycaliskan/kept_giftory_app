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
import 'package:kept/shared/widgets/kept_action_sheet.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';
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
  int _page = 0;

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

  Future<void> _photoActions(GiftPhoto photo) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    await showKeptActionSheet(
      context,
      actions: [
        KeptSheetAction(
          icon: Icons.delete_outline,
          label: l10n.giftPhotoRemove,
          destructive: true,
          onTap: () async {
            final ok = await ref
                .read(giftPhotoControllerProvider.notifier)
                .remove(photo);
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  ok ? l10n.giftPhotoRemoved : l10n.giftPhotoRemoveFailed,
                ),
              ),
            );
            if (ok && mounted) setState(() => _page = 0);
          },
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
            padding: const EdgeInsets.only(bottom: KeptSpacing.xxl),
            children: [
              _PhotoPager(
                photos: gift.photos,
                page: _page,
                onPageChanged: (i) => setState(() => _page = i),
                onActions: (photo) => photo.uploaderId == myId
                    ? () => _photoActions(photo)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(KeptSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (canAdd)
                      Padding(
                        padding: const EdgeInsets.only(bottom: KeptSpacing.lg),
                        child: FilledButton.tonalIcon(
                          onPressed: busy ? null : () => _addPhoto(gift),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text(l10n.giftPhotoAdd),
                        ),
                      ),
                    _Facts(gift: gift),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Photos big, one per page, with dots; empty → quiet placeholder. The
/// uploader gets a ⋯ over their own photo.
class _PhotoPager extends StatelessWidget {
  const _PhotoPager({
    required this.photos,
    required this.page,
    required this.onPageChanged,
    required this.onActions,
  });

  final List<GiftPhoto> photos;
  final int page;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? Function(GiftPhoto photo) onActions;

  static const double _height = 320;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (photos.isEmpty) {
      return Container(
        height: _height / 2,
        color: scheme.surfaceContainerLow,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_outlined, color: scheme.onSurfaceVariant),
              const SizedBox(height: KeptSpacing.sm),
              Text(
                context.l10n.giftDetailNoPhotos,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }
    final current = photos[page.clamp(0, photos.length - 1)];
    final actions = onActions(current);
    return SizedBox(
      height: _height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: scheme.surfaceContainerLow,
            child: PageView.builder(
              itemCount: photos.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) => PrivateMediaImage(
                bucket: giftMediaBucket,
                path: photos[i].mediaPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (photos.length > 1)
            Positioned(
              bottom: KeptSpacing.sm,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photos.length; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == page ? scheme.primary : scheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          if (actions != null)
            Positioned(
              top: KeptSpacing.sm,
              right: KeptSpacing.sm,
              child: Material(
                color: scheme.surface,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: context.l10n.storyMoreActions,
                  icon: const Icon(Icons.more_horiz),
                  onPressed: actions,
                ),
              ),
            ),
        ],
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
