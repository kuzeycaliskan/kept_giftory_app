import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/profile/application/avatar_controller.dart';
import 'package:kept/features/profile/application/edit_profile_controller.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/presentation/avatar_crop_screen.dart';
import 'package:kept/shared/widgets/avatar_preview.dart';
import 'package:kept/shared/widgets/kept_action_sheet.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';
import 'package:kept/shared/widgets/kept_date_picker.dart';

/// Edit own profile (G-23): display name, birthday, occupation, bio.
/// Username is shown read-only — it's identity, locked in V1 (support
/// handles changes). Visibility lives in Settings → Privacy (G-22).
/// Avatar: tap the photo badge — gallery/camera via KeptActionSheet.
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

  Future<void> _pickFrom(ImageSource source) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = ref.read(avatarControllerProvider.notifier);

    final original = await controller.pickImage(source);
    if (original == null || !mounted) return;

    final cropped = await navigator.push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => AvatarCropScreen(imageBytes: original),
        fullscreenDialog: true,
      ),
    );
    if (cropped == null) return; // backed out of the crop screen

    final ok = await controller.uploadCropped(cropped);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.avatarUpdated)));
    }
  }

  Future<void> _changeAvatar() async {
    final l10n = context.l10n;
    await showKeptActionSheet(
      context,
      actions: [
        KeptSheetAction(
          icon: Icons.photo_library_outlined,
          label: l10n.avatarFromGallery,
          onTap: () => _pickFrom(ImageSource.gallery),
        ),
        KeptSheetAction(
          icon: Icons.photo_camera_outlined,
          label: l10n.avatarFromCamera,
          onTap: () => _pickFrom(ImageSource.camera),
        ),
      ],
    );
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
    final avatarBusy = ref.watch(avatarControllerProvider).isLoading;

    ref.listen(avatarControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

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
          Center(
            child: Stack(
              children: [
                Builder(
                  builder: (context) {
                    final label =
                        widget.initial.displayName ?? widget.initial.username;
                    final value =
                        ref.watch(myProfileProvider).valueOrNull?.avatarUrl ??
                        widget.initial.avatarUrl;
                    final url = KeptAvatar.resolveUrl(ref, value);
                    return GestureDetector(
                      onTap: url == null
                          ? null
                          : () => showAvatarPreview(
                              context,
                              url: url,
                              label: label,
                            ),
                      child: KeptAvatar(
                        label: label,
                        avatarValue: value,
                        radius: 44,
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: avatarBusy ? null : _changeAvatar,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: avatarBusy
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : Icon(
                                Icons.photo_camera_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
