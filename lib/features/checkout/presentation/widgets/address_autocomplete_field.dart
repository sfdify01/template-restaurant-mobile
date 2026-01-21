import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../shared/widgets/map_location_picker.dart';

/// Parsed address components from Google Places
class ParsedAddress {
  final String streetNumber;
  final String streetName;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String formattedAddress;

  const ParsedAddress({
    this.streetNumber = '',
    this.streetName = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.country = '',
    this.formattedAddress = '',
  });

  String get streetLine1 {
    if (streetNumber.isNotEmpty && streetName.isNotEmpty) {
      return '$streetNumber $streetName';
    }
    return streetName;
  }

  bool get isValid =>
      streetName.isNotEmpty && city.isNotEmpty && state.isNotEmpty;
}

/// Address autocomplete field matching web's ModernAddressPicker
class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<ParsedAddress> onAddressSelected;
  final String? initialValue;
  final String? hintText;
  final String? labelText;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.onAddressSelected,
    this.initialValue,
    this.hintText,
    this.labelText,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final GooglePlacesService _placesService = GooglePlacesService();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  bool _showDropdown = false;
  bool _isGettingLocation = false;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _predictions.isNotEmpty) {
      _showOverlay();
    } else if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    final query = widget.controller.text.trim();

    _debounceTimer?.cancel();

    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _showDropdown = false;
      });
      _removeOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() => _isLoading = true);

    try {
      final predictions = await _placesService.getAutocompletePredictions(
        query,
        // Bias to US addresses
        components: 'country:us',
      );

      if (mounted) {
        setState(() {
          _predictions = predictions;
          _showDropdown = predictions.isNotEmpty;
          _isLoading = false;
        });

        if (_showDropdown && _focusNode.hasFocus) {
          _showOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _predictions = [];
        });
      }
    }
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    _removeOverlay();
    setState(() {
      _isLoading = true;
      _showDropdown = false;
    });

    try {
      final details = await _placesService.getPlaceDetails(prediction.placeId);

      if (details != null && mounted) {
        final parsed = _parseAddressComponents(details);
        widget.controller.text = parsed.formattedAddress;
        widget.onAddressSelected(parsed);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to get address details. Please try again.',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  ParsedAddress _parseAddressComponents(PlaceDetails details) {
    String streetNumber = '';
    String streetName = '';
    String city = '';
    String state = '';
    String postalCode = '';
    String country = '';

    for (final component in details.addressComponents) {
      final types = component.types;
      final value = component.longName;

      if (types.contains('street_number')) {
        streetNumber = value;
      } else if (types.contains('route')) {
        streetName = value;
      } else if (types.contains('locality')) {
        city = value;
      } else if (types.contains('administrative_area_level_1')) {
        state = component.shortName;
      } else if (types.contains('postal_code')) {
        postalCode = value;
      } else if (types.contains('country')) {
        country = component.shortName;
      }
    }

    return ParsedAddress(
      streetNumber: streetNumber,
      streetName: streetName,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      formattedAddress: details.formattedAddress,
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      final locationService = LocationService.instance;

      // Check/request location permission using proper permission_handler flow
      final permissionStatus = await locationService
          .requestLocationPermission();

      if (!permissionStatus.allowsLocationAccess) {
        if (permissionStatus == LocationPermissionStatus.permanentlyDenied) {
          // Show dialog to open app settings
          if (mounted) {
            _showPermissionDeniedDialog();
          }
          return;
        } else if (permissionStatus ==
            LocationPermissionStatus.serviceDisabled) {
          // Show dialog to open location settings
          if (mounted) {
            _showLocationServicesDisabledDialog();
          }
          return;
        }
        throw Exception(permissionStatus.description);
      }

      // Get current position
      final result = await locationService.getCurrentLocation(
        highAccuracy: true,
      );

      if (!result.isSuccess) {
        throw Exception(result.errorMessage ?? 'Failed to get location');
      }

      // Reverse geocode to get address using Google Places API
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
        final parsed = _parseAddressComponents(address);
        widget.controller.text = parsed.formattedAddress;
        widget.onAddressSelected(parsed);
      } else if (mounted) {
        // Fallback: Use native geocoding library
        debugPrint('Falling back to native geocoding...');
        final fallbackAddress = await locationService.getAddressFromCoordinates(
          latitude: result.latitude!,
          longitude: result.longitude!,
        );

        if (fallbackAddress.isSuccess && mounted) {
          // Convert AddressResult to ParsedAddress
          final parsed = ParsedAddress(
            streetNumber: '',
            streetName: fallbackAddress.streetLine1 ?? '',
            city: fallbackAddress.city ?? '',
            state: fallbackAddress.state ?? '',
            postalCode: fallbackAddress.postalCode ?? '',
            country: fallbackAddress.countryCode ?? '',
            formattedAddress: fallbackAddress.formattedAddress,
          );
          widget.controller.text = parsed.formattedAddress;
          widget.onAddressSelected(parsed);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Could not determine address from your location. Please enter it manually.',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Current location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not get current location. Please check your settings and try again.',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. '
          'Please enable it in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService.instance.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationServicesDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled on your device. '
          'Please enable them to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService.instance.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker() async {
    // Get initial position for the map
    LatLng? initialPosition;

    // Try to get user's current location
    try {
      final locationService = LocationService.instance;
      final currentLocation = await locationService.getCurrentLocation();
      if (currentLocation.isSuccess) {
        initialPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      }
    } catch (e) {
      // Fallback: MapLocationPicker will use myLocationAsInitial or default
      debugPrint('Could not get current location for map: $e');
    }

    if (!mounted) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          initialPosition: initialPosition,
          title: 'Select Delivery Address',
        ),
      ),
    );

    if (result != null && mounted) {
      final position = result['position'] as LatLng;
      final address = result['address'] as AddressResult?;

      if (address != null && address.isSuccess) {
        // Convert AddressResult to ParsedAddress
        final parsed = ParsedAddress(
          streetNumber: '', // AddressResult doesn't separate these
          streetName: address.streetLine1 ?? '',
          city: address.city ?? '',
          state: address.state ?? '',
          postalCode: address.postalCode ?? '',
          country: address.countryCode ?? '',
          formattedAddress: address.formattedAddress,
        );

        widget.controller.text = parsed.formattedAddress;
        widget.onAddressSelected(parsed);
      } else {
        // If no address, try to reverse geocode
        final addressResult = await _placesService.reverseGeocode(
          position.latitude,
          position.longitude,
        );

        if (addressResult != null && mounted) {
          final parsed = _parseAddressComponents(addressResult);
          widget.controller.text = parsed.formattedAddress;
          widget.onAddressSelected(parsed);
        }
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.findRenderObject() != null
            ? (context.findRenderObject() as RenderBox).size.width
            : 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _predictions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: AppTheme.primaryColor,
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () => _selectPrediction(prediction),
                  );
                },
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address input with autocomplete
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: widget.labelText ?? 'Street Address',
              hintText: widget.hintText ?? 'Start typing your address...',
              prefixIcon: Icon(LucideIcons.search, size: 20),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, size: 18),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {
                          _predictions = [];
                          _showDropdown = false;
                        });
                        _removeOverlay();
                      },
                    )
                  : null,
            ),
            validator: (value) {
              return AppValidators.required(
                message: 'Please enter your address',
              )(value);
            },
          ),
        ),

        const SizedBox(height: 8),

        // Location action buttons
        Row(
          children: [
            // Use current location button
            Expanded(
              child: TextButton.icon(
                onPressed: _isGettingLocation ? null : _useCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(LucideIcons.locateFixed, size: 16),
                label: Text(
                  _isGettingLocation ? 'Getting...' : 'Use Current Location',
                  overflow: TextOverflow.ellipsis,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Pick on map button
            Expanded(
              child: TextButton.icon(
                onPressed: _openMapPicker,
                icon: Icon(LucideIcons.map, size: 16),
                label: const Text(
                  'Pick on Map',
                  overflow: TextOverflow.ellipsis,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
