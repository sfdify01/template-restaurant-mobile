import 'package:dart_mappable/dart_mappable.dart';

part 'order_item.mapper.dart';

/// Order item model matching Supabase order_items table
@MappableClass(caseStyle: CaseStyle.snakeCase)
class OrderItem with OrderItemMappable {
  final String id;
  final String orderId;
  final String tenantId;
  final String? menuItemId;
  final String? menuItemKey;
  final String name;
  final String? description;
  final String? imageUrl;
  final int unitPriceCents;
  final double quantity;
  final String unitLabel;
  final int totalPriceCents;
  final List<Map<String, dynamic>> modifiers;
  final Map<String, dynamic>? metadata;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.tenantId,
    this.menuItemId,
    this.menuItemKey,
    required this.name,
    this.description,
    this.imageUrl,
    required this.unitPriceCents,
    required this.quantity,
    this.unitLabel = 'each',
    required this.totalPriceCents,
    this.modifiers = const [],
    this.metadata,
  });

  /// Unit price in dollars
  double get unitPriceInDollars => unitPriceCents / 100.0;

  /// Total price in dollars
  double get totalInDollars => totalPriceCents / 100.0;

  /// Formatted unit price
  String get formattedUnitPrice => '\$${unitPriceInDollars.toStringAsFixed(2)}';

  /// Formatted total price
  String get formattedTotal => '\$${totalInDollars.toStringAsFixed(2)}';

  /// Formatted quantity display
  String get formattedQuantity {
    if (quantity == quantity.truncate()) {
      return '${quantity.toInt()} $unitLabel'.trim();
    }
    return '${quantity.toStringAsFixed(2)} $unitLabel'.trim();
  }
}
