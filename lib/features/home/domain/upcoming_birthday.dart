import 'package:flutter/foundation.dart';

/// A friend's upcoming birthday for the Home "important/upcoming" section.
@immutable
class UpcomingBirthday {
  const UpcomingBirthday({
    required this.friendId,
    required this.username,
    required this.birthday,
    required this.daysUntil,
    this.displayName,
    this.avatarUrl,
  });

  final String friendId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final DateTime birthday;

  /// 0 = today.
  final int daysUntil;

  String get label => displayName ?? username;
}
