// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(giftRepository)
final giftRepositoryProvider = GiftRepositoryProvider._();

final class GiftRepositoryProvider
    extends $FunctionalProvider<GiftRepository, GiftRepository, GiftRepository>
    with $Provider<GiftRepository> {
  GiftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftRepositoryHash();

  @$internal
  @override
  $ProviderElement<GiftRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GiftRepository create(Ref ref) {
    return giftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GiftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GiftRepository>(value),
    );
  }
}

String _$giftRepositoryHash() => r'b42281e23468401c9783cad5f923ea099df64419';

@ProviderFor(givenGifts)
final givenGiftsProvider = GivenGiftsProvider._();

final class GivenGiftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GiftEntry>>,
          List<GiftEntry>,
          FutureOr<List<GiftEntry>>
        >
    with $FutureModifier<List<GiftEntry>>, $FutureProvider<List<GiftEntry>> {
  GivenGiftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'givenGiftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$givenGiftsHash();

  @$internal
  @override
  $FutureProviderElement<List<GiftEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GiftEntry>> create(Ref ref) {
    return givenGifts(ref);
  }
}

String _$givenGiftsHash() => r'8c4b6e9d7c629fe2e1a58cd2971a643e9c76965e';

@ProviderFor(receivedGifts)
final receivedGiftsProvider = ReceivedGiftsProvider._();

final class ReceivedGiftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GiftEntry>>,
          List<GiftEntry>,
          FutureOr<List<GiftEntry>>
        >
    with $FutureModifier<List<GiftEntry>>, $FutureProvider<List<GiftEntry>> {
  ReceivedGiftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receivedGiftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receivedGiftsHash();

  @$internal
  @override
  $FutureProviderElement<List<GiftEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GiftEntry>> create(Ref ref) {
    return receivedGifts(ref);
  }
}

String _$receivedGiftsHash() => r'9dbbafe0276b23a7521aa3633b536c4284ee2469';

/// A friend's gift history (G-52); RLS applies visibility + surprise rules.

@ProviderFor(friendGiftHistory)
final friendGiftHistoryProvider = FriendGiftHistoryFamily._();

/// A friend's gift history (G-52); RLS applies visibility + surprise rules.

final class FriendGiftHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GiftEntry>>,
          List<GiftEntry>,
          FutureOr<List<GiftEntry>>
        >
    with $FutureModifier<List<GiftEntry>>, $FutureProvider<List<GiftEntry>> {
  /// A friend's gift history (G-52); RLS applies visibility + surprise rules.
  FriendGiftHistoryProvider._({
    required FriendGiftHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'friendGiftHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$friendGiftHistoryHash();

  @override
  String toString() {
    return r'friendGiftHistoryProvider'
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
    return friendGiftHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendGiftHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$friendGiftHistoryHash() => r'fd3d520d35c063ffe50078179d483671217d60dc';

/// A friend's gift history (G-52); RLS applies visibility + surprise rules.

final class FriendGiftHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GiftEntry>>, String> {
  FriendGiftHistoryFamily._()
    : super(
        retry: null,
        name: r'friendGiftHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A friend's gift history (G-52); RLS applies visibility + surprise rules.

  FriendGiftHistoryProvider call(String profileId) =>
      FriendGiftHistoryProvider._(argument: profileId, from: this);

  @override
  String toString() => r'friendGiftHistoryProvider';
}

/// One gift with photos, for the detail screen. Refetched (not read from
/// the list caches) so photo edits show without juggling three lists.

@ProviderFor(giftDetail)
final giftDetailProvider = GiftDetailFamily._();

/// One gift with photos, for the detail screen. Refetched (not read from
/// the list caches) so photo edits show without juggling three lists.

final class GiftDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<GiftEntry?>,
          GiftEntry?,
          FutureOr<GiftEntry?>
        >
    with $FutureModifier<GiftEntry?>, $FutureProvider<GiftEntry?> {
  /// One gift with photos, for the detail screen. Refetched (not read from
  /// the list caches) so photo edits show without juggling three lists.
  GiftDetailProvider._({
    required GiftDetailFamily super.from,
    required (String, {bool counterpartIsGiver}) super.argument,
  }) : super(
         retry: null,
         name: r'giftDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$giftDetailHash();

  @override
  String toString() {
    return r'giftDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<GiftEntry?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GiftEntry?> create(Ref ref) {
    final argument = this.argument as (String, {bool counterpartIsGiver});
    return giftDetail(
      ref,
      argument.$1,
      counterpartIsGiver: argument.counterpartIsGiver,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GiftDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$giftDetailHash() => r'49c48204d973b7ba1cda105a173fe69bb0e33bb2';

/// One gift with photos, for the detail screen. Refetched (not read from
/// the list caches) so photo edits show without juggling three lists.

final class GiftDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<GiftEntry?>,
          (String, {bool counterpartIsGiver})
        > {
  GiftDetailFamily._()
    : super(
        retry: null,
        name: r'giftDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One gift with photos, for the detail screen. Refetched (not read from
  /// the list caches) so photo edits show without juggling three lists.

  GiftDetailProvider call(String giftId, {required bool counterpartIsGiver}) =>
      GiftDetailProvider._(
        argument: (giftId, counterpartIsGiver: counterpartIsGiver),
        from: this,
      );

  @override
  String toString() => r'giftDetailProvider';
}

@ProviderFor(GiftsController)
final giftsControllerProvider = GiftsControllerProvider._();

final class GiftsControllerProvider
    extends $NotifierProvider<GiftsController, AsyncValue<void>> {
  GiftsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftsControllerHash();

  @$internal
  @override
  GiftsController create() => GiftsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$giftsControllerHash() => r'0582bb4f3fbee7bae2dcc1203fa204b717050712';

abstract class _$GiftsController extends $Notifier<AsyncValue<void>> {
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
