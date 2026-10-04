// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saves profile edits (G-23). Success refreshes [myProfileProvider] so the
/// Me screen and every other consumer re-render at once.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(EditProfileController)
final editProfileControllerProvider = EditProfileControllerProvider._();

/// Saves profile edits (G-23). Success refreshes [myProfileProvider] so the
/// Me screen and every other consumer re-render at once.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class EditProfileControllerProvider
    extends $NotifierProvider<EditProfileController, AsyncValue<void>> {
  /// Saves profile edits (G-23). Success refreshes [myProfileProvider] so the
  /// Me screen and every other consumer re-render at once.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  EditProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editProfileControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editProfileControllerHash();

  @$internal
  @override
  EditProfileController create() => EditProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$editProfileControllerHash() =>
    r'e3978d9dfd715fd7592862338e0b7d75b002662d';

/// Saves profile edits (G-23). Success refreshes [myProfileProvider] so the
/// Me screen and every other consumer re-render at once.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$EditProfileController extends $Notifier<AsyncValue<void>> {
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
