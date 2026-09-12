import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';

/// One row in a [showKeptActionSheet].
class KeptSheetAction {
  const KeptSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Destructive rows render in the error color (design.md §1: red is
  /// reserved for destructive actions).
  final bool destructive;
}

/// House context menu (design.md §4): bottom action sheet with icon rows and
/// a separate cancel button — never a Material popup menu. The sheet closes
/// itself before invoking the tapped action.
Future<void> showKeptActionSheet(
  BuildContext context, {
  required List<KeptSheetAction> actions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final action in actions)
              ListTile(
                leading: Icon(
                  action.icon,
                  color: action.destructive ? scheme.error : null,
                ),
                title: Text(
                  action.label,
                  style: TextStyle(
                    color: action.destructive ? scheme.error : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  action.onTap();
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KeptSpacing.lg,
                KeptSpacing.sm,
                KeptSpacing.lg,
                KeptSpacing.lg,
              ),
              child: OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(sheetContext.l10n.commonCancel),
              ),
            ),
          ],
        ),
      );
    },
  );
}
