// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeGoalHash() => r'1278c5e18bd9fee67624196899bdc8d90512f027';

/// See also [activeGoal].
@ProviderFor(activeGoal)
final activeGoalProvider = AutoDisposeFutureProvider<Goal?>.internal(
  activeGoal,
  name: r'activeGoalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeGoalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveGoalRef = AutoDisposeFutureProviderRef<Goal?>;
String _$goalNotifierHash() => r'a25e290519a97c774aa5d149aca9e27415f61fc0';

/// See also [GoalNotifier].
@ProviderFor(GoalNotifier)
final goalNotifierProvider =
    AutoDisposeAsyncNotifierProvider<GoalNotifier, Goal?>.internal(
      GoalNotifier.new,
      name: r'goalNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$goalNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GoalNotifier = AutoDisposeAsyncNotifier<Goal?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
