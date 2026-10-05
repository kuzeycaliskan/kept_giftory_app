// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventsRepository)
final eventsRepositoryProvider = EventsRepositoryProvider._();

final class EventsRepositoryProvider
    extends
        $FunctionalProvider<
          EventsRepository,
          EventsRepository,
          EventsRepository
        >
    with $Provider<EventsRepository> {
  EventsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventsRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventsRepository create(Ref ref) {
    return eventsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventsRepository>(value),
    );
  }
}

String _$eventsRepositoryHash() => r'0e8c5aa7c8a50f5244ab4928c4212fcb04f5de31';

/// Events I belong to (joined or invited), soonest first.

@ProviderFor(myEvents)
final myEventsProvider = MyEventsProvider._();

/// Events I belong to (joined or invited), soonest first.

final class MyEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GiftEvent>>,
          List<GiftEvent>,
          FutureOr<List<GiftEvent>>
        >
    with $FutureModifier<List<GiftEvent>>, $FutureProvider<List<GiftEvent>> {
  /// Events I belong to (joined or invited), soonest first.
  MyEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<GiftEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GiftEvent>> create(Ref ref) {
    return myEvents(ref);
  }
}

String _$myEventsHash() => r'83d76dd3d9040ee7aefadd5c2dc512b361d16f6d';

@ProviderFor(eventDetail)
final eventDetailProvider = EventDetailFamily._();

final class EventDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<GiftEvent?>,
          GiftEvent?,
          FutureOr<GiftEvent?>
        >
    with $FutureModifier<GiftEvent?>, $FutureProvider<GiftEvent?> {
  EventDetailProvider._({
    required EventDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventDetailHash();

  @override
  String toString() {
    return r'eventDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GiftEvent?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GiftEvent?> create(Ref ref) {
    final argument = this.argument as String;
    return eventDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventDetailHash() => r'd4bd2e6b7a60497a3a59340c3cc50637a34b0cb1';

final class EventDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GiftEvent?>, String> {
  EventDetailFamily._()
    : super(
        retry: null,
        name: r'eventDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventDetailProvider call(String eventId) =>
      EventDetailProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventDetailProvider';
}

@ProviderFor(invitableFriends)
final invitableFriendsProvider = InvitableFriendsFamily._();

final class InvitableFriendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileCard>>,
          List<ProfileCard>,
          FutureOr<List<ProfileCard>>
        >
    with
        $FutureModifier<List<ProfileCard>>,
        $FutureProvider<List<ProfileCard>> {
  InvitableFriendsProvider._({
    required InvitableFriendsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'invitableFriendsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invitableFriendsHash();

  @override
  String toString() {
    return r'invitableFriendsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProfileCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProfileCard>> create(Ref ref) {
    final argument = this.argument as String;
    return invitableFriends(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InvitableFriendsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invitableFriendsHash() => r'cf5435266eec153d1ec1a8ee4fc956ed58ca0888';

final class InvitableFriendsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProfileCard>>, String> {
  InvitableFriendsFamily._()
    : super(
        retry: null,
        name: r'invitableFriendsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InvitableFriendsProvider call(String eventId) =>
      InvitableFriendsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'invitableFriendsProvider';
}

/// Gifts logged against an event (members as they log, honoree once
/// revealed).

@ProviderFor(eventGifts)
final eventGiftsProvider = EventGiftsFamily._();

/// Gifts logged against an event (members as they log, honoree once
/// revealed).

final class EventGiftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GiftEntry>>,
          List<GiftEntry>,
          FutureOr<List<GiftEntry>>
        >
    with $FutureModifier<List<GiftEntry>>, $FutureProvider<List<GiftEntry>> {
  /// Gifts logged against an event (members as they log, honoree once
  /// revealed).
  EventGiftsProvider._({
    required EventGiftsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventGiftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventGiftsHash();

  @override
  String toString() {
    return r'eventGiftsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GiftEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GiftEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return eventGifts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventGiftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventGiftsHash() => r'b6a5f4259cec10979ba59c0c97c4f5cb92747246';

/// Gifts logged against an event (members as they log, honoree once
/// revealed).

final class EventGiftsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GiftEntry>>, String> {
  EventGiftsFamily._()
    : super(
        retry: null,
        name: r'eventGiftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Gifts logged against an event (members as they log, honoree once
  /// revealed).

  EventGiftsProvider call(String eventId) =>
      EventGiftsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventGiftsProvider';
}

/// Home row: the open event for a friend's occasion (null = none).

@ProviderFor(eventForHonoree)
final eventForHonoreeProvider = EventForHonoreeFamily._();

/// Home row: the open event for a friend's occasion (null = none).

final class EventForHonoreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventForHonoree?>,
          EventForHonoree?,
          FutureOr<EventForHonoree?>
        >
    with $FutureModifier<EventForHonoree?>, $FutureProvider<EventForHonoree?> {
  /// Home row: the open event for a friend's occasion (null = none).
  EventForHonoreeProvider._({
    required EventForHonoreeFamily super.from,
    required OccasionKey super.argument,
  }) : super(
         retry: null,
         name: r'eventForHonoreeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventForHonoreeHash();

  @override
  String toString() {
    return r'eventForHonoreeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EventForHonoree?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventForHonoree?> create(Ref ref) {
    final argument = this.argument as OccasionKey;
    return eventForHonoree(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventForHonoreeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventForHonoreeHash() => r'cabd9657c8cf4237da555ad888471261a148e227';

/// Home row: the open event for a friend's occasion (null = none).

final class EventForHonoreeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EventForHonoree?>, OccasionKey> {
  EventForHonoreeFamily._()
    : super(
        retry: null,
        name: r'eventForHonoreeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Home row: the open event for a friend's occasion (null = none).

  EventForHonoreeProvider call(OccasionKey key) =>
      EventForHonoreeProvider._(argument: key, from: this);

  @override
  String toString() => r'eventForHonoreeProvider';
}

/// Every write on events; refreshes the hub, the detail and the Home
/// lookups afterwards.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(EventsController)
final eventsControllerProvider = EventsControllerProvider._();

/// Every write on events; refreshes the hub, the detail and the Home
/// lookups afterwards.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class EventsControllerProvider
    extends $NotifierProvider<EventsController, AsyncValue<void>> {
  /// Every write on events; refreshes the hub, the detail and the Home
  /// lookups afterwards.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  EventsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventsControllerHash();

  @$internal
  @override
  EventsController create() => EventsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$eventsControllerHash() => r'dd21a303bcb95ecff7f11e41d5acf240ed0d7a79';

/// Every write on events; refreshes the hub, the detail and the Home
/// lookups afterwards.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$EventsController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
