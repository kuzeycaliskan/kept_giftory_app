// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

final class HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'300d208acc23eb2765c246b38d652ad2223e6799';

/// Upper Home section: friends' upcoming birthdays (real data).

@ProviderFor(upcomingBirthdays)
final upcomingBirthdaysProvider = UpcomingBirthdaysProvider._();

/// Upper Home section: friends' upcoming birthdays (real data).

final class UpcomingBirthdaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UpcomingBirthday>>,
          List<UpcomingBirthday>,
          FutureOr<List<UpcomingBirthday>>
        >
    with
        $FutureModifier<List<UpcomingBirthday>>,
        $FutureProvider<List<UpcomingBirthday>> {
  /// Upper Home section: friends' upcoming birthdays (real data).
  UpcomingBirthdaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingBirthdaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingBirthdaysHash();

  @$internal
  @override
  $FutureProviderElement<List<UpcomingBirthday>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UpcomingBirthday>> create(Ref ref) {
    return upcomingBirthdays(ref);
  }
}

String _$upcomingBirthdaysHash() => r'72324555c1198bb8abc2c1b7669851ad045ca9f5';

/// Lower Home section: my real social events (G-82; feed proper is V2/G-210).

@ProviderFor(homeEvents)
final homeEventsProvider = HomeEventsProvider._();

/// Lower Home section: my real social events (G-82; feed proper is V2/G-210).

final class HomeEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HomeEvent>>,
          List<HomeEvent>,
          FutureOr<List<HomeEvent>>
        >
    with $FutureModifier<List<HomeEvent>>, $FutureProvider<List<HomeEvent>> {
  /// Lower Home section: my real social events (G-82; feed proper is V2/G-210).
  HomeEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<HomeEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HomeEvent>> create(Ref ref) {
    return homeEvents(ref);
  }
}

String _$homeEventsHash() => r'ef45afa89004c535236329e73c562b984eddbe7f';

/// "A surprise is coming" card data (G-210); null = nothing pending.

@ProviderFor(surpriseTeaser)
final surpriseTeaserProvider = SurpriseTeaserProvider._();

/// "A surprise is coming" card data (G-210); null = nothing pending.

final class SurpriseTeaserProvider
    extends
        $FunctionalProvider<
          AsyncValue<SurpriseTeaser?>,
          SurpriseTeaser?,
          FutureOr<SurpriseTeaser?>
        >
    with $FutureModifier<SurpriseTeaser?>, $FutureProvider<SurpriseTeaser?> {
  /// "A surprise is coming" card data (G-210); null = nothing pending.
  SurpriseTeaserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'surpriseTeaserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$surpriseTeaserHash();

  @$internal
  @override
  $FutureProviderElement<SurpriseTeaser?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SurpriseTeaser?> create(Ref ref) {
    return surpriseTeaser(ref);
  }
}

String _$surpriseTeaserHash() => r'04ef9a766485062d6e6e6f983b720dd864199418';
