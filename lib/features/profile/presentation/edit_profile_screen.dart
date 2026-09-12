import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/profile/application/edit_profile_controller.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/shared/widgets/kept_date_picker.dart';

/// Edit own profile (G-23): display name, birthday, occupation, bio.
/// Username is shown read-only — it's identity, locked in V1 (support
/// handles changes). Visibility lives in Settings → Privacy (G-22); avatar
/// arrives with the V2 media pipeline.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(myProfileProvider);

    return profile.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editProfileTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.editProfileTitle)),
        body: Center(child: Text(l10n.meProfileError)),
      ),
      data: (p) {
        if (p == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editProfileTitle)),
            body: Center(child: Text(l10n.meProfileFallback)),
          );
        }
        return _EditProfileForm(initial: p);
      },
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm({required this.initial});

  final Profile initial;

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  late final TextEditingController _username;
  late final TextEditingController _displayName;
  late final TextEditingController _occupation;
  late final TextEditingController _bio;
  late DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _username = TextEditingController(text: p.username);
    _displayName = TextEditingController(text: p.displayName ?? '');
    _occupation = TextEditingController(text: p.occupation ?? '');
    _bio = TextEditingController(text: p.bio ?? '');
    _birthday = p.birthday;
  }

  @override
  void dispose() {
    _username.dispose();
    _displayName.dispose();
    _occupation.dispose();
    _bio.dispose();
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showKeptDatePicker(
      context,
      initialDate: _birthday ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final edited = widget.initial.copyWith(
      displayName: _trimmedOrNull(_displayName),
      birthday: _birthday,
      occupation: _trimmedOrNull(_occupation),
      bio: _trimmedOrNull(_bio),
    );
    final ok = await ref
        .read(editProfileControllerProvider.notifier)
        .save(edited);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.editProfileSaved)));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final busy = ref.watch(editProfileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
        actions: [
          TextButton(
            onPressed: busy ? null : _save,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Username is identity — read-only in V1 (invite codes, search and
          // mentions hang off it). Changes go through support for now.
          TextField(
            controller: _username,
            enabled: false,
            decoration: InputDecoration(
              labelText: l10n.usernameLabel,
              prefixText: '@',
              helperText: l10n.editProfileUsernameLocked,
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _displayName,
            enabled: !busy,
            decoration: InputDecoration(
              labelText: l10n.nameOptionalLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Birthday is required (reminders depend on it) — no clear option.
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined),
            title: Text(l10n.profileAboutBirthday),
            subtitle: Text(
              _birthday == null
                  ? l10n.birthdayRequiredLabel
                  : DateFormat.yMMMMd(locale).format(_birthday!),
            ),
            trailing: const Icon(Icons.edit_outlined, size: 18),
            onTap: busy ? null : _pickBirthday,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _occupation,
            enabled: !busy,
            decoration: InputDecoration(
              labelText: l10n.profileAboutOccupation,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bio,
            enabled: !busy,
            minLines: 2,
            maxLines: 5,
            maxLength: 280,
            decoration: InputDecoration(
              labelText: l10n.editProfileBioLabel,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
