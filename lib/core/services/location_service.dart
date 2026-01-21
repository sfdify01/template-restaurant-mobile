import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart';

/// Comprehensive location service with proper permission handling.
/// Uses permission_handler for explicit permission management and
/// geolocator for actual location fetching.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  /// Stream controller for location updates
  StreamSubscription<Position>? _positionStreamSubscription;

  // ==========================================================================
  // PERMISSION HANDLING (using permission_handler)
  // ==========================================================================

  /// Check current location permission status without requesting
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    // First check if location services are enabled on device
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Check permission status using PermissionService
    final status = await PermissionService.instance.getLocationStatus();

    if (status.isGranted) {
      return LocationPermissionStatus.granted;
    } else if (status.isDenied) {
      return LocationPermissionStatus.denied;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    } else if (status.isRestricted) {
      return LocationPermissionStatus.restricted;
    } else if (status.isLimited) {
      return LocationPermissionStatus.limited;
    }

    return LocationPermissionStatus.denied;
  }

  /// Request location permission from the user
  /// Returns the resulting permission status
  Future<LocationPermissionStatus> requestLocationPermission() async {
    // First check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Check current status first
    var status = await PermissionService.instance.getLocationStatus();

    // If already granted, return immediately
    if (status.isGranted) {
      return LocationPermissionStatus.granted;
    }

    // If permanently denied, can't request - must go to settings
    if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    }

    // Request permission
    status = await PermissionService.instance.requestLocationPermission();

    if (status.isGranted) {
      return LocationPermissionStatus.granted;
    } else if (status.isDenied) {
      return LocationPermissionStatus.denied;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    } else if (status.isRestricted) {
      return LocationPermissionStatus.restricted;
    } else if (status.isLimited) {
      return LocationPermissionStatus.limited;
    }

    return LocationPermissionStatus.denied;
  }

  /// Open device location settings (when services are disabled)
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (when permission is permanently denied)
  Future<bool> openAppSettings() async {
    return await PermissionService.instance.openSettings();
  }

  // ==========================================================================
  // LOCATION FETCHING
  // ==========================================================================

  /// Get current location coordinates
  /// Automatically requests permission if not granted
  Future<LocationResult> getCurrentLocation({
    bool highAccuracy = true,
    Duration? timeout,
  }) async {
    try {
      // Check/request permission
      final permissionStatus = await requestLocationPermission();
      if (permissionStatus != LocationPermissionStatus.granted &&
          permissionStatus != LocationPermissionStatus.limited) {
        return LocationResult.permissionError(permissionStatus);
      }

      // Get position using geolocator
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: highAccuracy
              ? LocationAccuracy.high
              : LocationAccuracy.medium,
          timeLimit: timeout ?? const Duration(seconds: 15),
        ),
      );

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      return LocationResult.error('Failed to get location: $e');
    }
  }

  /// Get last known location (faster, may be stale)
  Future<LocationResult> getLastKnownLocation() async {
    try {
      final permissionStatus = await checkPermissionStatus();
      if (permissionStatus != LocationPermissionStatus.granted &&
          permissionStatus != LocationPermissionStatus.limited) {
        return LocationResult.permissionError(permissionStatus);
      }

      final position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return LocationResult.error('No last known location available');
      }

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      return LocationResult.error('Failed to get last known location: $e');
    }
  }

  /// Start listening to location updates
  Stream<Position> getLocationStream({
    bool highAccuracy = true,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: highAccuracy
            ? LocationAccuracy.high
            : LocationAccuracy.medium,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Stop listening to location updates
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // ==========================================================================
  // GEOCODING
  // ==========================================================================

  /// Get address from coordinates (reverse geocoding)
  Future<AddressResult> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return AddressResult.error('No address found for coordinates');
      }

      final place = placemarks.first;

      return AddressResult.success(
        streetLine1: _buildStreetLine(place),
        streetLine2: place.subLocality,
        city: place.locality ?? place.subAdministrativeArea ?? '',
        state: place.administrativeArea ?? '',
        postalCode: place.postalCode ?? '',
        country: place.country ?? '',
        countryCode: place.isoCountryCode ?? '',
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error reverse geocoding: $e');
      }
      return AddressResult.error('Failed to get address: $e');
    }
  }

  /// Get coordinates from address string (forward geocoding)
  Future<LocationResult> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        return LocationResult.error('No coordinates found for address');
      }

      final location = locations.first;
      return LocationResult.success(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error forward geocoding: $e');
      }
      return LocationResult.error('Failed to geocode address: $e');
    }
  }

  /// Get current location with address (combined operation)
  Future<AddressResult> getCurrentLocationWithAddress({
    bool highAccuracy = true,
  }) async {
    final locationResult = await getCurrentLocation(highAccuracy: highAccuracy);

    if (!locationResult.isSuccess) {
      return AddressResult.error(
        locationResult.errorMessage ?? 'Failed to get location',
      );
    }

    return await getAddressFromCoordinates(
      latitude: locationResult.latitude!,
      longitude: locationResult.longitude!,
    );
  }

  // ==========================================================================
  // DISTANCE CALCULATIONS
  // ==========================================================================

  /// Calculate distance between two points in meters
  double calculateDistanceMeters({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate distance in miles
  double calculateDistanceMiles({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final meters = calculateDistanceMeters(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );
    return meters / 1609.344; // Convert meters to miles
  }

  /// Calculate distance in kilometers
  double calculateDistanceKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final meters = calculateDistanceMeters(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );
    return meters / 1000;
  }

  /// Calculate bearing between two points
  double calculateBearing({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  String _buildStreetLine(Placemark place) {
    final parts = <String>[];

    if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
      parts.add(place.subThoroughfare!);
    }
    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      parts.add(place.thoroughfare!);
    }

    return parts.join(' ');
  }
}

// =============================================================================
// DATA CLASSES
// =============================================================================

/// Status of location permission
enum LocationPermissionStatus {
  /// Permission has been granted
  granted,

  /// Permission has been denied (can be requested again)
  denied,

  /// Permission has been permanently denied (must go to settings)
  permanentlyDenied,

  /// Location services are disabled on the device
  serviceDisabled,

  /// Permission is restricted (e.g., parental controls) - iOS only
  restricted,

  /// Limited permission (approximate location) - iOS 14+ only
  limited,
}

extension LocationPermissionStatusX on LocationPermissionStatus {
  /// Whether the permission allows location access
  bool get allowsLocationAccess =>
      this == LocationPermissionStatus.granted ||
      this == LocationPermissionStatus.limited;

  /// Human-readable description
  String get description {
    switch (this) {
      case LocationPermissionStatus.granted:
        return 'Location access granted';
      case LocationPermissionStatus.denied:
        return 'Location permission denied';
      case LocationPermissionStatus.permanentlyDenied:
        return 'Location permission permanently denied. Please enable in Settings.';
      case LocationPermissionStatus.serviceDisabled:
        return 'Location services are disabled. Please enable in Settings.';
      case LocationPermissionStatus.restricted:
        return 'Location access is restricted';
      case LocationPermissionStatus.limited:
        return 'Limited location access (approximate)';
    }
  }
}

/// Result of location fetch operation
class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime? timestamp;
  final String? errorMessage;
  final LocationPermissionStatus? permissionStatus;

  LocationResult._({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.timestamp,
    this.errorMessage,
    this.permissionStatus,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationResult._(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );
  }

  factory LocationResult.error(String message) {
    return LocationResult._(isSuccess: false, errorMessage: message);
  }

  factory LocationResult.permissionError(LocationPermissionStatus status) {
    return LocationResult._(
      isSuccess: false,
      errorMessage: status.description,
      permissionStatus: status,
    );
  }

  /// Whether this is a permission error
  bool get isPermissionError => permissionStatus != null;
}

/// Result of address lookup operation
class AddressResult {
  final bool isSuccess;
  final String? streetLine1;
  final String? streetLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  AddressResult._({
    required this.isSuccess,
    this.streetLine1,
    this.streetLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.errorMessage,
  });

  factory AddressResult.success({
    required String streetLine1,
    String? streetLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    String? countryCode,
    required double latitude,
    required double longitude,
  }) {
    return AddressResult._(
      isSuccess: true,
      streetLine1: streetLine1,
      streetLine2: streetLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory AddressResult.error(String message) {
    return AddressResult._(isSuccess: false, errorMessage: message);
  }

  /// Full formatted address
  String get formattedAddress {
    if (!isSuccess) return '';

    final parts = <String>[];
    if (streetLine1 != null && streetLine1!.isNotEmpty) {
      parts.add(streetLine1!);
    }
    if (streetLine2 != null && streetLine2!.isNotEmpty) {
      parts.add(streetLine2!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }

    return parts.join(', ');
  }

  /// Short formatted address (street, city)
  String get shortAddress {
    if (!isSuccess) return '';

    final parts = <String>[];
    if (streetLine1 != null && streetLine1!.isNotEmpty) {
      parts.add(streetLine1!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }

    return parts.join(', ');
  }
}
