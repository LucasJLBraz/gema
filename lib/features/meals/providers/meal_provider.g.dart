// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayMealsHash() => r'6dcbf6c9acc51fcbefb181214b98a983a51b35e8';

/// See also [todayMeals].
@ProviderFor(todayMeals)
final todayMealsProvider = AutoDisposeStreamProvider<List<Meal>>.internal(
  todayMeals,
  name: r'todayMealsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayMealsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayMealsRef = AutoDisposeStreamProviderRef<List<Meal>>;
String _$mealsForDayHash() => r'7c744a3225758dadb781c34b4358c2e41ea50725';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [mealsForDay].
@ProviderFor(mealsForDay)
const mealsForDayProvider = MealsForDayFamily();

/// See also [mealsForDay].
class MealsForDayFamily extends Family<AsyncValue<List<Meal>>> {
  /// See also [mealsForDay].
  const MealsForDayFamily();

  /// See also [mealsForDay].
  MealsForDayProvider call(DateTime day) {
    return MealsForDayProvider(day);
  }

  @override
  MealsForDayProvider getProviderOverride(
    covariant MealsForDayProvider provider,
  ) {
    return call(provider.day);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mealsForDayProvider';
}

/// See also [mealsForDay].
class MealsForDayProvider extends AutoDisposeStreamProvider<List<Meal>> {
  /// See also [mealsForDay].
  MealsForDayProvider(DateTime day)
    : this._internal(
        (ref) => mealsForDay(ref as MealsForDayRef, day),
        from: mealsForDayProvider,
        name: r'mealsForDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mealsForDayHash,
        dependencies: MealsForDayFamily._dependencies,
        allTransitiveDependencies: MealsForDayFamily._allTransitiveDependencies,
        day: day,
      );

  MealsForDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.day,
  }) : super.internal();

  final DateTime day;

  @override
  Override overrideWith(
    Stream<List<Meal>> Function(MealsForDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MealsForDayProvider._internal(
        (ref) => create(ref as MealsForDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        day: day,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Meal>> createElement() {
    return _MealsForDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealsForDayProvider && other.day == day;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MealsForDayRef on AutoDisposeStreamProviderRef<List<Meal>> {
  /// The parameter `day` of this provider.
  DateTime get day;
}

class _MealsForDayProviderElement
    extends AutoDisposeStreamProviderElement<List<Meal>>
    with MealsForDayRef {
  _MealsForDayProviderElement(super.provider);

  @override
  DateTime get day => (origin as MealsForDayProvider).day;
}

String _$mealByIdHash() => r'030ceed07c72256a64ea78b3db9288a59a137a33';

/// See also [mealById].
@ProviderFor(mealById)
const mealByIdProvider = MealByIdFamily();

/// See also [mealById].
class MealByIdFamily extends Family<AsyncValue<Meal?>> {
  /// See also [mealById].
  const MealByIdFamily();

  /// See also [mealById].
  MealByIdProvider call(int id) {
    return MealByIdProvider(id);
  }

  @override
  MealByIdProvider getProviderOverride(covariant MealByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mealByIdProvider';
}

/// See also [mealById].
class MealByIdProvider extends AutoDisposeFutureProvider<Meal?> {
  /// See also [mealById].
  MealByIdProvider(int id)
    : this._internal(
        (ref) => mealById(ref as MealByIdRef, id),
        from: mealByIdProvider,
        name: r'mealByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mealByIdHash,
        dependencies: MealByIdFamily._dependencies,
        allTransitiveDependencies: MealByIdFamily._allTransitiveDependencies,
        id: id,
      );

  MealByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(FutureOr<Meal?> Function(MealByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: MealByIdProvider._internal(
        (ref) => create(ref as MealByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Meal?> createElement() {
    return _MealByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MealByIdRef on AutoDisposeFutureProviderRef<Meal?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _MealByIdProviderElement extends AutoDisposeFutureProviderElement<Meal?>
    with MealByIdRef {
  _MealByIdProviderElement(super.provider);

  @override
  int get id => (origin as MealByIdProvider).id;
}

String _$mealQueueNotifierHash() => r'c934f4bcac07e495d90b1a0510e84cf42c63eb56';

/// See also [MealQueueNotifier].
@ProviderFor(MealQueueNotifier)
final mealQueueNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MealQueueNotifier, List<Meal>>.internal(
      MealQueueNotifier.new,
      name: r'mealQueueNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mealQueueNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MealQueueNotifier = AutoDisposeAsyncNotifier<List<Meal>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
