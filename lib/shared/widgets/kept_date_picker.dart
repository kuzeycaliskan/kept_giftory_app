import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';

/// House date picker: Cupertino day/month/year wheels in a bottom sheet.
///
/// Replaces Material's calendar `showDatePicker`, whose month-by-month arrow
/// navigation is painful for far-away dates like birthdays. Returns the
/// picked date, or null when dismissed.
Future<DateTime?> showKeptDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  var selected = initialDate;
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 216,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 20,
                      color: Theme.of(sheetContext).colorScheme.onSurface,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(selected),
                  child: Text(l10n.commonDone),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
