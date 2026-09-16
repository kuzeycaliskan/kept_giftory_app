import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/presentation/widgets/gift_list_tile.dart';

/// Gifts tab (G-51/G-52): Given / Received segments. In V3 this evolves into
/// the event hub.
class GiftsScreen extends ConsumerStatefulWidget {
  const GiftsScreen({super.key});

  @override
  ConsumerState<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends ConsumerState<GiftsScreen> {
  bool _showGiven = true;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select({required bool given}) {
    setState(() => _showGiven = given);
    _pageController.animateToPage(
      given ? 0 : 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(giftsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.giftsTitle)),
      // FAB follows the visible tab: Given logs a gift I bought; Received
      // records one from outside the app (G-212).
      floatingActionButton: FloatingActionButton(
        tooltip: _showGiven ? l10n.logGiftTitle : l10n.logExternalTitle,
        onPressed: () =>
            context.push(_showGiven ? '/gifts/log' : '/gifts/log-external'),
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
                  _select(given: selection.first),
            ),
          ),
          // Horizontal swipe moves between the two lists; the segment stays
          // in sync. Row-level Dismissibles win the gesture arena on rows,
          // so swipe-to-delete keeps working.
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _showGiven = page == 0),
              children: const [
                _GiftListPage(given: true),
                _GiftListPage(given: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One page of the Given/Received pager, with its own async states.
class _GiftListPage extends ConsumerWidget {
  const _GiftListPage({required this.given});

  final bool given;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = given ? givenGiftsProvider : receivedGiftsProvider;
    final items = ref.watch(provider);

    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.giftsError)),
      data: (list) {
        if (list.isEmpty) return _EmptyState(given: given);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(provider);
            await ref.read(provider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final gift in list)
                given
                    ? _DismissibleGiftTile(gift: gift)
                    : GiftListTile(
                        gift: gift,
                        directionIcon: Icons.south_west,
                        counterpartIsGiver: true,
                      ),
            ],
          ),
        );
      },
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
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                context.push(given ? '/gifts/log' : '/gifts/log-external'),
            child: Text(given ? l10n.giftsLogFirst : l10n.logExternalCta),
          ),
        ],
      ),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.giftDeletedSnack)));
        }
        return true;
      },
      child: GiftListTile(
        gift: gift,
        directionIcon: Icons.north_east,
        counterpartIsGiver: false,
        showSurpriseBadge: true,
      ),
    );
  }
}
