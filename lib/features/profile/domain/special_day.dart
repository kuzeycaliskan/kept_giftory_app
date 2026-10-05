import 'package:flutter/foundation.dart';
import 'package:kept/features/events/domain/event_kind.dart';

/// An occasion a person announces on their own profile (G-410b): friends
/// see it among upcoming days and can open the gift event from there.
/// Never a birthday — that lives on the profile itself.
@immutable
class SpecialDay {
  const SpecialDay({
    required this.id,
    required this.userId,
    required this.kind,
    required this.day,
    this.title,
  });

  final String id;
  final String userId;
  final EventKind kind;

  /// Only for [EventKind.other].
  final String? title;
  final DateTime day;
}
