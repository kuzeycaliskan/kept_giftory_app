import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// A friend's gift history, read-only (G-52): "what has this person already
/// received" — the duplicate-gift guard. RLS applies visibility + surprise
/// rules; pending surprises for the *viewer* are naturally absent.
class FriendGiftsScreen extends ConsumerWidget {
  const FriendGiftsScreen({required this.profileId, this.label, super.key});

  final String profileId;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final history = ref.watch(friendGiftHistoryProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.friendGiftsTitle(label ?? ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.giftsError)),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(l10n.friendGiftsEmpty));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final gift in list)
                ListTile(
                  leading: gift.preview == null
                      ? const Icon(Icons.card_giftcard_outlined)
                      : LinkPreviewThumb(preview: gift.preview!),
                  title: Text(
                    gift.item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${gift.counterpartLabel ?? l10n.giftAnonymousGiver} · '
                    '${DateFormat.yMMMd(locale).format(gift.giftDate)}',
                  ),
                  onTap: gift.preview?.url == null
                      ? null
                      : () => launchUrl(
                          Uri.parse(gift.preview!.url!),
                          mode: LaunchMode.externalApplication,
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
