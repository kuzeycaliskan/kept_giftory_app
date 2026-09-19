// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_reaction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$giftReactionControllerHash() =>
    r'a712f4d9af52a0933c0c86c326a212e29560853f';

/// Reactions on gifts (G-210 slice 2): same rule as moments — tapping the
/// kind you already chose clears it, any other kind sets it.
///
/// Copied from [GiftReactionController].
@ProviderFor(GiftReactionController)
final giftReactionControllerProvider =
    AutoDisposeNotifierProvider<
      GiftReactionController,
      AsyncValue<void>
    >.internal(
      GiftReactionController.new,
      name: r'giftReactionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$giftReactionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GiftReactionController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
