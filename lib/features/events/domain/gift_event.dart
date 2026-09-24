import 'package:flutter/foundation.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

/// Event lifecycle (wire values match `event_status`).
enum EventStatus { open, revealed, cancelled }

enum EventMemberRole { organizer, member }

/// Wire values match `event_member_status`.
enum EventMemberStatus { invited, joined, declined }

/// One participant of an event. [user] resolves through the discovery
/// card RPC (members are the honoree's friends, not necessarily mine).
@immutable
class EventMember {
  const EventMember({
    required this.userId,
    required this.role,
    required this.status,
    this.user,
  });

  final String userId;
  final EventMemberRole role;
  final EventMemberStatus status;
  final ProfileCard? user;

  String labelOr(String fallback) =>
      user?.displayName ?? user?.username ?? fallback;
}

/// A gift event as the viewer sees it (never the honoree — RLS). Members
/// are loaded with the event; the viewer's own row is [me].
@immutable
class GiftEvent {
  const GiftEvent({
    required this.id,
    required this.honoreeId,
    required this.eventDate,
    required this.revealAt,
    required this.status,
    required this.members,
    this.honoree,
    this.externalChatUrl,
    this.creatorId,
    this.commentCount = 0,
    this.revealedAt,
    this.thanksNote,
    this.thanksAt,
  });

  final String id;
  final String honoreeId;
  final ProfileCard? honoree;
  final DateTime eventDate;
  final DateTime revealAt;
  final EventStatus status;
  final String? externalChatUrl;
  final String? creatorId;
  final List<EventMember> members;

  /// Notes on the board (visible ones); the list loads on demand.
  final int commentCount;

  /// G-306: when the state machine (or the organizer) opened the event.
  final DateTime? revealedAt;

  /// G-307: the honoree's one thank-you, once written.
  final String? thanksNote;
  final DateTime? thanksAt;

  String honoreeLabel(String fallback) =>
      honoree?.displayName ?? honoree?.username ?? fallback;

  EventMember? me(String? userId) =>
      members.where((m) => m.userId == userId).firstOrNull;

  bool isOrganizer(String? userId) =>
      me(userId)?.role == EventMemberRole.organizer &&
      me(userId)?.status == EventMemberStatus.joined;

  bool isInvited(String? userId) =>
      me(userId)?.status == EventMemberStatus.invited;

  List<EventMember> get joined =>
      members.where((m) => m.status == EventMemberStatus.joined).toList();

  List<EventMember> get invited =>
      members.where((m) => m.status == EventMemberStatus.invited).toList();

  bool get isOpen => status == EventStatus.open;

  bool get isRevealed => status == EventStatus.revealed;

  /// The birthday person — sees the event only once revealed (RLS).
  bool isHonoree(String? userId) => userId != null && honoreeId == userId;

  GiftEvent copyWith({List<EventMember>? members, ProfileCard? honoree}) =>
      GiftEvent(
        id: id,
        honoreeId: honoreeId,
        honoree: honoree ?? this.honoree,
        eventDate: eventDate,
        revealAt: revealAt,
        status: status,
        externalChatUrl: externalChatUrl,
        creatorId: creatorId,
        members: members ?? this.members,
        commentCount: commentCount,
        revealedAt: revealedAt,
        thanksNote: thanksNote,
        thanksAt: thanksAt,
      );
}

/// What the Home row needs to decide between "open an event" and "go to
/// the event": the open event for a friend's next birthday, if any.
@immutable
class EventForHonoree {
  const EventForHonoree({
    required this.eventId,
    required this.eventDate,
    this.myStatus,
  });

  final String eventId;
  final DateTime eventDate;

  /// Null = an event exists but I'm not part of it yet.
  final EventMemberStatus? myStatus;
}
