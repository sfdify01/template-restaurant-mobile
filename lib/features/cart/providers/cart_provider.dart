import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/models.dart';

part 'cart_provider.g.dart';

/// Cart state
class CartState {
  final List<CartItem> items;
  final FulfillmentType fulfillmentType;
  final String? specialInstructions;
  final int tipCents;

  const CartState({
    this.items = const [],
    this.fulfillmentType = FulfillmentType.pickup,
    this.specialInstructions,
    this.tipCents = 0,
  });

  /// Total items count
  int get itemCount => items.fold(0, (sum, item) => sum + item.qty.ceil());

  /// Subtotal in cents
  int get subtotalCents => items.fold(0, (sum, item) => sum + item.totalCents);

  /// Subtotal in dollars
  double get subtotalInDollars => subtotalCents / 100.0;

  /// Formatted subtotal
  String get formattedSubtotal => '\$${subtotalInDollars.toStringAsFixed(2)}';

  /// Tip in dollars
  double get tipInDollars => tipCents / 100.0;

  /// Whether cart is empty
  bool get isEmpty => items.isEmpty;

  /// Whether cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<CartItem>? items,
    FulfillmentType? fulfillmentType,
    String? specialInstructions,
    int? tipCents,
  }) {
    return CartState(
      items: items ?? this.items,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      tipCents: tipCents ?? this.tipCents,
    );
  }
}

/// Cart notifier using latest Riverpod syntax
@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  CartState build() {
    return const CartState();
  }

  /// Add item to cart
  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere(
      (i) => i.menuItemId == item.menuItemId && _sameModifiers(i, item),
    );

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existing = state.items[existingIndex];
      final updatedItem = existing.copyWithQty(existing.qty + item.qty);
      final newItems = [...state.items];
      newItems[existingIndex] = updatedItem;
      state = state.copyWith(items: newItems);
    } else {
      // Add new item
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  /// Add item from menu item
  void addFromMenuItem(
    MenuItem menuItem, {
    double qty = 1,
    String? note,
    List<CartModifier> modifiers = const [],
  }) {
    final cartItem = CartItem.fromMenuItem(
      menuItem,
      qty: qty,
      note: note,
      modifiers: modifiers,
    );
    addItem(cartItem);
  }

  /// Update item quantity
  void updateQuantity(String itemId, double newQty) {
    if (newQty <= 0) {
      removeItem(itemId);
      return;
    }

    final newItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWithQty(newQty);
      }
      return item;
    }).toList();

    state = state.copyWith(items: newItems);
  }

  /// Remove item from cart
  void removeItem(String itemId) {
    final newItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: newItems);
  }

  /// Clear cart
  void clear() {
    state = const CartState();
  }

  /// Set fulfillment type
  void setFulfillmentType(FulfillmentType type) {
    state = state.copyWith(fulfillmentType: type);
  }

  /// Set special instructions
  void setSpecialInstructions(String? instructions) {
    state = state.copyWith(specialInstructions: instructions);
  }

  /// Set tip amount in cents
  void setTip(int tipCents) {
    state = state.copyWith(tipCents: tipCents);
  }

  /// Check if two items have the same modifiers
  bool _sameModifiers(CartItem a, CartItem b) {
    if (a.modifiers.length != b.modifiers.length) return false;
    for (var i = 0; i < a.modifiers.length; i++) {
      if (a.modifiers[i].id != b.modifiers[i].id) return false;
    }
    return true;
  }
}

/// Cart item count for badge
@riverpod
int cartItemCount(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemCount;
}

/// Cart subtotal
@riverpod
double cartSubtotal(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.subtotalInDollars;
}
