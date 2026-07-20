// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weightHistoryHash() => r'c8890b0c05ed19e1393ce14d7e0e5fa292820e8c';

/// See also [weightHistory].
@ProviderFor(weightHistory)
final weightHistoryProvider =
    AutoDisposeFutureProvider<List<WeightEntry>>.internal(
  weightHistory,
  name: r'weightHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weightHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WeightHistoryRef = AutoDisposeFutureProviderRef<List<WeightEntry>>;
String _$smoothedWeightsHash() => r'695e7fce90f3da9153acf594386349823d83d045';

/// See also [smoothedWeights].
@ProviderFor(smoothedWeights)
final smoothedWeightsProvider =
    AutoDisposeFutureProvider<List<(DateTime, double)>>.internal(
  smoothedWeights,
  name: r'smoothedWeightsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$smoothedWeightsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SmoothedWeightsRef
    = AutoDisposeFutureProviderRef<List<(DateTime, double)>>;
String _$weightNotifierHash() => r'c479d325fb8ae708a0ced38c4fd89dd8a1c7c844';

/// See also [WeightNotifier].
@ProviderFor(WeightNotifier)
final weightNotifierProvider = AutoDisposeAsyncNotifierProvider<WeightNotifier,
    List<WeightEntry>>.internal(
  WeightNotifier.new,
  name: r'weightNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weightNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WeightNotifier = AutoDisposeAsyncNotifier<List<WeightEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
