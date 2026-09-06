import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/auth/application/auth_providers.dart';

/// Settings hub (G-85 lite): account actions today (sign out, delete account
/// — G-71). Privacy toggles (G-22), notification prefs (G-63) and legal texts
/// (G-74) land here next.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    // Auth-state change drives the router back to /sign-in.
  }

  Future<void> _deleteAccount() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    final result = await ref.read(authRepositoryProvider).deleteAccount();
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      // Success: signOut inside deleteAccount flips auth state → router
      // redirects to /sign-in on its own.
      success: (_) {},
      failure: (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountError)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Stack(
        children: [
          ListView(
            children: [
              _SectionLabel(l10n.settingsAccountSection),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.meSignOut),
                onTap: _busy ? null : _signOut,
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l10n.settingsDeleteAccount,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: _busy ? null : _deleteAccount,
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
