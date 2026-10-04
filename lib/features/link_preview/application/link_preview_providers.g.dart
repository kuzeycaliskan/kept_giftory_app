// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preview_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkPreviewRepository)
final linkPreviewRepositoryProvider = LinkPreviewRepositoryProvider._();

final class LinkPreviewRepositoryProvider
    extends
        $FunctionalProvider<
          LinkPreviewRepository,
          LinkPreviewRepository,
          LinkPreviewRepository
        >
    with $Provider<LinkPreviewRepository> {
  LinkPreviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkPreviewRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkPreviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<LinkPreviewRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinkPreviewRepository create(Ref ref) {
    return linkPreviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkPreviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkPreviewRepository>(value),
    );
  }
}

String _$linkPreviewRepositoryHash() =>
    r'd92c1959fbb21d7cdc719a8c5e9ba9a2df7c5a34';
