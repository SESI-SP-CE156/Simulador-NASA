// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cargo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cargoStatsHash() => r'ed02e8165a77bd3c8d34111c4b961df3cc5fc249';

/// See also [cargoStats].
@ProviderFor(cargoStats)
final cargoStatsProvider = AutoDisposeProvider<Map<String, dynamic>>.internal(
  cargoStats,
  name: r'cargoStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cargoStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CargoStatsRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$cargoCapacityHash() => r'ce0b97c3a1f562d3efef29a810cb52707cd6c4a1';

/// See also [cargoCapacity].
@ProviderFor(cargoCapacity)
final cargoCapacityProvider =
    AutoDisposeProvider<
      ({
        double pesoTotal,
        double volumeTotal,
        bool pesoExcedido,
        bool volumeExcedido,
      })
    >.internal(
      cargoCapacity,
      name: r'cargoCapacityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cargoCapacityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CargoCapacityRef =
    AutoDisposeProviderRef<
      ({
        double pesoTotal,
        double volumeTotal,
        bool pesoExcedido,
        bool volumeExcedido,
      })
    >;
String _$cargoControllerHash() => r'8c63ecffa65ac8dabb634a3ca9f1910f123215d7';

/// See also [CargoController].
@ProviderFor(CargoController)
final cargoControllerProvider =
    AutoDisposeNotifierProvider<CargoController, CargoInventory>.internal(
      CargoController.new,
      name: r'cargoControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cargoControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CargoController = AutoDisposeNotifier<CargoInventory>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
