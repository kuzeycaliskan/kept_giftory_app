import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/safety/application/safety_providers.dart';
import 'package:kept/features/safety/domain/safety_repository.dart';

/// Opens the report flow (G-73) for [userId]. Resolves after the sheet
/// closes; shows its own success snackbar.
Future<void> showReportSheet(BuildContext context, String userId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReportSheet(userId: userId),
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.userId});

  final String userId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  static const _maxDetailsLength = 500;

  ReportReason _reason = ReportReason.spam;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  String _label(ReportReason reason) {
    final l10n = context.l10n;
    return switch (reason) {
      ReportReason.spam => l10n.reportReasonSpam,
      ReportReason.harassment => l10n.reportReasonHarassment,
      ReportReason.inappropriate => l10n.reportReasonInappropriate,
      ReportReason.other => l10n.reportReasonOther,
    };
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(safetyControllerProvider.notifier)
        .report(widget.userId, _reason, details: _details.text);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportSuccess)));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = ref.watch(safetyControllerProvider).isLoading;

    return Padding(
      // Keep the sheet above the keyboard while typing details.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Text(
                l10n.reportTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (value) {
                if (busy || value == null) return;
                setState(() => _reason = value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final reason in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: reason,
                      title: Text(_label(reason)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _details,
                enabled: !busy,
                maxLength: _maxDetailsLength,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: l10n.reportDetailsLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: FilledButton(
                onPressed: busy ? null : _submit,
                child: Text(l10n.reportSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
