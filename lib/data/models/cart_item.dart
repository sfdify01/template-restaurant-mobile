import 'package:dart_mappable/dart_mappable.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';
import 'menu_item.dart';

part 'cart_item.mapper.dart';

/// Modifier selection for cart items
@MappableClass()
class CartModifier with CartModifierMappable {
  final String id;
  final String name;
  final int priceCents;

  const CartModifier({
    required this.id,
    required this.name,
    this.priceCents = 0,
  });
}

/// Cart item model for local cart state
@MappableClass(caseStyle: CaseStyle.snakeCase)
class CartItem with CartItemMappable {
  final String id;
  final String menuItemId;
  final String name;
  final int unitPriceCents;
  final PriceUnit priceUnit;
  final String? unitLabel;
  final double qty;
  final String? imageUrl;
  final List<CartModifier> modifiers;
  final String? note;
  final Map<String, dynamic>? metadata;

  const CartItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.unitPriceCents,
    this.priceUnit = PriceUnit.each,
    this.unitLabel,
    required this.qty,
    this.imageUrl,
    this.modifiers = const [],
    this.note,
    this.metadata,
  });

  /// Create cart item from menu item
  factory CartItem.fromMenuItem(
    MenuItem item, {
    double qty = 1,
    String? note,
    List<CartModifier> modifiers = const [],
  }) {
    return CartItem(
      id: const Uuid().v4(),
      menuItemId: item.id,
      name: item.name,
      unitPriceCents: item.priceCents,
      priceUnit: item.priceUnit,
      qty: qty,
      imageUrl: item.imageUrl,
      modifiers: modifiers,
      note: note,
    );
  }

  /// Total price in cents (unit price * quantity + modifiers)
  int get totalCents {
    final modifierTotal = modifiers.fold<int>(
      0,
      (sum, m) => sum + m.priceCents,
    );
    return ((unitPriceCents + modifierTotal) * qty).round();
  }

  /// Total price in dollars
  double get totalInDollars => totalCents / 100.0;

  /// Unit price in dollars
  double get unitPriceInDollars => unitPriceCents / 100.0;

  /// Formatted unit price
  String get formattedUnitPrice {
    final price = '\$${unitPriceInDollars.toStringAsFixed(2)}';
    return '$price${priceUnit.priceSuffix}';
  }

  /// Formatted total price
  String get formattedTotal => '\$${totalInDollars.toStringAsFixed(2)}';

  /// Formatted quantity display (e.g., "2 lb" or "3")
  String get formattedQuantity {
    if (priceUnit.isWeight) {
      return '${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2)} ${priceUnit.quantitySuffix}';
    }
    return qty.toInt().toString();
  }

  /// Whether this is a weight-based item
  bool get isWeightBased => priceUnit.isWeight;

  /// Create copy with updated quantity
  CartItem copyWithQty(double newQty) => copyWith(qty: newQty);
}
