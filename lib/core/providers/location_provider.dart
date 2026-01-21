import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/location_service.dart';

part 'location_provider.g.dart';

/// Location state holding current position, permission status, and loading state
class LocationState {
  final LatLng? currentPosition;
  final LocationPermissionStatus permissionStatus;
  final AddressResult? currentAddress;
  final bool isLoading;
  final bool isWatchingPosition;
  final String? errorMessage;

  const LocationState({
    this.currentPosition,
    this.permissionStatus = LocationPermissionStatus.denied,
    this.currentAddress,
    this.isLoading = false,
    this.isWatchingPosition = false,
    this.errorMessage,
  });

  /// Whether location access is available
  bool get hasLocationAccess => permissionStatus.allowsLocationAccess;

  /// Whether we have a valid position
  bool get hasPosition => currentPosition != null;

  LocationState copyWith({
    LatLng? currentPosition,
    LocationPermissionStatus? permissionStatus,
    AddressResult? currentAddress,
    bool? isLoading,
    bool? isWatchingPosition,
    String? errorMessage,
    bool clearError = false,
    bool clearAddress = false,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      currentAddress: clearAddress
          ? null
          : (currentAddress ?? this.currentAddress),
      isLoading: isLoading ?? this.isLoading,
      isWatchingPosition: isWatchingPosition ?? this.isWatchingPosition,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Location provider managing device location and permissions
@Riverpod(keepAlive: true)
class Location extends _$Location {
  final _locationService = LocationService.instance;
  StreamSubscription<Position>? _positionSubscription;

  @override
  LocationState build() {
    // Check initial permission status on startup
    _checkInitialPermission();

    // Clean up stream subscription when provider is disposed
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });

    return const LocationState();
  }

  Future<void> _checkInitialPermission() async {
    final status = await _locationService.checkPermissionStatus();
    state = state.copyWith(permissionStatus: status);

    // If we already have permission, try to get last known location
    if (status.allowsLocationAccess) {
      final lastKnown = await _locationService.getLastKnownLocation();
      if (lastKnown.isSuccess) {
        state = state.copyWith(
          currentPosition: LatLng(lastKnown.latitude!, lastKnown.longitude!),
        );
      }
    }
  }

  // ==========================================================================
  // PERMISSION MANAGEMENT
  // ==========================================================================

  /// Request location permission from the user
  Future<LocationPermissionStatus> requestPermission() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final status = await _locationService.requestLocationPermission();
    state = state.copyWith(permissionStatus: status, isLoading: false);

    // If granted, try to get current location
    if (status.allowsLocationAccess) {
      await getCurrentLocation();
    }

    return status;
  }

  /// Open location settings (when services are disabled)
  Future<bool> openLocationSettings() async {
    return await _locationService.openLocationSettings();
  }

  /// Open app settings (when permission is permanently denied)
  Future<bool> openAppSettings() async {
    return await _locationService.openAppSettings();
  }

  // ==========================================================================
  // LOCATION FETCHING
  // ==========================================================================

