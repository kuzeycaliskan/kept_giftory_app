// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$previewRefresherHash() => r'c7e482e560f27b54fcffc2092f17c8f312769b9c';

/// Periodic price refresh, triggered by lists coming on screen: previews
/// whose slot looks due are offered to the server (which owns the clock and
/// claims the slot). One ask per link per app session, a few per load, so a
/// list never turns into a polling loop.
///
/// Copied from [PreviewRefresher].
@ProviderFor(PreviewRefresher)
final previewRefresherProvider =
    NotifierProvider<PreviewRefresher, void>.internal(
      PreviewRefresher.new,
      name: r'previewRefresherProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$previewRefresherHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PreviewRefresher = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
