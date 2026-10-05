import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/events/presentation/event_kind_labels.dart';
import 'package:kept/shared/widgets/kept_date_picker.dart';
import 'package:kept/shared/widgets/kept_list_group.dart';

/// What the user picked: the occasion, its day (null for a birthday,
/// which takes the profile's), and a title for "other".
@immutable
class OccasionChoice {
  const OccasionChoice({required this.kind, this.day, this.title});

  final EventKind kind;
  final DateTime? day;
  final String? title;
}

/// The shared "which occasion → when → called what" steps (G-410): used
/// when opening an event for a friend and when announcing one's own day.
/// Returns null when the user backs out at any step.
Future<OccasionChoice?> pickOccasion(
  BuildContext context, {
  required String title,
  bool offerBirthday = true,
  bool birthdayAvailable = true,
}) async {
  final l10n = context.l10n;
  final kinds = [
    for (final k in EventKind.values)
      if (!k.isBirthday || offerBirthday) k,
  ];
  final kind = await showModalBottomSheet<EventKind>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    // Eight occasions outgrow a short screen: the list scrolls under a cap
    // taken from layout, not MediaQuery.
    isScrollControlled: true,
    builder: (sheetContext) => LayoutBuilder(
      builder: (_, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: KeptSpacing.lg),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KeptSpacing.lg,
                0,
                KeptSpacing.lg,
                KeptSpacing.sm,
              ),
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (final k in kinds)
              ListTile(
                leading: KeptIconBadge(k.icon),
                title: Text(k.label(l10n)),
                subtitle: k.isBirthday && !birthdayAvailable
                    ? Text(l10n.eventsKindNeedsBirthday)
                    : null,
                enabled: !(k.isBirthday && !birthdayAvailable),
                onTap: () => Navigator.of(sheetContext).pop(k),
              ),
          ],
        ),
      ),
    ),
  );
  if (kind == null || !context.mounted) return null;

  DateTime? day;
  if (!kind.isBirthday) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    day = await showKeptDatePicker(
      context,
      initialDate: start,
      firstDate: start,
      lastDate: start.add(eventMaxLeadTime),
    );
    if (day == null || !context.mounted) return null;
  }

  String? name;
  if (kind.needsTitle) {
    name = await showDialog<String>(
      context: context,
      builder: (_) => const _TitleDialog(),
    );
    if (name == null || !context.mounted) return null;
  }
  return OccasionChoice(kind: kind, day: day, title: name);
}

/// Names an "other" occasion. Owns its controller so the dialog's exit
/// animation never touches a disposed one.
class _TitleDialog extends StatefulWidget {
  const _TitleDialog();

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.eventsTitleTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: eventTitleMaxLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: l10n.eventsTitleHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(context).pop(text);
          },
          child: Text(l10n.commonDone),
        ),
      ],
    );
  }
}