  /// Get current device location
  Future<LocationResult> getCurrentLocation({
    bool highAccuracy = true,
    bool includeAddress = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _locationService.getCurrentLocation(
      highAccuracy: highAccuracy,
    );

    if (result.isSuccess) {
      final position = LatLng(result.latitude!, result.longitude!);
      state = state.copyWith(
        currentPosition: position,
        permissionStatus: LocationPermissionStatus.granted,
        isLoading: false,
      );

      // Optionally get address for the location
      if (includeAddress) {
        await _fetchAddressForPosition(position);
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
        permissionStatus: result.permissionStatus ?? state.permissionStatus,
      );
    }

    return result;
  }

  /// Fetch address for a given position
  Future<AddressResult> _fetchAddressForPosition(LatLng position) async {
    final addressResult = await _locationService.getAddressFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (addressResult.isSuccess) {
      state = state.copyWith(currentAddress: addressResult);
    }

    return addressResult;
  }

  /// Get current location with address
  Future<AddressResult> getCurrentLocationWithAddress({
    bool highAccuracy = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _locationService.getCurrentLocationWithAddress(
      highAccuracy: highAccuracy,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        currentPosition: LatLng(result.latitude!, result.longitude!),
        currentAddress: result,
        permissionStatus: LocationPermissionStatus.granted,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      );
    }

    return result;
  }

  // ==========================================================================
  // POSITION WATCHING (for real-time updates)
  // ==========================================================================

  /// Start watching position changes
  void startWatchingPosition({
    bool highAccuracy = true,
    int distanceFilter = 10,
  }) {
    if (state.isWatchingPosition) return;

    state = state.copyWith(isWatchingPosition: true);

    _positionSubscription = _locationService
        .getLocationStream(
          highAccuracy: highAccuracy,
          distanceFilter: distanceFilter,
        )
        .listen(
          (position) {
            state = state.copyWith(
              currentPosition: LatLng(position.latitude, position.longitude),
            );
          },
          onError: (error) {
            if (kDebugMode) {
              print('Position stream error: $error');
            }
            state = state.copyWith(
              isWatchingPosition: false,
              errorMessage: 'Location updates stopped: $error',
            );
          },
        );
  }

  /// Stop watching position changes
  void stopWatchingPosition() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    state = state.copyWith(isWatchingPosition: false);
  }

  // ==========================================================================
  // GEOCODING
  // ==========================================================================

  /// Get address from coordinates
  Future<AddressResult> getAddressFromCoordinates(LatLng position) async {
    return await _locationService.getAddressFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Get coordinates from address string
  Future<LocationResult> getCoordinatesFromAddress(String address) async {
    return await _locationService.getCoordinatesFromAddress(address);
  }

  // ==========================================================================
  // DISTANCE CALCULATIONS
  // ==========================================================================

  /// Calculate distance from current position to a target in miles
  double? distanceToMiles(LatLng target) {
    if (state.currentPosition == null) return null;

    return _locationService.calculateDistanceMiles(
      startLat: state.currentPosition!.latitude,
      startLng: state.currentPosition!.longitude,
      endLat: target.latitude,
      endLng: target.longitude,
    );
  }

  /// Calculate distance between two points in miles
  double calculateDistanceMiles(LatLng from, LatLng to) {
    return _locationService.calculateDistanceMiles(
      startLat: from.latitude,
      startLng: from.longitude,
      endLat: to.latitude,
      endLng: to.longitude,
    );
  }

  // ==========================================================================
  // STATE MANAGEMENT
  // ==========================================================================

  /// Clear any error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Update position manually (e.g., from map picker)
  void setPosition(LatLng position) {
    state = state.copyWith(currentPosition: position, clearAddress: true);
  }

  /// Update position with address
  Future<void> setPositionWithAddress(LatLng position) async {
    state = state.copyWith(
      currentPosition: position,
      clearAddress: true,
      isLoading: true,
    );

    final addressResult = await _locationService.getAddressFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    state = state.copyWith(
      currentAddress: addressResult.isSuccess ? addressResult : null,
      isLoading: false,
    );
  }
}

// =============================================================================
// CONVENIENCE PROVIDERS
// =============================================================================

/// Provider for just the current position (for widgets that only need coordinates)
@riverpod
LatLng? currentPosition(Ref ref) {
  return ref.watch(locationProvider).currentPosition;
}

/// Provider for permission status
@riverpod
LocationPermissionStatus locationPermissionStatus(Ref ref) {
  return ref.watch(locationProvider).permissionStatus;
}

/// Provider for whether location access is available
@riverpod
bool hasLocationAccess(Ref ref) {
  return ref.watch(locationProvider).hasLocationAccess;
}

/// Provider for the current address
@riverpod
AddressResult? currentAddress(Ref ref) {
  return ref.watch(locationProvider).currentAddress;
}
