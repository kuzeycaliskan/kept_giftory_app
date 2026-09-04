import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/profile/application/profile_providers.dart';

/// Me tab: profile hub (G-84 will flesh this out with the tabbed profile;
/// friends & settings entries hang off this screen per the nav decision).
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Dev session has no real auth user → skip the profile query.
    final profile = Env.hasSupabaseConfig && !ref.watch(devSessionProvider)
        ? ref.watch(myProfileProvider)
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.meTitle)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.meProfileError)),
        data: (p) => ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  (p?.displayName ?? p?.username ?? '?')
                      .substring(0, 1)
                      .toUpperCase(),
                ),
              ),
              title: Text(
                p?.displayName ?? p?.username ?? l10n.meProfileFallback,
              ),
              subtitle: p == null ? null : Text('@${p.username}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(l10n.wishlistMineTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/wishlist'),
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: Text(l10n.meFriends),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/friends'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.meSettings),
              subtitle: Text(l10n.meSettingsComingSoon),
            ),
          ],
        ),
      ),
    );
  }
}
