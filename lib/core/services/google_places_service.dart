import 'package:dio/dio.dart';

import '../config/env_config.dart';

/// Place prediction from Google Places Autocomplete
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>?;
    return PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      mainText: structuredFormatting?['main_text'] as String? ?? '',
      secondaryText: structuredFormatting?['secondary_text'] as String? ?? '',
    );
  }
}

/// Address component from Google Places
class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  const AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'] as String,
      shortName: json['short_name'] as String,
      types: List<String>.from(json['types'] as List),
    );
  }
}

/// Place details from Google Places
class PlaceDetails {
  final String placeId;
  final String formattedAddress;
  final List<AddressComponent> addressComponents;
  final double? lat;
  final double? lng;

  const PlaceDetails({
    required this.placeId,
    required this.formattedAddress,
    required this.addressComponents,
    this.lat,
    this.lng,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    return PlaceDetails(
      placeId: json['place_id'] as String,
      formattedAddress: json['formatted_address'] as String,
      addressComponents: (json['address_components'] as List)
          .map((c) => AddressComponent.fromJson(c as Map<String, dynamic>))
          .toList(),
      lat: location?['lat'] as double?,
      lng: location?['lng'] as double?,
    );
  }
}

/// Service for Google Places API interactions
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _geocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode';

  final Dio _dio;

  GooglePlacesService() : _dio = Dio();

  String get _apiKey => EnvConfig.googleMapsApiKey;

  /// Get autocomplete predictions for a search query
  Future<List<PlacePrediction>> getAutocompletePredictions(
    String input, {
    String? components,
    String? types,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': _apiKey,
          if (components != null) 'components': components,
          if (types != null) 'types': types,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String;

        if (status == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
              .toList();
        } else if (status == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Places API error: $status');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvConfig.enableLogging) {
        print('GooglePlacesService.getAutocompletePredictions error: $e');
      }
      rethrow;
    }
  }

  /// Get place details by place ID
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
          'fields': 'place_id,formatted_address,address_components,geometry',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String;

        if (status == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          return PlaceDetails.fromJson(result);
        } else {
          throw Exception('Place details API error: $status');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvConfig.enableLogging) {
        print('GooglePlacesService.getPlaceDetails error: $e');
      }
      rethrow;
    }
  }

  /// Reverse geocode coordinates to address
  Future<PlaceDetails?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_geocodeUrl/json',
        queryParameters: {'latlng': '$lat,$lng', 'key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String;

        if (status == 'OK') {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final result = results.first as Map<String, dynamic>;
            return PlaceDetails.fromJson(result);
          }
        }
        return null;
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvConfig.enableLogging) {
        print('GooglePlacesService.reverseGeocode error: $e');
      }
      rethrow;
    }
  }
}
