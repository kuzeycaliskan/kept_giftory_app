import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/invite/application/invite_providers.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Invite screen (G-34): share your personal code (QR + share sheet) and
/// redeem someone else's. Redemption = instant accepted friendship.
/// Deep links attach here once a domain exists.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final l10n = context.l10n;
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    final name =
        await ref.read(inviteControllerProvider.notifier).redeem(code);
    if (!mounted) return;
    if (name != null) {
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.inviteRedeemSuccess(name))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final myCode = ref.watch(myInviteCodeProvider);
    final redeemState = ref.watch(inviteControllerProvider);
    final busy = redeemState.isLoading;

    ref.listen(inviteControllerProvider, (_, next) {
      final error = next.error;
      if (error is ValidationFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.inviteInvalidCode)),
        );
      } else if (error is Failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inviteTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.inviteYourCode,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            myCode.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Text(l10n.inviteError),
              data: (code) => Column(
                children: [
                  Center(
                    child: QrImageView(
                      data: code,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    code,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(letterSpacing: 4),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: l10n.inviteShareMessage(code)),
                    ),
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.inviteShareButton),
                  ),
                ],
              ),
            ),
            const Divider(height: 48),
            Text(
              l10n.inviteEnterTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.inviteCodeLabel,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => busy ? null : _redeem(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: busy ? null : _redeem,
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.inviteRedeemButton),
            ),
          ],
        ),
      ),
    );
  }
}
