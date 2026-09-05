// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inviteRepositoryHash() => r'e011f54bb68f548daf192c9f0d8a5baf38891584';

/// See also [inviteRepository].
@ProviderFor(inviteRepository)
final inviteRepositoryProvider = Provider<InviteRepository>.internal(
  inviteRepository,
  name: r'inviteRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inviteRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InviteRepositoryRef = ProviderRef<InviteRepository>;
String _$myInviteCodeHash() => r'cb8a3998e70501d0336a5293c4971dc664422aca';

/// See also [myInviteCode].
@ProviderFor(myInviteCode)
final myInviteCodeProvider = AutoDisposeFutureProvider<String>.internal(
  myInviteCode,
  name: r'myInviteCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myInviteCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyInviteCodeRef = AutoDisposeFutureProviderRef<String>;
String _$inviteControllerHash() => r'e0d3772d2cee035f6fdd2945733bacb8aa904e47';

/// See also [InviteController].
@ProviderFor(InviteController)
final inviteControllerProvider =
    AutoDisposeNotifierProvider<InviteController, AsyncValue<void>>.internal(
      InviteController.new,
      name: r'inviteControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inviteControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InviteController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
