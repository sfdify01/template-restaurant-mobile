import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:place_pickarte/place_pickarte.dart';

import '../../core/config/env_config.dart';
import '../../core/providers/location_provider.dart' hide Location;
import '../../core/services/location_service.dart';
import '../../core/theme/app_theme.dart';

/// Callback when a location is selected
typedef OnLocationSelected =
    void Function(LatLng position, AddressResult? address);

/// A reusable map picker widget using place_pickarte for beautiful map picking.
class MapLocationPicker extends ConsumerStatefulWidget {
  /// Initial position to show
  final LatLng? initialPosition;

  /// Callback when location is selected
  final OnLocationSelected? onLocationSelected;

  /// Confirm button text
  final String confirmButtonText;

  /// Whether to auto-fetch address when location changes
  final bool autoFetchAddress;

  /// Map height
  final double height;

  const MapLocationPicker({
    super.key,
    this.initialPosition,
    this.onLocationSelected,
    this.confirmButtonText = 'Confirm Location',
    this.autoFetchAddress = true,
    this.height = 300,
  });

  @override
  ConsumerState<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends ConsumerState<MapLocationPicker> {
  PlacePickarteController? _controller;
  LatLng? _selectedPosition;
  AddressResult? _selectedAddress;
  bool _isLoadingAddress = false;
  bool _isInitialized = false;
  Timer? _debounceTimer;

  // Default to Shahirizada store location in Naperville, IL
  static const LatLng _defaultPosition = LatLng(41.7508, -88.1535);

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? _defaultPosition;
    _initController();
  }

