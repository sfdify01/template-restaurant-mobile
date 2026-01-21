import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/market_api_service.dart';
import '../../../data/models/models.dart';

/// Simple local storage for guest orders (equivalent to web's localStorage)
///
/// After a guest places an order, we store it locally so they can view it
/// on the confirmation and order detail screens without needing authentication.
/// This matches the web app's approach of using localStorage for guest orders.
class GuestOrderStorage {
  GuestOrderStorage._();
  static final GuestOrderStorage instance = GuestOrderStorage._();

  static const String _storageKey = 'guest_orders';

  /// Save an order from API response to local storage
  /// This converts the API response format to our Order model format
  Future<void> saveOrderFromResponse(OrderDetailsResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);

      Map<String, dynamic> orders = {};
      if (ordersJson != null) {
        orders = Map<String, dynamic>.from(jsonDecode(ordersJson));
      }

      // Convert API response to storage format matching Order model
      final orderData = _convertResponseToStorageFormat(response);
      orders[response.id] = orderData;

      await prefs.setString(_storageKey, jsonEncode(orders));

      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Saved order from response: ${response.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Failed to save order from response: $e');
      }
    }
  }

  /// Convert OrderDetailsResponse to storage format
  Map<String, dynamic> _convertResponseToStorageFormat(OrderDetailsResponse response) {
    final totals = response.totals;
    final items = response.items;

    final itemRows = items.map((item) {
      final itemMap = item as Map<String, dynamic>;
      return {
        'id': itemMap['id'] ?? '',
        'order_id': response.id,
        'menu_item_id': itemMap['sku'] ?? '',
        'name': itemMap['name'] ?? '',
        'quantity': (itemMap['qty'] as num?)?.toDouble() ?? 1.0,
        'unit_price_cents': itemMap['priceCents'] ?? 0,
        'total_cents': ((itemMap['priceCents'] ?? 0) as num) *
            ((itemMap['qty'] as num?) ?? 1),
        'image_url': itemMap['image'],
        'notes': itemMap['note'],
        'price_unit': itemMap['unit'] ?? 'each',
      };
    }).toList();

    return {
      'id': response.id,
      'order_number': response.orderNumber ?? 0,
      'tenant_id': response.tenantId,
      'customer_id': response.customerId,
      'fulfillment_type': response.fulfillmentType,
      'status': response.status,
      'payment_status': response.paymentStatus,
      'source': 'mobile',
      'currency': 'USD',
      'subtotal_cents': totals['subtotal'] ?? 0,
      'tax_cents': totals['tax'] ?? 0,
      'tip_cents': totals['tip'] ?? 0,
      'delivery_fee_cents': totals['deliveryFee'] ?? 0,
      'service_fee_cents': totals['serviceFee'] ?? 0,
      'discount_cents': totals['discount'] ?? 0,
      'total_cents': totals['total'] ?? 0,
      'items_count': items.length,
      'weight_oz': 0,
      'contact_name': response.contact?['name'],
      'contact_email': response.contact?['email'],
      'contact_phone': response.contact?['phone'],
      'pickup_eta': response.pickupEta,
      'delivery_eta': response.deliveryEta,
      'metadata': response.metadata,
      'created_at': response.createdAt,
      'updated_at': response.updatedAt,
      // Convert items to storage format
      'items': itemRows,
      // Backward-compatible key for older readers
      'order_items': itemRows,
      // Convert delivery address if present
      if (response.deliveryAddress != null)
        'delivery_address': {
          'id': '',
          'street_line_1': response.deliveryAddress!['line1'],
          'street_line_2': response.deliveryAddress!['line2'],
          'city': response.deliveryAddress!['city'],
          'state': response.deliveryAddress!['state'],
          'postal_code': response.deliveryAddress!['zip'],
        },
    };
  }

  /// Save an order to local storage
  Future<void> saveOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);

      Map<String, dynamic> orders = {};
      if (ordersJson != null) {
        orders = Map<String, dynamic>.from(jsonDecode(ordersJson));
      }

      // Store order as JSON
      orders[order.id] = order.toMap();

      await prefs.setString(_storageKey, jsonEncode(orders));

      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Saved order: ${order.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Failed to save order: $e');
      }
    }
  }

  /// Get an order from local storage by ID
  Future<Order?> getOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);

      if (ordersJson == null) return null;

      final orders = Map<String, dynamic>.from(jsonDecode(ordersJson));
      final orderData = orders[orderId];

      if (orderData == null) return null;

      return OrderMapper.fromMap(Map<String, dynamic>.from(orderData));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Failed to get order: $e');
      }
      return null;
    }
  }

  /// Get all stored guest orders
  Future<List<Order>> getAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);

      if (ordersJson == null) return [];

      final orders = Map<String, dynamic>.from(jsonDecode(ordersJson));

      return orders.values
          .map((data) => OrderMapper.fromMap(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Failed to get all orders: $e');
      }
      return [];
    }
  }

  /// Remove an order from local storage
  Future<void> removeOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);

      if (ordersJson == null) return;

      final orders = Map<String, dynamic>.from(jsonDecode(ordersJson));
      orders.remove(orderId);

      await prefs.setString(_storageKey, jsonEncode(orders));

      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Removed order: $orderId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Failed to remove order: $e');
      }
    }
  }

  /// Clear all stored guest orders
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);

      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Cleared all orders');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Failed to clear orders: $e');
      }
    }
  }

  /// Clean up old orders (older than 7 days)
  Future<void> cleanupOldOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);

      if (ordersJson == null) return;

      final orders = Map<String, dynamic>.from(jsonDecode(ordersJson));
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 7));

      orders.removeWhere((id, data) {
        try {
          final createdAt = DateTime.parse(data['created_at'] as String);
          return createdAt.isBefore(cutoff);
        } catch (_) {
          return false;
        }
      });

      await prefs.setString(_storageKey, jsonEncode(orders));

      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Cleaned up old orders');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestOrderStorage] Failed to cleanup orders: $e');
      }
    }
  }
}
