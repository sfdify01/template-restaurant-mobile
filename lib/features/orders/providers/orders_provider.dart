import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../../../core/config/env_provider.dart';
import '../../../core/services/market_api_service.dart';
import '../../../data/models/models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/guest_profile_storage.dart';
import '../services/guest_order_storage.dart';

part 'orders_provider.g.dart';

/// Fetch orders for the current user
@riverpod
Future<List<Order>> orders(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated || auth.customer == null) {
    return [];
  }

  final response = await supabase
      .from('orders')
      .select('''
        *,
        items:order_items(*),
        delivery_address:addresses(*)
      ''')
      .eq('customer_id', auth.customer!.id)
      .order('created_at', ascending: false);

  return (response as List).map((item) => OrderMapper.fromMap(item)).toList();
}

/// Fetch orders for guest users (local + customer lookup)
@riverpod
Future<List<Order>> guestOrders(Ref ref) async {
  final profile = await GuestProfileStorage.instance.loadProfile();

  // If we have a guest profile, prefer server lookup (matches web behavior)
  if (profile != null) {
    final hasLookupKey =
        (profile.email?.isNotEmpty ?? false) ||
        (profile.phone?.isNotEmpty ?? false) ||
        (profile.customerId?.isNotEmpty ?? false);
    if (!hasLookupKey) {
      return GuestOrderStorage.instance.getAllOrders();
    }
    try {
      final api = MarketApiService.instance;
      api.initialize(
        anonKey: RuntimeEnvConfig.supabaseAnonKey(currentEnvironment),
      );
      final orders = await api.lookupCustomerOrders(
        email: profile.email,
        phone: profile.phone,
        customerId: profile.customerId,
      );
      if (orders.isNotEmpty) return orders;
    } catch (_) {
      // Fall through to local storage fallback
    }
  }

  return GuestOrderStorage.instance.getAllOrders();
}

@riverpod
Future<List<Order>> guestActiveOrders(Ref ref) async {
  final allOrders = await ref.watch(guestOrdersProvider.future);
  return allOrders.where((order) => !order.status.isTerminal).toList();
}

@riverpod
Future<List<Order>> guestPastOrders(Ref ref) async {
  final allOrders = await ref.watch(guestOrdersProvider.future);
  return allOrders.where((order) => order.status.isTerminal).toList();
}

/// Fetch active orders (not completed or cancelled)
@riverpod
Future<List<Order>> activeOrders(Ref ref) async {
  final allOrders = await ref.watch(ordersProvider.future);
  return allOrders.where((order) => !order.status.isTerminal).toList();
}

/// Fetch past orders (completed or cancelled)
@riverpod
Future<List<Order>> pastOrders(Ref ref) async {
  final allOrders = await ref.watch(ordersProvider.future);
  return allOrders.where((order) => order.status.isTerminal).toList();
}

/// Fetch a single order by ID
///
/// First checks local guest order storage (like web's localStorage),
/// then falls back to Supabase for authenticated users.
@riverpod
Future<Order?> order(Ref ref, String orderId) async {
  // First, check guest order storage (like web's localStorage)
  // This allows guests to view orders they just placed
  final guestOrder = await GuestOrderStorage.instance.getOrder(orderId);
  if (guestOrder != null) {
    return guestOrder;
  }

  final auth = ref.watch(authProvider);

  // If guest, try edge function lookup and cache locally
  if (!auth.isAuthenticated) {
    try {
      final api = MarketApiService.instance;
      api.initialize(
        anonKey: RuntimeEnvConfig.supabaseAnonKey(currentEnvironment),
      );
      final response = await api.getOrder(orderId);
      await GuestOrderStorage.instance.saveOrderFromResponse(response);
      return await GuestOrderStorage.instance.getOrder(orderId);
    } catch (_) {
      return null;
    }
  }

  // Fallback to Supabase for authenticated users
  final response = await supabase
      .from('orders')
      .select('''
        *,
        items:order_items(*),
        delivery_address:addresses(*)
      ''')
      .eq('id', orderId)
      .maybeSingle();

  if (response == null) return null;
  return OrderMapper.fromMap(response);
}

/// Stream order updates for real-time tracking
@riverpod
Stream<Order?> orderStream(Ref ref, String orderId) {
  return supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', orderId)
      .map((data) {
        if (data.isEmpty) return null;
        return OrderMapper.fromMap(data.first);
      });
}

/// Fetch courier task for an order
@riverpod
Future<CourierTask?> orderCourierTask(Ref ref, String orderId) async {
  final response = await supabase
      .from('courier_tasks')
      .select()
      .eq('order_id', orderId)
      .maybeSingle();

  if (response == null) return null;
  return CourierTaskMapper.fromMap(response);
}
