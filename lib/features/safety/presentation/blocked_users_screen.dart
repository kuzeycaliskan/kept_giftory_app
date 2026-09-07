import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/safety/application/safety_providers.dart';

/// Settings → Blocked users (G-72): list + unblock.
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final blocked = ref.watch(blockedUsersProvider);
    final busy = ref.watch(safetyControllerProvider).isLoading;

    ref.listen(safetyControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.blockedUsersTitle)),
      body: blocked.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorGeneric)),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.blockedUsersEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final name = card.displayName ?? card.username;
              return ListTile(
                leading: CircleAvatar(
                  foregroundImage: card.avatarUrl == null
                      ? null
                      : NetworkImage(card.avatarUrl!),
                  child: Text(name.characters.first.toUpperCase()),
                ),
                title: Text(name),
                subtitle: Text('@${card.username}'),
                trailing: TextButton(
                  onPressed: busy
                      ? null
                      : () => ref
                            .read(safetyControllerProvider.notifier)
                            .unblock(card.id),
                  child: Text(l10n.blockedUsersUnblock),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
