import 'package:flutter/foundation.dart';

enum ActivityKind { friendAccepted, giftLogged, birthdayReminder }

/// One row of the Home activity panel.
///
/// V1: the panel is a scaffold fed by mock data (no real V1 event source —
/// feed/reactions arrive in V2, see G-82 note). Keep this model stable so the
/// V2 implementation only swaps the repository.
@immutable
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.kind,
    required this.text,
    required this.occurredAt,
  });

  final String id;
  final ActivityKind kind;
  final String text;
  final DateTime occurredAt;
}
