import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/features/onboarding/application/onboarding_controller.dart';
import 'package:kept/features/profile/domain/username.dart';

/// Onboarding (G-87 lite): step 1 username (G-12), step 2 basics (G-13).
/// Birthday is required — it is the retention engine.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  int _step = 0;
  String? _usernameFeedback;
  bool _usernameOk = false;
  DateTime? _birthday;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _validateUsername() async {
    final value = _usernameController.text.trim();
    final error = Username.validate(value);
    if (error != null) {
      setState(() {
        _usernameOk = false;
        _usernameFeedback = switch (error) {
          UsernameError.tooShort => 'At least ${Username.minLength} characters',
          UsernameError.tooLong => 'At most ${Username.maxLength} characters',
          UsernameError.invalidCharacters =>
            'Only letters, numbers and underscore',
        };
      });
      return;
    }
    final free = await ref
        .read(onboardingControllerProvider.notifier)
        .checkAvailability(value);
    if (!mounted) return;
    setState(() {
      _usernameOk = free ?? false;
      _usernameFeedback = switch (free) {
        true => null,
        false => 'That username is taken',
        null => 'Could not check availability — try again',
      };
    });
    if (_usernameOk) setState(() => _step = 1);
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
    final state = ref.watch(onboardingControllerProvider);
    final busy = state.isLoading;

    ref.listen(onboardingControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Choose a username' : 'About you'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '@',
            labelText: 'Username',
            errorText: _usernameFeedback,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() => _usernameFeedback = null),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: busy ? null : _validateUsername,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _profileStep(bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: busy ? null : _pickBirthday,
          icon: const Icon(Icons.cake_outlined),
          label: Text(
            _birthday == null
                ? 'Birthday (required)'
                : '${_birthday!.day}.${_birthday!.month}.${_birthday!.year}',
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
              : const Text('Finish'),
        ),
      ],
    );
  }
}
