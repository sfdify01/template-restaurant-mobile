import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Data model for order status notification
class OrderNotificationData {
  final String? orderId;
  final String? orderNumber;
  final String? status;
  final String? title;
  final String? body;

  const OrderNotificationData({
    this.orderId,
    this.orderNumber,
    this.status,
    this.title,
    this.body,
  });

  @override
  String toString() =>
      'OrderNotificationData(orderId: $orderId, orderNumber: $orderNumber, status: $status, title: $title)';
}

class OneSignalService {
  OneSignalService._();
  static final OneSignalService instance = OneSignalService._();

  static const String _appId = '02131d59-ddb7-42f0-a1f7-0cb8b2d512e7';

  bool _initialized = false;

  /// Called when user taps on a notification
  void Function(OrderNotificationData data)? onNotificationTapped;

  /// Called when a notification is received while app is in foreground
  void Function(OrderNotificationData data)? onForegroundNotificationReceived;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      OneSignal.initialize(_appId);

      OneSignal.Notifications.addClickListener(_onNotificationClicked);

      OneSignal.Notifications.addForegroundWillDisplayListener(
        _onForegroundNotification,
      );

      // NOTE: Push subscription and permission observers are now handled
      // directly by PushTokenSyncService for push token syncing

      _initialized = true;

      // Request permission - this is required to get push token on iOS
      // Even if already granted in settings, we need to call this for APNs registration
      final permissionGranted = await OneSignal.Notifications.requestPermission(true);

      if (kDebugMode) {
        debugPrint('[OneSignal] ═══════════════════════════════════════');
        debugPrint('[OneSignal] ✅ Initialized successfully');
        debugPrint('[OneSignal] Permission granted: $permissionGranted');
        debugPrint('[OneSignal] Permission state: ${OneSignal.Notifications.permission}');
        debugPrint('[OneSignal] Subscription ID: ${OneSignal.User.pushSubscription.id}');
        debugPrint('[OneSignal] Push Token: ${OneSignal.User.pushSubscription.token != null ? "${OneSignal.User.pushSubscription.token!.substring(0, 20)}..." : "null"}');
        debugPrint('[OneSignal] OptedIn: ${OneSignal.User.pushSubscription.optedIn}');
        debugPrint('[OneSignal] ═══════════════════════════════════════');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Initialization error: $e');
      }
    }
  }

  Future<void> login(String userId) async {
    try {
      await OneSignal.login(userId);
      if (kDebugMode) {
        debugPrint('[OneSignal] User logged in: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Login error: $e');
      }
    }
  }

  Future<void> logout() async {
    try {
      await OneSignal.logout();
      if (kDebugMode) {
        debugPrint('[OneSignal] User logged out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Logout error: $e');
      }
    }
  }

  Future<void> setTags(Map<String, String> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      if (kDebugMode) {
        debugPrint('[OneSignal] Tags set: $tags');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Set tags error: $e');
      }
    }
  }

  Future<void> removeTags(List<String> keys) async {
    try {
      await OneSignal.User.removeTags(keys);
      if (kDebugMode) {
        debugPrint('[OneSignal] Tags removed: $keys');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Remove tags error: $e');
      }
    }
  }

  Future<void> setEmail(String email) async {
    try {
      await OneSignal.User.addEmail(email);
      if (kDebugMode) {
        debugPrint('[OneSignal] Email set: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Set email error: $e');
      }
    }
  }

  Future<void> setPhoneNumber(String phoneNumber) async {
    try {
      await OneSignal.User.addSms(phoneNumber);
      if (kDebugMode) {
        debugPrint('[OneSignal] Phone number set: $phoneNumber');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OneSignal] Set phone number error: $e');
      }
    }
  }

  bool get hasPermission => OneSignal.Notifications.permission;

  Future<bool> requestPermission({bool fallbackToSettings = false}) async {
    return await OneSignal.Notifications.requestPermission(fallbackToSettings);
  }

  /// Extract order notification data from a notification
  OrderNotificationData _extractNotificationData(OSNotification notification) {
    final additionalData = notification.additionalData;
    final orderId =
        additionalData?['order_id']?.toString() ??
        additionalData?['orderId']?.toString();
    final orderNumber =
        additionalData?['order_number']?.toString() ??
        additionalData?['orderNumber']?.toString();

    return OrderNotificationData(
      orderId: orderId,
      orderNumber: orderNumber,
      status: additionalData?['status']?.toString(),
      title: notification.title,
      body: notification.body,
    );
  }

  void _onNotificationClicked(OSNotificationClickEvent event) {
    if (kDebugMode) {
      debugPrint('[OneSignal] Notification clicked');
      debugPrint('[OneSignal] Title: ${event.notification.title}');
      debugPrint('[OneSignal] Body: ${event.notification.body}');
      debugPrint(
        '[OneSignal] Additional data: ${event.notification.additionalData}',
      );
    }

    final data = _extractNotificationData(event.notification);
    onNotificationTapped?.call(data);
  }

  void _onForegroundNotification(OSNotificationWillDisplayEvent event) {
    if (kDebugMode) {
      debugPrint('[OneSignal] Foreground notification received');
      debugPrint('[OneSignal] Title: ${event.notification.title}');
      debugPrint('[OneSignal] Body: ${event.notification.body}');
      debugPrint(
        '[OneSignal] Additional data: ${event.notification.additionalData}',
      );
    }

    final data = _extractNotificationData(event.notification);

    // Notify listeners about the foreground notification
    onForegroundNotificationReceived?.call(data);

    // Display the notification in the system tray
    event.notification.display();
  }

  String? get subscriptionId => OneSignal.User.pushSubscription.id;

  String? get pushToken => OneSignal.User.pushSubscription.token;

  bool get isSubscribed => OneSignal.User.pushSubscription.optedIn ?? false;
}
