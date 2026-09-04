import 'package:flutter/foundation.dart';

enum FriendshipStatus { pending, accepted, declined }

/// Direction of a pending request relative to the signed-in user.
enum RequestDirection { incoming, outgoing }

/// A friendship row joined with the OTHER party's profile, ready for the UI.
@immutable
class FriendEntry {
  const FriendEntry({
    required this.friendshipId,
    required this.profileId,
    required this.username,
    required this.status,
    this.displayName,
    this.avatarUrl,
    this.direction,
  });

  final String friendshipId;
  final String profileId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final FriendshipStatus status;

  /// Set only when [status] is [FriendshipStatus.pending].
  final RequestDirection? direction;

  String get label => displayName ?? username;
}
