import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/services/google_places_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../shared/widgets/map_location_picker.dart';

/// Completed delivery address from the picker
class DeliveryAddress {
  final String streetLine1;
  final String? streetLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? deliveryInstructions;
  final double? latitude;
  final double? longitude;

  const DeliveryAddress({
    required this.streetLine1,
    this.streetLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'US',
    this.deliveryInstructions,
    this.latitude,
    this.longitude,
  });

  bool get isValid =>
      streetLine1.isNotEmpty &&
      city.isNotEmpty &&
      state.isNotEmpty &&
      postalCode.isNotEmpty;

  String get formattedAddress {
    final parts = <String>[streetLine1];
    if (streetLine2 != null && streetLine2!.isNotEmpty) {
      parts.add(streetLine2!);
    }
    parts.add('$city, $state $postalCode');
    return parts.join(', ');
  }

  String get shortAddress => '$streetLine1, $city';
}

/// Modern address picker matching the web's ModernAddressPicker component.
/// Clean, beautiful UX with Google Places autocomplete + GPS location.
class ModernAddressPicker extends ConsumerStatefulWidget {
  /// Called when a valid address is selected/confirmed
  final ValueChanged<DeliveryAddress> onAddressChanged;

  /// Initial address to populate (for editing)
  final DeliveryAddress? initialAddress;

  /// Whether to show delivery instructions field
  final bool showDeliveryInstructions;

  const ModernAddressPicker({
    super.key,
    required this.onAddressChanged,
    this.initialAddress,
    this.showDeliveryInstructions = true,
  });

  @override
  ConsumerState<ModernAddressPicker> createState() =>
      _ModernAddressPickerState();
}

class _ModernAddressPickerState extends ConsumerState<ModernAddressPicker> {
  final GooglePlacesService _placesService = GooglePlacesService();
  final _searchController = TextEditingController();
  final _aptController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _layerLink = LayerLink();

  List<PlacePrediction> _predictions = [];
  bool _isSearching = false;
  bool _isGettingLocation = false;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;

  // Confirmed address state
  String? _confirmedStreet;
  String? _confirmedCity;
  String? _confirmedState;
  String? _confirmedZip;
  double? _confirmedLat;
  double? _confirmedLng;

