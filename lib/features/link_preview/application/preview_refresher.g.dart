// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Periodic price refresh, triggered by lists coming on screen: previews
/// whose slot looks due are offered to the server (which owns the clock and
/// claims the slot). One ask per link per app session, a few per load, so a
/// list never turns into a polling loop.

@ProviderFor(PreviewRefresher)
final previewRefresherProvider = PreviewRefresherProvider._();

/// Periodic price refresh, triggered by lists coming on screen: previews
/// whose slot looks due are offered to the server (which owns the clock and
/// claims the slot). One ask per link per app session, a few per load, so a
/// list never turns into a polling loop.
final class PreviewRefresherProvider
    extends $NotifierProvider<PreviewRefresher, void> {
  /// Periodic price refresh, triggered by lists coming on screen: previews
  /// whose slot looks due are offered to the server (which owns the clock and
  /// claims the slot). One ask per link per app session, a few per load, so a
  /// list never turns into a polling loop.
  PreviewRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewRefresherHash();

  @$internal
  @override
  PreviewRefresher create() => PreviewRefresher();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$previewRefresherHash() => r'ed5131915eb38878a3836642f97c4e0e9867c6c2';

/// Periodic price refresh, triggered by lists coming on screen: previews
/// whose slot looks due are offered to the server (which owns the clock and
/// claims the slot). One ask per link per app session, a few per load, so a
/// list never turns into a polling loop.

abstract class _$PreviewRefresher extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
