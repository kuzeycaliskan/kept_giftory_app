import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/settings/application/notification_prefs_controller.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings hub (G-85): privacy (G-22), blocked users (G-72), notification
/// prefs (G-63), legal texts (G-74) and account actions (sign out, delete
/// account — G-71). Profile editing (G-23) lands here next.
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
      failure: (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountError))),
    );
  }

  Future<void> _openUrl(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.legalOpenError)));
    }
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
              _SectionLabel(l10n.settingsPrivacySection),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: Text(l10n.privacyEntry),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed('settings-privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: Text(l10n.blockedUsersTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed('settings-blocked'),
              ),
              const Divider(),
              _SectionLabel(l10n.settingsNotificationsSection),
              const _BirthdayRemindersSwitch(),
              const Divider(),
              _SectionLabel(l10n.settingsLegalSection),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.legalPrivacyPolicy),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _openUrl(Env.privacyPolicyUrl),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.legalTermsOfUse),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _openUrl(Env.termsOfUseUrl),
              ),
              const Divider(),
              _SectionLabel(l10n.settingsAccountSection),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.editProfileTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed('profile-edit'),
              ),
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

/// G-63: birthday-reminder pushes on/off. The dispatch query respects this
/// server-side; the switch reflects the profile row.
class _BirthdayRemindersSwitch extends ConsumerWidget {
  const _BirthdayRemindersSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(myProfileProvider);
    final saving = ref.watch(notificationPrefsControllerProvider).isLoading;

    ref.listen(notificationPrefsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    // Backend-less / not onboarded: show the row disabled at its default.
    final enabled = profile.valueOrNull?.birthdayRemindersEnabled ?? true;
    final interactive = !saving && profile.valueOrNull != null;

    return SwitchListTile(
      secondary: const Icon(Icons.cake_outlined),
      title: Text(l10n.notifBirthdayReminders),
      subtitle: Text(l10n.notifBirthdayRemindersDesc),
      value: enabled,
      onChanged: interactive
          ? (value) => ref
                .read(notificationPrefsControllerProvider.notifier)
                .setBirthdayReminders(enabled: value)
          : null,
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
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
