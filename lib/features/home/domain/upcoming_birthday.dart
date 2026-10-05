import 'package:flutter/foundation.dart';
import 'package:kept/features/events/domain/event_kind.dart';

/// A friend's upcoming occasion for the Home "upcoming" section: their
/// birthday (from the profile) or a day they announced (G-410b).
@immutable
class UpcomingBirthday {
  const UpcomingBirthday({
    required this.friendId,
    required this.username,
    required this.birthday,
    required this.daysUntil,
    this.displayName,
    this.avatarUrl,
    this.kind = EventKind.birthday,
    this.title,
  });

  final String friendId;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  /// The occasion's date: the birthday (any year) or the announced day.
  final DateTime birthday;

  /// Which occasion (G-410b); [title] only for [EventKind.other].
  final EventKind kind;
  final String? title;

  /// 0 = today.
  final int daysUntil;

  String get label => displayName ?? username;
}
