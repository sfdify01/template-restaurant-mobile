// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentPositionHash() => r'9ad5ccd0cf66f0153fd05b353cecee30fc62bc73';

/// Provider for just the current position (for widgets that only need coordinates)
///
/// Copied from [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider = AutoDisposeProvider<LatLng?>.internal(
  currentPosition,
  name: r'currentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionRef = AutoDisposeProviderRef<LatLng?>;
String _$locationPermissionStatusHash() =>
    r'9c2c7326758c264ce79e8ac818f57a2e6dae436a';

/// Provider for permission status
///
/// Copied from [locationPermissionStatus].
@ProviderFor(locationPermissionStatus)
final locationPermissionStatusProvider =
    AutoDisposeProvider<LocationPermissionStatus>.internal(
      locationPermissionStatus,
      name: r'locationPermissionStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationPermissionStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationPermissionStatusRef =
    AutoDisposeProviderRef<LocationPermissionStatus>;
String _$hasLocationAccessHash() => r'5bb7bf87cef1565ffaaac0c8b1eb71f5adfd0cab';

/// Provider for whether location access is available
///
/// Copied from [hasLocationAccess].
@ProviderFor(hasLocationAccess)
final hasLocationAccessProvider = AutoDisposeProvider<bool>.internal(
  hasLocationAccess,
  name: r'hasLocationAccessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasLocationAccessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasLocationAccessRef = AutoDisposeProviderRef<bool>;
String _$currentAddressHash() => r'66aadabdb992e494d572909ec6348c9621b49935';

/// Provider for the current address
///
/// Copied from [currentAddress].
@ProviderFor(currentAddress)
final currentAddressProvider = AutoDisposeProvider<AddressResult?>.internal(
  currentAddress,
  name: r'currentAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentAddressRef = AutoDisposeProviderRef<AddressResult?>;
String _$locationHash() => r'ecef9c7b9d15247d04c9330ec4ed034467c2ef02';

/// Location provider managing device location and permissions
///
/// Copied from [Location].
@ProviderFor(Location)
final locationProvider = NotifierProvider<Location, LocationState>.internal(
  Location.new,
  name: r'locationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Location = Notifier<LocationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
