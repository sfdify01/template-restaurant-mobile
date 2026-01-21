import 'package:dart_mappable/dart_mappable.dart';
import 'enums.dart';

part 'menu_item.mapper.dart';

/// Menu item / Product model matching Supabase menu_items table
@MappableClass(caseStyle: CaseStyle.snakeCase)
class MenuItem with MenuItemMappable {
  final String id;
  final String tenantId;
  final String? externalId;
  final String name;
  final String? category;
  final String? description;
  final String? imageUrl;
  final int priceCents;
  final PriceUnit priceUnit;
  final List<String> dietaryTags;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuItem({
    required this.id,
    required this.tenantId,
    this.externalId,
    required this.name,
    this.category,
    this.description,
    this.imageUrl,
    required this.priceCents,
    this.priceUnit = PriceUnit.each,
    this.dietaryTags = const [],
    this.isActive = true,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Price in dollars
  double get priceInDollars => priceCents / 100.0;

  /// Formatted price string (e.g., "$12.99/lb")
  String get formattedPrice {
    final price = '\$${priceInDollars.toStringAsFixed(2)}';
    return '$price${priceUnit.priceSuffix}';
  }

  /// Whether this is a weight-based product
  bool get isWeightBased => priceUnit.isWeight;

  /// Get dietary tags as comma-separated string
  String get dietaryTagsDisplay => dietaryTags.join(', ');
}
