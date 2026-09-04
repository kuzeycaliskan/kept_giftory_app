import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';

/// Gifts tab (G-51/G-52): Given / Received segments. In V3 this evolves into
/// the event hub.
class GiftsScreen extends ConsumerStatefulWidget {
  const GiftsScreen({super.key});

  @override
  ConsumerState<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends ConsumerState<GiftsScreen> {
  bool _showGiven = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _showGiven
        ? ref.watch(givenGiftsProvider)
        : ref.watch(receivedGiftsProvider);

    ref.listen(giftsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.giftsTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.logGiftTitle,
        onPressed: () => context.push('/gifts/log'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(l10n.giftsGivenTab),
                  icon: const Icon(Icons.north_east),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(l10n.giftsReceivedTab),
                  icon: const Icon(Icons.south_west),
                ),
              ],
              selected: {_showGiven},
              onSelectionChanged: (selection) =>
                  setState(() => _showGiven = selection.first),
            ),
          ),
          Expanded(
            child: items.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.giftsError)),
              data: (list) {
                if (list.isEmpty) return _EmptyState(given: _showGiven);
                return RefreshIndicator(
                  onRefresh: () async {
                    final provider = _showGiven
                        ? givenGiftsProvider
                        : receivedGiftsProvider;
                    ref.invalidate(provider);
                    await ref.read(provider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 88),
                    children: [
                      for (final gift in list)
                        _showGiven
                            ? _DismissibleGiftTile(gift: gift)
                            : _GiftTile(gift: gift, given: false),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.given});

  final bool given;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.card_giftcard_outlined, size: 56),
          const SizedBox(height: 12),
          Text(given ? l10n.giftsEmpty : l10n.giftsReceivedEmpty),
          if (given) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/gifts/log'),
              child: Text(l10n.giftsLogFirst),
            ),
          ],
        ],
      ),
    );
  }
}

class _GiftTile extends StatelessWidget {
  const _GiftTile({required this.gift, required this.given});

  final GiftEntry gift;
  final bool given;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final counterpart = gift.counterpartLabel ?? l10n.giftAnonymousGiver;
    final date = DateFormat.yMMMd(locale).format(gift.giftDate);

    return ListTile(
      leading: Icon(
        given ? Icons.north_east : Icons.south_west,
      ),
      title: Text(gift.item),
      subtitle: Text('$counterpart · $date'),
      trailing: gift.isPendingSurprise
          ? Chip(
              label: Text(l10n.giftSurpriseBadge),
              visualDensity: VisualDensity.compact,
            )
          : null,
    );
  }
}

/// Given-gift tile with the house swipe gesture: swipe left to delete.
class _DismissibleGiftTile extends ConsumerWidget {
  const _DismissibleGiftTile({required this.gift});

  final GiftEntry gift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('gift-${gift.id}'),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: colors.error,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Icon(Icons.delete_outline, color: colors.onError),
          ),
        ),
      ),
      confirmDismiss: (_) async {
        await ref.read(giftsControllerProvider.notifier).delete(gift.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.giftDeletedSnack)),
          );
        }
        return true;
      },
      child: _GiftTile(gift: gift, given: true),
    );
  }
}
