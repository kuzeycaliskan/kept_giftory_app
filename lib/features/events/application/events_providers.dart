import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/events/data/supabase_events_repository.dart';
import 'package:kept/features/events/domain/events_repository.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events_providers.g.dart';

@Riverpod(keepAlive: true)
EventsRepository eventsRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyEventsRepository();
  return SupabaseEventsRepository(ref.watch(supabaseClientProvider));
}

/// Events I belong to (joined or invited), soonest first.
@riverpod
Future<List<GiftEvent>> myEvents(Ref ref) async {
  final result = await ref.watch(eventsRepositoryProvider).fetchMine();
  return result.when(success: (l) => l, failure: (f) => throw f);
}

@riverpod
Future<GiftEvent?> eventDetail(Ref ref, String eventId) async {
  final result = await ref.watch(eventsRepositoryProvider).fetchEvent(eventId);
  return result.when(success: (e) => e, failure: (f) => throw f);
}

@riverpod
Future<List<ProfileCard>> invitableFriends(Ref ref, String eventId) async {
  final result = await ref
      .watch(eventsRepositoryProvider)
      .invitableFriends(eventId);
  return result.when(success: (l) => l, failure: (f) => throw f);
}

/// Gifts logged against an event (members as they log, honoree once
/// revealed).
@riverpod
Future<List<GiftEntry>> eventGifts(Ref ref, String eventId) async {
  final result = await ref
      .watch(eventsRepositoryProvider)
      .fetchEventGifts(eventId);
  return result.when(success: (l) => l, failure: (f) => throw f);
}

/// Home row: the open event for a friend's next birthday (null = none).
@riverpod
Future<EventForHonoree?> eventForHonoree(Ref ref, String honoreeId) async {
  final result = await ref
      .watch(eventsRepositoryProvider)
      .eventForHonoree(honoreeId);
  return result.when(success: (e) => e, failure: (f) => throw f);
}

/// Every write on events; refreshes the hub, the detail and the Home
/// lookups afterwards.
@riverpod
class EventsController extends _$EventsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the event id (created or joined), null on failure.
  Future<String?> createOrJoin(String honoreeId) async {
    state = const AsyncLoading();
    final result = await ref
        .read(eventsRepositoryProvider)
        .createOrJoin(honoreeId);
    return result.when(
      success: (id) {
        _refresh();
        state = const AsyncData(null);
        return id;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
    );
  }

  Future<bool> invite(String eventId, String userId) =>
      _run(() => ref.read(eventsRepositoryProvider).invite(eventId, userId));

  Future<bool> respond(String eventId, {required bool join}) => _run(
    () => ref.read(eventsRepositoryProvider).respond(eventId, join: join),
  );

  Future<bool> leave(String eventId) =>
      _run(() => ref.read(eventsRepositoryProvider).leave(eventId));

  Future<bool> cancel(String eventId) =>
      _run(() => ref.read(eventsRepositoryProvider).cancel(eventId));

  Future<bool> setChatUrl(String eventId, String? url) =>
      _run(() => ref.read(eventsRepositoryProvider).setChatUrl(eventId, url));

  Future<bool> reveal(String eventId) =>
      _run(() => ref.read(eventsRepositoryProvider).reveal(eventId));

  Future<bool> thank(String eventId, String note) =>
      _run(() => ref.read(eventsRepositoryProvider).thank(eventId, note));

  Future<bool> _run(Future<Result<void>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.when(
      success: (_) {
        _refresh();
        state = const AsyncData(null);
        return true;
      },
      failure: (Failure failure) {
        debugPrint('event action failed: $failure');
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }

  void _refresh() {
    ref
      ..invalidate(myEventsProvider)
      ..invalidate(eventDetailProvider)
      ..invalidate(invitableFriendsProvider)
      ..invalidate(eventGiftsProvider)
      ..invalidate(eventForHonoreeProvider);
  }
}