  void _initController() {
    final apiKey = EnvConfig.googleMapsApiKey;
    if (apiKey.isEmpty) {
      debugPrint('WARNING: Google Maps API key is empty');
    }

    final initialLoc = widget.initialPosition ?? _defaultPosition;

    _controller = PlacePickarteController(
      config: PlacePickarteConfig(
        googleMapConfig: GoogleMapConfig(
          iosApiKey: apiKey,
          androidApiKey: apiKey,
        ),
        initialLocation: Location(
          lat: initialLoc.latitude,
          lng: initialLoc.longitude,
        ),
        // Only try to get user location if no initial position was provided
        myLocationAsInitial: widget.initialPosition == null,
        initialZoom: 16.0,
        googleMapsGeocoding: GoogleMapsGeocoding(apiKey: apiKey),
        placesAutocompleteConfig: PlacesAutocompleteConfig(
          region: 'us',
          components: [Component(Component.country, 'us')],
          language: 'en',
        ),
      ),
    );

    // Listen to location changes from the map
    _controller!.currentLocationStream.listen((result) {
      if (result != null && mounted) {
        final lat = result.geometry.location.lat;
        final lng = result.geometry.location.lng;

        final position = LatLng(lat, lng);
        _onPositionChanged(position, result.formattedAddress);
      }
    });

    // Mark as initialized after a brief delay to let the map render
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  void _onPositionChanged(LatLng position, String? formattedAddress) {
    setState(() {
      _selectedPosition = position;
    });

    // Debounce address fetching
    if (widget.autoFetchAddress) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _fetchAddressForPosition(position);
      });
    }
  }

  Future<void> _fetchAddressForPosition(LatLng position) async {
    if (!mounted) return;

    setState(() => _isLoadingAddress = true);

    final locationNotifier = ref.read(locationProvider.notifier);
    final result = await locationNotifier.getAddressFromCoordinates(position);

    if (mounted) {
      setState(() {
        _selectedAddress = result.isSuccess ? result : null;
        _isLoadingAddress = false;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller?.close();
    super.dispose();
  }

  void _onConfirm() {
    if (_selectedPosition != null) {
      widget.onLocationSelected?.call(_selectedPosition!, _selectedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_controller == null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Loading map...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map container
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                PlacePickarteMap(_controller!),
                // Loading overlay while initializing
                if (!_isInitialized)
                  Container(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading map...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Address display
        if (widget.autoFetchAddress) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: _isLoadingAddress
                ? Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Finding address...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 18,
                        color: _selectedAddress != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAddress?.formattedAddress ??
                              'Move map to select location',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _selectedAddress != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],

        // Confirm button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selectedPosition != null && !_isLoadingAddress
                ? _onConfirm
                : null,
            icon: const Icon(LucideIcons.check),
            label: Text(widget.confirmButtonText),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-screen map picker screen with search, my location, and beautiful UI
class MapLocationPickerScreen extends ConsumerStatefulWidget {
  final LatLng? initialPosition;
  final String title;

  const MapLocationPickerScreen({
    super.key,
    this.initialPosition,
    this.title = 'Select Location',
  });

  @override
  ConsumerState<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState
    extends ConsumerState<MapLocationPickerScreen> {
  PlacePickarteController? _controller;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  LatLng? _selectedPosition;
  AddressResult? _selectedAddress;
  String? _displayAddress;
  bool _isLoadingAddress = false;
  bool _isLoadingMyLocation = false;
  bool _showSearchResults = false;
  List<Prediction> _predictions = [];
  Timer? _debounceTimer;

  // Default to Shahirizada store location
  static const LatLng _defaultPosition = LatLng(41.7508, -88.1535);

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? _defaultPosition;
    _initController();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() => _showSearchResults = false);
      }
    });
  }

  void _initController() {
    final apiKey = EnvConfig.googleMapsApiKey;
    final initialLoc = widget.initialPosition ?? _defaultPosition;

    _controller = PlacePickarteController(
      config: PlacePickarteConfig(
        googleMapConfig: GoogleMapConfig(
          iosApiKey: apiKey,
          androidApiKey: apiKey,
        ),
        initialLocation: Location(
          lat: initialLoc.latitude,
          lng: initialLoc.longitude,
        ),
        myLocationAsInitial: widget.initialPosition == null,
        initialZoom: 16.0,
        googleMapsGeocoding: GoogleMapsGeocoding(apiKey: apiKey),
        placesAutocompleteConfig: PlacesAutocompleteConfig(
          region: 'us',
          components: [Component(Component.country, 'us')],
          language: 'en',
        ),
        pinBuilder: (context, state) => _buildPin(context, state),
      ),
    );

    // Listen to location changes
    _controller!.currentLocationStream.listen((result) {
      if (result != null && mounted) {
        final lat = result.geometry.location.lat;
        final lng = result.geometry.location.lng;

        setState(() {
          _selectedPosition = LatLng(lat, lng);
          _displayAddress = result.formattedAddress;
        });
        _fetchAddressDetails(LatLng(lat, lng));
      }
    });

    // Listen to autocomplete results
    _controller!.autocompleteResultsStream.listen((predictions) {
      if (mounted) {
        setState(() {
          _predictions = predictions ?? [];
          _showSearchResults = _predictions.isNotEmpty;
        });
      }
    });
  }

  Widget _buildPin(BuildContext context, PinState state) {
    final isDragging = state == PinState.dragging;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(0, isDragging ? -12 : 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDragging
                  ? AppTheme.primaryColor.withOpacity(0.8)
                  : AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDragging ? 0.3 : 0.2),
                  blurRadius: isDragging ? 12 : 8,
                  offset: Offset(0, isDragging ? 8 : 4),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.mapPin,
              color: Colors.white,
              size: isDragging ? 28 : 24,
            ),
          ),
          // Pin pointer
          CustomPaint(
            size: const Size(12, 8),
            painter: _PinPointerPainter(
              color: isDragging
                  ? AppTheme.primaryColor.withOpacity(0.8)
                  : AppTheme.primaryColor,
            ),
          ),
          // Shadow dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isDragging ? 8 : 6,
            height: isDragging ? 4 : 3,
            margin: EdgeInsets.only(top: isDragging ? 4 : 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(isDragging ? 0.2 : 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAddressDetails(LatLng position) async {
    if (!mounted) return;

    setState(() => _isLoadingAddress = true);

    final locationNotifier = ref.read(locationProvider.notifier);
    final result = await locationNotifier.getAddressFromCoordinates(position);

    if (mounted) {
      setState(() {
        _selectedAddress = result.isSuccess ? result : null;
        _isLoadingAddress = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _showSearchResults = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _controller?.searchAutocomplete(query);
    });
  }

  void _selectPrediction(Prediction prediction) {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _predictions = [];
      _showSearchResults = false;
    });
    _controller?.selectAutocompleteItem(prediction);
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLoadingMyLocation = true);

    try {
      final result = await _controller?.goToMyLocation();

      if (result == MyLocationResult.permissionDenied) {
        if (mounted) {
          _showLocationPermissionDialog(
            title: 'Location Permission Required',
            message:
                'Please enable location permission to use your current location.',
            onOpenSettings: () => LocationService.instance.openAppSettings(),
          );
        }
      } else if (result == MyLocationResult.serviceNotEnabled) {
        if (mounted) {
          _showLocationPermissionDialog(
            title: 'Location Services Disabled',
            message: 'Please enable location services on your device.',
            onOpenSettings: () =>
                LocationService.instance.openLocationSettings(),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMyLocation = false);
      }
    }
  }

  void _showLocationPermissionDialog({
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

  void _onConfirm() {
    if (_selectedPosition != null) {
      Navigator.pop(context, {
        'position': _selectedPosition,
        'address': _selectedAddress,
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          if (_controller != null)
            Positioned.fill(child: PlacePickarteMap(_controller!))
          else
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),

          // Top bar with search
          Positioned(
            top: mediaQuery.padding.top + 8,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search bar row
                Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          LucideIcons.arrowLeft,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search address...',
                            prefixIcon: Icon(
                              LucideIcons.search,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      LucideIcons.x,
                                      size: 18,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _predictions = [];
                                        _showSearchResults = false;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Search results dropdown
                if (_showSearchResults && _predictions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            LucideIcons.mapPin,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            prediction.structuredFormatting?.mainText ??
                                prediction.description ??
                                '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            prediction.structuredFormatting?.secondaryText ??
                                '',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectPrediction(prediction),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // My location button
          Positioned(
            right: 16,
            bottom: mediaQuery.padding.bottom + 200,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isLoadingMyLocation ? null : _goToMyLocation,
                icon: _isLoadingMyLocation
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(
                        LucideIcons.locateFixed,
                        color: theme.colorScheme.primary,
                      ),
              ),
            ),
          ),

          // Bottom sheet with address and confirm button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                mediaQuery.padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.mapPin,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Location',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_isLoadingAddress)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Finding address...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                _displayAddress ??
                                    _selectedAddress?.formattedAddress ??
                                    'Move the map to select a location',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selectedPosition != null && !_isLoadingAddress
                          ? _onConfirm
                          : null,
                      icon: const Icon(LucideIcons.check),
                      label: const Text('Confirm Location'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the pin pointer triangle
class _PinPointerPainter extends CustomPainter {
  final Color color;

  _PinPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
