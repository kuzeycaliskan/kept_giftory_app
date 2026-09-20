// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventsRepositoryHash() => r'0e8c5aa7c8a50f5244ab4928c4212fcb04f5de31';

/// See also [eventsRepository].
@ProviderFor(eventsRepository)
final eventsRepositoryProvider = Provider<EventsRepository>.internal(
  eventsRepository,
  name: r'eventsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventsRepositoryRef = ProviderRef<EventsRepository>;
String _$myEventsHash() => r'83d76dd3d9040ee7aefadd5c2dc512b361d16f6d';

/// Events I belong to (joined or invited), soonest first.
///
/// Copied from [myEvents].
@ProviderFor(myEvents)
final myEventsProvider = AutoDisposeFutureProvider<List<GiftEvent>>.internal(
  myEvents,
  name: r'myEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyEventsRef = AutoDisposeFutureProviderRef<List<GiftEvent>>;
String _$eventDetailHash() => r'd4bd2e6b7a60497a3a59340c3cc50637a34b0cb1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [eventDetail].
@ProviderFor(eventDetail)
const eventDetailProvider = EventDetailFamily();

/// See also [eventDetail].
class EventDetailFamily extends Family<AsyncValue<GiftEvent?>> {
  /// See also [eventDetail].
  const EventDetailFamily();

  /// See also [eventDetail].
  EventDetailProvider call(String eventId) {
    return EventDetailProvider(eventId);
  }

  @override
  EventDetailProvider getProviderOverride(
    covariant EventDetailProvider provider,
  ) {
    return call(provider.eventId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventDetailProvider';
}

/// See also [eventDetail].
class EventDetailProvider extends AutoDisposeFutureProvider<GiftEvent?> {
  /// See also [eventDetail].
  EventDetailProvider(String eventId)
    : this._internal(
        (ref) => eventDetail(ref as EventDetailRef, eventId),
        from: eventDetailProvider,
        name: r'eventDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$eventDetailHash,
        dependencies: EventDetailFamily._dependencies,
        allTransitiveDependencies: EventDetailFamily._allTransitiveDependencies,
        eventId: eventId,
      );

  EventDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventId,
  }) : super.internal();

  final String eventId;

  @override
  Override overrideWith(
    FutureOr<GiftEvent?> Function(EventDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventDetailProvider._internal(
        (ref) => create(ref as EventDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventId: eventId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<GiftEvent?> createElement() {
    return _EventDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventDetailProvider && other.eventId == eventId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventDetailRef on AutoDisposeFutureProviderRef<GiftEvent?> {
  /// The parameter `eventId` of this provider.
  String get eventId;
}

class _EventDetailProviderElement
    extends AutoDisposeFutureProviderElement<GiftEvent?>
    with EventDetailRef {
  _EventDetailProviderElement(super.provider);

  @override
  String get eventId => (origin as EventDetailProvider).eventId;
}

String _$invitableFriendsHash() => r'cf5435266eec153d1ec1a8ee4fc956ed58ca0888';

/// See also [invitableFriends].
@ProviderFor(invitableFriends)
const invitableFriendsProvider = InvitableFriendsFamily();

/// See also [invitableFriends].
class InvitableFriendsFamily extends Family<AsyncValue<List<ProfileCard>>> {
  /// See also [invitableFriends].
  const InvitableFriendsFamily();

  /// See also [invitableFriends].
  InvitableFriendsProvider call(String eventId) {
    return InvitableFriendsProvider(eventId);
  }

  @override
  InvitableFriendsProvider getProviderOverride(
    covariant InvitableFriendsProvider provider,
  ) {
    return call(provider.eventId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'invitableFriendsProvider';
}

/// See also [invitableFriends].
class InvitableFriendsProvider
    extends AutoDisposeFutureProvider<List<ProfileCard>> {
  /// See also [invitableFriends].
  InvitableFriendsProvider(String eventId)
    : this._internal(
        (ref) => invitableFriends(ref as InvitableFriendsRef, eventId),
        from: invitableFriendsProvider,
        name: r'invitableFriendsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$invitableFriendsHash,
        dependencies: InvitableFriendsFamily._dependencies,
        allTransitiveDependencies:
            InvitableFriendsFamily._allTransitiveDependencies,
        eventId: eventId,
      );

  InvitableFriendsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventId,
  }) : super.internal();

  final String eventId;

  @override
  Override overrideWith(
    FutureOr<List<ProfileCard>> Function(InvitableFriendsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvitableFriendsProvider._internal(
        (ref) => create(ref as InvitableFriendsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventId: eventId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProfileCard>> createElement() {
    return _InvitableFriendsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvitableFriendsProvider && other.eventId == eventId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InvitableFriendsRef on AutoDisposeFutureProviderRef<List<ProfileCard>> {
  /// The parameter `eventId` of this provider.
  String get eventId;
}

class _InvitableFriendsProviderElement
    extends AutoDisposeFutureProviderElement<List<ProfileCard>>
    with InvitableFriendsRef {
  _InvitableFriendsProviderElement(super.provider);

  @override
  String get eventId => (origin as InvitableFriendsProvider).eventId;
}

String _$eventForHonoreeHash() => r'94d52fd6ee959f09ab47a48bb8c6d041b795fbe0';

/// Home row: the open event for a friend's next birthday (null = none).
///
/// Copied from [eventForHonoree].
@ProviderFor(eventForHonoree)
const eventForHonoreeProvider = EventForHonoreeFamily();

/// Home row: the open event for a friend's next birthday (null = none).
///
/// Copied from [eventForHonoree].
class EventForHonoreeFamily extends Family<AsyncValue<EventForHonoree?>> {
  /// Home row: the open event for a friend's next birthday (null = none).
  ///
  /// Copied from [eventForHonoree].
  const EventForHonoreeFamily();

  /// Home row: the open event for a friend's next birthday (null = none).
  ///
  /// Copied from [eventForHonoree].
  EventForHonoreeProvider call(String honoreeId) {
    return EventForHonoreeProvider(honoreeId);
  }

  @override
  EventForHonoreeProvider getProviderOverride(
    covariant EventForHonoreeProvider provider,
  ) {
    return call(provider.honoreeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventForHonoreeProvider';
}

/// Home row: the open event for a friend's next birthday (null = none).
///
/// Copied from [eventForHonoree].
class EventForHonoreeProvider
    extends AutoDisposeFutureProvider<EventForHonoree?> {
  /// Home row: the open event for a friend's next birthday (null = none).
  ///
  /// Copied from [eventForHonoree].
  EventForHonoreeProvider(String honoreeId)
    : this._internal(
        (ref) => eventForHonoree(ref as EventForHonoreeRef, honoreeId),
        from: eventForHonoreeProvider,
        name: r'eventForHonoreeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$eventForHonoreeHash,
        dependencies: EventForHonoreeFamily._dependencies,
        allTransitiveDependencies:
            EventForHonoreeFamily._allTransitiveDependencies,
        honoreeId: honoreeId,
      );

  EventForHonoreeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.honoreeId,
  }) : super.internal();

  final String honoreeId;

  @override
  Override overrideWith(
    FutureOr<EventForHonoree?> Function(EventForHonoreeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventForHonoreeProvider._internal(
        (ref) => create(ref as EventForHonoreeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        honoreeId: honoreeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EventForHonoree?> createElement() {
    return _EventForHonoreeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventForHonoreeProvider && other.honoreeId == honoreeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, honoreeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventForHonoreeRef on AutoDisposeFutureProviderRef<EventForHonoree?> {
  /// The parameter `honoreeId` of this provider.
  String get honoreeId;
}

class _EventForHonoreeProviderElement
    extends AutoDisposeFutureProviderElement<EventForHonoree?>
    with EventForHonoreeRef {
  _EventForHonoreeProviderElement(super.provider);

  @override
  String get honoreeId => (origin as EventForHonoreeProvider).honoreeId;
}

String _$eventsControllerHash() => r'ac9ae2369259755695083ea07666333a505ca37c';

/// Every write on events; refreshes the hub, the detail and the Home
/// lookups afterwards.
///
/// Copied from [EventsController].
@ProviderFor(EventsController)
final eventsControllerProvider =
    AutoDisposeNotifierProvider<EventsController, AsyncValue<void>>.internal(
      EventsController.new,
      name: r'eventsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$eventsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EventsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
