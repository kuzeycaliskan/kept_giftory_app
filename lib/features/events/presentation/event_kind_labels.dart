import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/events/domain/gift_event.dart';

/// One place for how an occasion reads and looks.
extension EventKindLabels on EventKind {
  String label(AppLocalizations l10n) => switch (this) {
    EventKind.birthday => l10n.eventKindBirthday,
    EventKind.newBaby => l10n.eventKindNewBaby,
    EventKind.wedding => l10n.eventKindWedding,
    EventKind.newJob => l10n.eventKindNewJob,
    EventKind.graduation => l10n.eventKindGraduation,
    EventKind.newHome => l10n.eventKindNewHome,
    EventKind.retirement => l10n.eventKindRetirement,
    EventKind.other => l10n.eventKindOther,
  };

  IconData get icon => switch (this) {
    EventKind.birthday => Icons.cake_outlined,
    EventKind.newBaby => Icons.child_care_outlined,
    EventKind.wedding => Icons.favorite_outline,
    EventKind.newJob => Icons.work_outline,
    EventKind.graduation => Icons.school_outlined,
    EventKind.newHome => Icons.home_outlined,
    EventKind.retirement => Icons.beach_access_outlined,
    EventKind.other => Icons.celebration_outlined,
  };
}

extension GiftEventLabels on GiftEvent {
  /// "Ali's birthday" / "Ali · New baby" / an "other" event's own title.
  /// Suffix-free in Turkish on purpose: possessives bend with the name.
  String label(AppLocalizations l10n) {
    final name = honoreeLabel(l10n.giftAnonymousGiver);
    return switch (kind) {
      EventKind.birthday => l10n.eventsRowTitle(name),
      EventKind.other => title ?? name,
      _ => l10n.eventsRowTitleKind(name, kind.label(l10n)),
    };
  }

  /// What the honoree sees it called once revealed: "Your birthday",
  /// otherwise the occasion itself.
  String honoreeFacingLabel(AppLocalizations l10n) => switch (kind) {
    EventKind.birthday => l10n.eventsHonoreeRowTitle,
    EventKind.other => title ?? kind.label(l10n),
    _ => kind.label(l10n),
  };
}
