// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_reaction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactions on gifts (G-210 slice 2): same rule as moments — tapping the
/// kind you already chose clears it, any other kind sets it.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(GiftReactionController)
final giftReactionControllerProvider = GiftReactionControllerProvider._();

/// Reactions on gifts (G-210 slice 2): same rule as moments — tapping the
/// kind you already chose clears it, any other kind sets it.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class GiftReactionControllerProvider
    extends $NotifierProvider<GiftReactionController, AsyncValue<void>> {
  /// Reactions on gifts (G-210 slice 2): same rule as moments — tapping the
  /// kind you already chose clears it, any other kind sets it.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  GiftReactionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftReactionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftReactionControllerHash();

  @$internal
  @override
  GiftReactionController create() => GiftReactionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$giftReactionControllerHash() =>
    r'6ba9a5dc2abd85f1f0ae0b3ba368b8d4f474669c';

/// Reactions on gifts (G-210 slice 2): same rule as moments — tapping the
/// kind you already chose clears it, any other kind sets it.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$GiftReactionController extends $Notifier<AsyncValue<void>> {
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
