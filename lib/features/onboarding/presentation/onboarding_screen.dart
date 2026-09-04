import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/onboarding/application/onboarding_controller.dart';
import 'package:kept/features/profile/domain/username.dart';

/// Onboarding (G-87 lite): step 1 username (G-12), step 2 basics (G-13).
/// Birthday is required — it is the retention engine.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// Availability outcome for inline feedback (null text = valid & free).
enum _UsernameFeedback {
  tooShort,
  tooLong,
  invalidCharacters,
  taken,
  checkFailed,
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  int _step = 0;
  _UsernameFeedback? _feedback;
  DateTime? _birthday;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _feedbackText(BuildContext context) => switch (_feedback) {
        null => null,
        _UsernameFeedback.tooShort =>
          context.l10n.usernameTooShort(Username.minLength),
        _UsernameFeedback.tooLong =>
          context.l10n.usernameTooLong(Username.maxLength),
        _UsernameFeedback.invalidCharacters =>
          context.l10n.usernameInvalidCharacters,
        _UsernameFeedback.taken => context.l10n.usernameTaken,
        _UsernameFeedback.checkFailed => context.l10n.usernameCheckFailed,
      };

  Future<void> _validateUsername() async {
    final value = _usernameController.text.trim();
    final error = Username.validate(value);
    if (error != null) {
      setState(() {
        _feedback = switch (error) {
          UsernameError.tooShort => _UsernameFeedback.tooShort,
          UsernameError.tooLong => _UsernameFeedback.tooLong,
          UsernameError.invalidCharacters =>
            _UsernameFeedback.invalidCharacters,
        };
      });
      return;
    }
    final free = await ref
        .read(onboardingControllerProvider.notifier)
        .checkAvailability(value);
    if (!mounted) return;
    setState(() {
      _feedback = switch (free) {
        true => null,
        false => _UsernameFeedback.taken,
        null => _UsernameFeedback.checkFailed,
      };
    });
    if (_feedback == null) setState(() => _step = 1);
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _submit() async {
    final profile =
        await ref.read(onboardingControllerProvider.notifier).submit(
              username: _usernameController.text.trim(),
              displayName: _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
              birthday: _birthday,
            );
    if (profile != null && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(onboardingControllerProvider);
    final busy = state.isLoading;

    ref.listen(onboardingControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == 0 ? l10n.onboardingUsernameTitle : l10n.onboardingAboutTitle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _step == 0 ? _usernameStep(busy) : _profileStep(busy),
        ),
      ),
    );
  }

  Widget _usernameStep(bool busy) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '@',
            labelText: l10n.usernameLabel,
            errorText: _feedbackText(context),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() => _feedback = null),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: busy ? null : _validateUsername,
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }

  Widget _profileStep(bool busy) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.nameOptionalLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: busy ? null : _pickBirthday,
          icon: const Icon(Icons.cake_outlined),
          label: Text(
            _birthday == null
                ? l10n.birthdayRequiredLabel
                : DateFormat.yMMMMd(locale).format(_birthday!),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: busy || _birthday == null ? null : _submit,
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.finishLabel),
        ),
      ],
    );
  }
}
