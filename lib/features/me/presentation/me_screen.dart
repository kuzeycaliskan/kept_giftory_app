import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/profile/application/profile_providers.dart';

/// Me tab: profile hub (G-84 will flesh this out with the tabbed profile;
/// friends & settings entries hang off this screen per the nav decision).
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dev session has no real auth user → skip the profile query.
    final profile = Env.hasSupabaseConfig && !ref.watch(devSessionProvider)
        ? ref.watch(myProfileProvider)
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: AppBar(title: const Text('Me')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const Center(child: Text('Could not load profile')),
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
              title: Text(p?.displayName ?? p?.username ?? 'Profile'),
              subtitle: p == null ? null : Text('@${p.username}'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.group_outlined),
              title: Text('Friends'),
              subtitle: Text('Coming with G-31'),
            ),
            const ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
              subtitle: Text('Coming with G-85'),
            ),
          ],
        ),
      ),
    );
  }
}
