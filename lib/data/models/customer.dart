import 'package:dart_mappable/dart_mappable.dart';
import 'enums.dart';

part 'customer.mapper.dart';

/// Customer model matching Supabase customers table
@MappableClass(caseStyle: CaseStyle.snakeCase)
class Customer with CustomerMappable {
  final String id;
  final String tenantId;
  final String? authUserId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final bool marketingOptIn;
  final FulfillmentType? defaultFulfillmentType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.tenantId,
    this.authUserId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.marketingOptIn = false,
    this.defaultFulfillmentType,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full name display
  String get fullName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : 'Guest';
  }

  /// Initials for avatar
  String get initials {
    final f = firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final l = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    return f + l;
  }
}
