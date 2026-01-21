import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../data/models/enums.dart';

/// Service for managing iOS Live Activities via OneSignal SDK.
///
/// Live Activities are updated remotely via OneSignal's Live Activity API.
/// When an order status changes, the backend calls OneSignal's API to push
/// updates to the Live Activity widget, even when the app is closed.
class LiveActivityService {
  LiveActivityService._();

  static final LiveActivityService instance = LiveActivityService._();

  static const MethodChannel _channel = MethodChannel('us.tabsy.shahirizada/live_activity');

  bool _initialized = false;

  /// Track active order IDs to their activity tokens
  final Map<String, String> _orderActivityTokens = {};

  Future<void> initialize() async {
    if (_initialized) return;

    // Live Activities are only supported on iOS 16.1+
    if (!Platform.isIOS) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] Not iOS, skipping initialization');
      }
      return;
    }

    _initialized = true;

    // CRITICAL: Setup OneSignal Live Activities for push-to-update support
    // This enables the backend to send APNs pushes directly to Live Activity
    // tokens, allowing updates even when the app is in background/closed.
    //
    // Without this call, Live Activities only update when the app is running.
    try {
      // setupDefault() configures OneSignal to:
      // 1. Handle incoming Live Activity push updates from APNs
      // 2. Enable push-to-start (start activities via push when app is closed)
      // 3. Automatically map activity tokens to the OneSignal activity_id
      await OneSignal.LiveActivities.setupDefault();

      if (kDebugMode) {
        debugPrint('[LiveActivity] ✅ OneSignal Live Activities setup complete');
        debugPrint('[LiveActivity] Push-to-update enabled for background updates');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] ⚠️ Failed to setup OneSignal Live Activities: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('[LiveActivity] Service initialized');
    }
  }

  /// Start a Live Activity for an order.
  ///
  /// This starts the native iOS Live Activity and registers it with OneSignal
  /// using the order ID as the activity_id. The backend can then send updates
  /// via OneSignal's Live Activity API using this activity_id.
  Future<void> startOrderActivity({
    required String orderId,
    String? orderNumber,
    String? status,
    String? fulfillmentType,
    DateTime? eta,
  }) async {
    if (!_initialized || !Platform.isIOS) return;

    try {
      // Calculate progress and status label
      final parsedStatus = status != null ? _parseStatus(status) : null;
      final progress = parsedStatus != null ? _progressForStatus(parsedStatus, fulfillmentType == 'delivery') : 0.1;
      final statusLabel = parsedStatus?.label ?? 'Order Placed';
      final fulfillment = fulfillmentType == 'delivery' ? 'Delivery' : 'Pickup';
      final etaString = eta != null ? _formatEta(eta, fulfillmentType == 'delivery') : null;

      // Start the native Live Activity via method channel
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('startActivity', {
        'orderId': orderId,
        'orderNumber': orderNumber != null ? '#$orderNumber' : 'Order',
        'brandName': 'Shahirizada',
        'status': status ?? 'created',
        'statusLabel': statusLabel,
        'progress': progress,
        'fulfillment': fulfillment,
        'eta': etaString,
      });

      if (result == null) {
        if (kDebugMode) {
          debugPrint('[LiveActivity] Failed to start activity - no result');
        }
        return;
      }

      final token = result['token'] as String?;
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('[LiveActivity] Failed to get activity token');
        }
        return;
      }

      // Register with OneSignal using orderId as activityId
      await OneSignal.LiveActivities.enterLiveActivity(orderId, token);

      _orderActivityTokens[orderId] = token;

      if (kDebugMode) {
        debugPrint('[LiveActivity] Started activity for order: $orderId');
        debugPrint('[LiveActivity] Token: ${token.substring(0, 20)}...');
        debugPrint('[LiveActivity] Registered with OneSignal');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] Platform error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] Start error: $e');
      }
    }
  }

  /// Update a Live Activity for an order.
  ///
  /// Note: With OneSignal integration, updates are sent from the backend
  /// via the OneSignal Live Activity API. This method is kept for local
  /// updates when the app is in foreground, but the primary update path
  /// is through the backend.
  Future<void> updateOrderActivity({
    required String orderId,
    String? orderNumber,
    String? status,
    String? fulfillmentType,
    DateTime? eta,
    int? itemsCount,
  }) async {
    if (!_initialized || !Platform.isIOS) return;

    // Check if this order has an active Live Activity
    if (!_orderActivityTokens.containsKey(orderId)) {
      // Start the activity if it doesn't exist
      await startOrderActivity(
        orderId: orderId,
        orderNumber: orderNumber,
        status: status,
        fulfillmentType: fulfillmentType,
        eta: eta,
      );
      return;
    }

    // Local update via method channel (for foreground updates)
    try {
      final parsedStatus = status != null ? _parseStatus(status) : null;
      final progress = parsedStatus != null ? _progressForStatus(parsedStatus, fulfillmentType == 'delivery') : 0.1;
      final statusLabel = parsedStatus?.label ?? 'Order Updated';
      final fulfillment = fulfillmentType == 'delivery' ? 'Delivery' : 'Pickup';
      final etaString = eta != null ? _formatEta(eta, fulfillmentType == 'delivery') : null;

      await _channel.invokeMethod('updateActivity', {
        'orderId': orderId,
        'status': status,
        'statusLabel': statusLabel,
        'progress': progress,
        'fulfillment': fulfillment,
        'eta': etaString,
      });

      if (kDebugMode) {
        debugPrint('[LiveActivity] Updated activity for order: $orderId, status: $status');
      }

      // Check if this is a terminal status
      if (parsedStatus?.isTerminal == true) {
        // End the activity after a short delay for terminal states
        Future.delayed(const Duration(seconds: 5), () {
          endOrderActivity(orderId);
        });
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] Update platform error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] Update error: $e');
      }
    }
  }

  /// End a Live Activity for an order.
  ///
  /// This unregisters the activity from OneSignal and removes it from
  /// the lock screen / Dynamic Island.
  Future<void> endOrderActivity(String orderId) async {
    if (!_initialized || !Platform.isIOS) return;

    if (!_orderActivityTokens.containsKey(orderId)) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] No activity found for order: $orderId');
      }
      return;
    }

    try {
      // End the native Live Activity
      await _channel.invokeMethod('endActivity', {
        'orderId': orderId,
      });

      // Unregister from OneSignal
      await OneSignal.LiveActivities.exitLiveActivity(orderId);

      _orderActivityTokens.remove(orderId);

      if (kDebugMode) {
        debugPrint('[LiveActivity] Ended activity for order: $orderId');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] End platform error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivity] End error: $e');
      }
    }
  }

  /// Check if an order has an active Live Activity
  bool hasActiveActivity(String orderId) {
    return _orderActivityTokens.containsKey(orderId);
  }

  /// Get all active order IDs with Live Activities
  List<String> get activeOrderIds => _orderActivityTokens.keys.toList();

  void dispose() {
    _orderActivityTokens.clear();
  }

  OrderStatus? _parseStatus(String value) {
    try {
      return OrderStatusMapper.fromValue(value);
    } catch (_) {
      return null;
    }
  }

  double _progressForStatus(OrderStatus status, bool isDelivery) {
    if (status.isTerminal) return 1.0;

    final steps = isDelivery
        ? <OrderStatus>[
            OrderStatus.created,
            OrderStatus.accepted,
            OrderStatus.inKitchen,
            OrderStatus.ready,
            OrderStatus.courierRequested,
            OrderStatus.driverEnRoute,
            OrderStatus.pickedUp,
            OrderStatus.delivered,
          ]
        : <OrderStatus>[
            OrderStatus.created,
            OrderStatus.accepted,
            OrderStatus.inKitchen,
            OrderStatus.ready,
            OrderStatus.delivered,
          ];

    // Normalize status
    var normalizedStatus = status;
    if (status == OrderStatus.confirmed) normalizedStatus = OrderStatus.accepted;
    if (status == OrderStatus.preparing) normalizedStatus = OrderStatus.inKitchen;
    if (status == OrderStatus.outForDelivery) normalizedStatus = OrderStatus.pickedUp;

    final index = steps.indexOf(normalizedStatus);
    if (index <= 0) return 0.1;
    if (steps.length <= 1) return 1.0;
    return index / (steps.length - 1);
  }

  String _formatEta(DateTime eta, bool isDelivery) {
    final now = DateTime.now();
    final minutes = eta.difference(now).inMinutes;

    if (minutes <= 1) {
      return isDelivery ? 'Arriving now' : 'Ready now';
    }

    if (minutes < 60) {
      return isDelivery ? 'ETA ${minutes}m' : 'Ready in ${minutes}m';
    }

    final hours = eta.hour;
    final mins = eta.minute;
    final ampm = hours >= 12 ? 'PM' : 'AM';
    final hour12 = hours % 12 == 0 ? 12 : hours % 12;
    final timeLabel = '$hour12:${mins.toString().padLeft(2, '0')} $ampm';
    return isDelivery ? 'ETA $timeLabel' : 'Ready at $timeLabel';
  }
}
