import 'package:dart_mappable/dart_mappable.dart';

part 'address.mapper.dart';

/// Address model matching Supabase addresses table
@MappableClass(caseStyle: CaseStyle.snakeCase)
class Address with AddressMappable {
  final String id;
  final String tenantId;
  final String? customerId;
  final String? label;
  final String streetLine1;
  final String? streetLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? deliveryInstructions;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.id,
    required this.tenantId,
    this.customerId,
    this.label,
    required this.streetLine1,
    this.streetLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'US',
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Single line address display
  String get singleLine {
    final parts = [
      streetLine1,
      if (streetLine2 != null && streetLine2!.isNotEmpty) streetLine2,
      city,
      state,
      postalCode,
    ];
    return parts.join(', ');
  }

  /// Multi-line address display
  String get multiLine {
    final lines = [
      streetLine1,
      if (streetLine2 != null && streetLine2!.isNotEmpty) streetLine2,
      '$city, $state $postalCode',
    ];
    return lines.join('\n');
  }

  /// Short display (street only)
  String get shortDisplay => streetLine1;

  /// Has valid coordinates
  bool get hasCoordinates => latitude != null && longitude != null;
}
