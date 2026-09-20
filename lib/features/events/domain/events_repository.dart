import 'package:kept/core/error/result.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

/// Gift events boundary (V3.0-a). Everything that touches who-may-see or
/// who-may-join is enforced by RLS + definer RPCs; the repository never
/// filters visibility client-side.
abstract interface class EventsRepository {
  /// Events I belong to (joined or invited), soonest first.
  Future<Result<List<GiftEvent>>> fetchMine();

  /// One event with members; null when hidden from me / gone.
  Future<Result<GiftEvent?>> fetchEvent(String eventId);

  /// Opens the event for a friend's next birthday, or joins the existing
  /// one (server decides). Returns the event id.
  Future<Result<String>> createOrJoin(String honoreeId);

  /// The open event for a friend's next birthday, from my side.
  Future<Result<EventForHonoree?>> eventForHonoree(String honoreeId);

  /// Honoree's friends who can still be invited.
  Future<Result<List<ProfileCard>>> invitableFriends(String eventId);

  Future<Result<void>> invite(String eventId, String userId);

  /// Accept (true) or decline (false) my invitation.
  Future<Result<void>> respond(String eventId, {required bool join});

  Future<Result<void>> leave(String eventId);

  /// Organizer only (RLS).
  Future<Result<void>> cancel(String eventId);

  /// Organizer only (RLS); null clears.
  Future<Result<void>> setChatUrl(String eventId, String? url);
}