  bool get _hasConfirmedAddress =>
      _confirmedStreet != null &&
      _confirmedCity != null &&
      _confirmedState != null &&
      _confirmedZip != null;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChanged);

    // Initialize from existing address if provided
    if (widget.initialAddress != null) {
      _confirmedStreet = widget.initialAddress!.streetLine1;
      _confirmedCity = widget.initialAddress!.city;
      _confirmedState = widget.initialAddress!.state;
      _confirmedZip = widget.initialAddress!.postalCode;
      _confirmedLat = widget.initialAddress!.latitude;
      _confirmedLng = widget.initialAddress!.longitude;
      _searchController.text = widget.initialAddress!.shortAddress;
      if (widget.initialAddress!.streetLine2 != null) {
        _aptController.text = widget.initialAddress!.streetLine2!;
      }
      if (widget.initialAddress!.deliveryInstructions != null) {
        _instructionsController.text =
            widget.initialAddress!.deliveryInstructions!;
      }
    }

    // Listen for changes to emit updated address
    _aptController.addListener(_emitAddressChange);
    _instructionsController.addListener(_emitAddressChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _aptController.dispose();
    _instructionsController.dispose();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _predictions.isNotEmpty) {
      _showOverlay();
    } else if (!_searchFocusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < 3) {
      setState(() {
        _predictions = [];
      });
      _removeOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() => _isSearching = true);

    try {
      final predictions = await _placesService.getAutocompletePredictions(
        query,
        components: 'country:us',
      );

      if (mounted) {
        setState(() {
          _predictions = predictions;
          _isSearching = false;
        });

        if (_predictions.isNotEmpty && _searchFocusNode.hasFocus) {
          _showOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _predictions = [];
        });
      }
    }
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    _removeOverlay();
    _searchFocusNode.unfocus();
    setState(() => _isSearching = true);

    try {
      final details = await _placesService.getPlaceDetails(prediction.placeId);

      if (details != null && mounted) {
        _parseAndConfirmAddress(details);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to get address details');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _parseAndConfirmAddress(PlaceDetails details) {
    String streetNumber = '';
    String streetName = '';
    String city = '';
    String state = '';
    String postalCode = '';

    for (final component in details.addressComponents) {
      final types = component.types;
      final value = component.longName;

      if (types.contains('street_number')) {
        streetNumber = value;
      } else if (types.contains('route')) {
        streetName = value;
      } else if (types.contains('locality')) {
        city = value;
      } else if (types.contains('sublocality_level_1') && city.isEmpty) {
        city = value;
      } else if (types.contains('administrative_area_level_1')) {
        state = component.shortName;
      } else if (types.contains('postal_code')) {
        postalCode = value;
      }
    }

    final streetLine1 = streetNumber.isNotEmpty
        ? '$streetNumber $streetName'
        : streetName;

    setState(() {
      _confirmedStreet = streetLine1;
      _confirmedCity = city;
      _confirmedState = state;
      _confirmedZip = postalCode;
      _confirmedLat = details.lat;
      _confirmedLng = details.lng;
      _searchController.text = '$streetLine1, $city';
      _predictions = [];
    });

    _emitAddressChange();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      final locationService = LocationService.instance;

      // Request permission - this will show the system dialog if not already granted
      final permissionStatus = await locationService
          .requestLocationPermission();

      if (!permissionStatus.allowsLocationAccess) {
        if (permissionStatus == LocationPermissionStatus.permanentlyDenied) {
          _showPermissionDialog(
            title: 'Location Permission Required',
            message:
                'Please enable location permission in settings to use your current location.',
            onOpenSettings: () => locationService.openAppSettings(),
          );
        } else if (permissionStatus ==
            LocationPermissionStatus.serviceDisabled) {
          _showPermissionDialog(
            title: 'Location Services Disabled',
            message: 'Please enable location services on your device.',
            onOpenSettings: () => locationService.openLocationSettings(),
          );
        } else if (permissionStatus == LocationPermissionStatus.denied) {
          // User denied the permission request - just show a snackbar
          _showError(
            'Location permission is required to use your current location',
          );
        }
        return;
      }

      // Get current position
      final result = await locationService.getCurrentLocation(
        highAccuracy: true,
      );

      if (!result.isSuccess) {
        _showError(
          UserErrorMessage.from(
            result.errorMessage,
            fallback: 'Failed to get location',
          ),
        );
        return;
      }

      // Reverse geocode using Google Places API for accurate address parsing
      PlaceDetails? address;
      try {
        address = await _placesService.reverseGeocode(
          result.latitude!,
          result.longitude!,
        );
      } catch (e) {
        debugPrint('Google Places reverse geocode failed: $e');
        // Will fall through to fallback below
      }

      if (address != null && mounted) {
        _parseAndConfirmAddress(address);
      } else if (mounted) {
        // Fallback: Use native geocoding library
        debugPrint('Falling back to native geocoding...');
        final fallbackAddress = await locationService.getAddressFromCoordinates(
          latitude: result.latitude!,
          longitude: result.longitude!,
        );

        if (fallbackAddress.isSuccess && mounted) {
          // Convert AddressResult to confirmed address fields
          setState(() {
            _confirmedStreet = fallbackAddress.streetLine1 ?? '';
            _confirmedCity = fallbackAddress.city ?? '';
            _confirmedState = fallbackAddress.state ?? '';
            _confirmedZip = fallbackAddress.postalCode ?? '';
            _confirmedLat = result.latitude;
            _confirmedLng = result.longitude;
            _searchController.text = fallbackAddress.shortAddress;
            _predictions = [];
          });
          _emitAddressChange();
        } else if (mounted) {
          _showError(
            'Could not determine address from your location. Please enter it manually.',
          );
        }
      }
    } catch (e) {
      debugPrint('Current location error: $e');
      if (mounted) {
        _showError(
          'Could not get current location. Please check your settings and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _openMapPicker() async {
    // Only use already-confirmed coordinates if available
    // Do NOT block on getting current location - let the map picker handle that
    // place_pickarte with myLocationAsInitial: true will get location in background
    LatLng? initialPosition;
    if (_confirmedLat != null && _confirmedLng != null) {
      initialPosition = LatLng(_confirmedLat!, _confirmedLng!);
    }

    if (!mounted) return;

    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => MapLocationPickerScreen(
            initialPosition: initialPosition,
            title: 'Select Delivery Location',
          ),
        ),
      );

      if (result != null && mounted) {
        final position = result['position'] as LatLng;
        final address = result['address'] as AddressResult?;

        if (address != null && address.isSuccess) {
          setState(() {
            _confirmedStreet = address.streetLine1 ?? '';
            _confirmedCity = address.city ?? '';
            _confirmedState = address.state ?? '';
            _confirmedZip = address.postalCode ?? '';
            _confirmedLat = position.latitude;
            _confirmedLng = position.longitude;
            _searchController.text = '${_confirmedStreet}, ${_confirmedCity}';
          });
          _emitAddressChange();
        } else {
          // Try reverse geocode with Places API
          final details = await _placesService.reverseGeocode(
            position.latitude,
            position.longitude,
          );
          if (details != null && mounted) {
            _parseAndConfirmAddress(details);
          }
        }
      }
    } catch (e) {
      debugPrint('Error opening map picker: $e');
      if (mounted) {
        _showError('Could not open map. Please try again.');
      }
    }
  }

  void _clearAddress() {
    setState(() {
      _confirmedStreet = null;
      _confirmedCity = null;
      _confirmedState = null;
      _confirmedZip = null;
      _confirmedLat = null;
      _confirmedLng = null;
      _searchController.clear();
      _aptController.clear();
      _instructionsController.clear();
      _predictions = [];
    });
  }

  void _emitAddressChange() {
    if (_hasConfirmedAddress) {
      widget.onAddressChanged(
        DeliveryAddress(
          streetLine1: _confirmedStreet!,
          streetLine2: _aptController.text.isNotEmpty
              ? _aptController.text
              : null,
          city: _confirmedCity!,
          state: _confirmedState!,
          postalCode: _confirmedZip!,
          deliveryInstructions: _instructionsController.text.isNotEmpty
              ? _instructionsController.text
              : null,
          latitude: _confirmedLat,
          longitude: _confirmedLng,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showPermissionDialog({
    required String title,
    required String message,
    required VoidCallback onOpenSettings,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOpenSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(300, 56);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Builder(
              builder: (overlayContext) {
                final overlayTheme = Theme.of(overlayContext);
                final isDark = overlayTheme.brightness == Brightness.dark;
                return Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: overlayTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? overlayTheme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            )
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark
                          ? overlayTheme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            )
                          : Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      final prediction = _predictions[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          LucideIcons.mapPin,
                          size: 18,
                          color: overlayTheme.colorScheme.primary,
                        ),
                        title: Text(
                          prediction.mainText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          prediction.secondaryText,
                          style: TextStyle(
                            fontSize: 12,
                            color: overlayTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => _selectPrediction(prediction),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input with autocomplete
        CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Enter your delivery address',
              prefixIcon: Icon(LucideIcons.search, size: 20),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, size: 18),
                      onPressed: _clearAddress,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? theme.colorScheme.outline.withValues(alpha: 0.5)
                      : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : Colors.grey[50],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Quick action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _useCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(LucideIcons.locateFixed, size: 16),
                label: Text(
                  _isGettingLocation ? 'Getting...' : 'Current Location',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openMapPicker,
                icon: Icon(LucideIcons.map, size: 16),
                label: const Text(
                  'Pick on Map',
                  style: TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Confirmed address card (green success state)
        if (_hasConfirmedAddress) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.circleCheckBig,
                    color: Color(0xFF4CAF50),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _confirmedStreet!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_confirmedCity, $_confirmedState $_confirmedZip',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchFocusNode.requestFocus();
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Optional fields (apt, instructions) - shown after address confirmed
          const SizedBox(height: 16),
          TextField(
            controller: _aptController,
            decoration: InputDecoration(
              labelText: 'Apt, Suite, Unit (optional)',
              hintText: 'Apartment number, suite, etc.',
              prefixIcon: Icon(LucideIcons.building, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          if (widget.showDeliveryInstructions) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Delivery Instructions (optional)',
                hintText: 'e.g., Gate code, ring doorbell, leave at door',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Icon(LucideIcons.messageSquare, size: 18),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
