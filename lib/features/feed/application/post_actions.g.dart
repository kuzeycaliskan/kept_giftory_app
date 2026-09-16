// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postActionsHash() => r'8944991f79b022d7d415770d20c57553f1600064';

/// Owner actions on a live moment (currently: delete). Kept apart from the
/// composer so the viewer doesn't drag the capture pipeline in.
///
/// Copied from [PostActions].
@ProviderFor(PostActions)
final postActionsProvider =
    AutoDisposeNotifierProvider<PostActions, AsyncValue<void>>.internal(
      PostActions.new,
      name: r'postActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
