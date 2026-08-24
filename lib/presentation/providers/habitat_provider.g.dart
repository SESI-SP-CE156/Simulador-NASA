// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habitat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitatResultHash() => r'0bd6bd1bb5aa6a021510d36147f52a2225be65eb';

/// See also [habitatResult].
@ProviderFor(habitatResult)
final habitatResultProvider = AutoDisposeProvider<HabitatResult>.internal(
  habitatResult,
  name: r'habitatResultProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitatResultHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitatResultRef = AutoDisposeProviderRef<HabitatResult>;
String _$habitatControllerHash() => r'70f615eaaafa6ab0a98e0e68d1009947f000ac45';

/// See also [HabitatController].
@ProviderFor(HabitatController)
final habitatControllerProvider =
    AutoDisposeNotifierProvider<HabitatController, HabitatInputState>.internal(
      HabitatController.new,
      name: r'habitatControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$habitatControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HabitatController = AutoDisposeNotifier<HabitatInputState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
