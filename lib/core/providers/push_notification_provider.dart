import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/live_activity_service.dart';
import '../services/onesignal_service.dart';

part 'push_notification_provider.g.dart';

class PushNotificationState {
  final bool isInitialized;
  final bool hasPermission;
  final String? userId;
  final String? pendingOrderId;

  /// Latest foreground notification data (for in-app display)
  final OrderNotificationData? foregroundNotification;

  const PushNotificationState({
    this.isInitialized = false,
    this.hasPermission = false,
    this.userId,
    this.pendingOrderId,
    this.foregroundNotification,
  });

  PushNotificationState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    String? userId,
    String? pendingOrderId,
    OrderNotificationData? foregroundNotification,
    bool clearForegroundNotification = false,
  }) {
    return PushNotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      userId: userId ?? this.userId,
      pendingOrderId: pendingOrderId,
      foregroundNotification: clearForegroundNotification
          ? null
          : (foregroundNotification ?? this.foregroundNotification),
    );
  }
}

@Riverpod(keepAlive: true)
class PushNotification extends _$PushNotification {
  @override
  PushNotificationState build() {
    OneSignalService.instance.onNotificationTapped = _onNotificationTapped;
    OneSignalService.instance.onForegroundNotificationReceived =
        _onForegroundNotification;

    final hasPermission = OneSignalService.instance.hasPermission;

    return PushNotificationState(
      isInitialized: true,
      hasPermission: hasPermission,
    );
  }

  void _onNotificationTapped(OrderNotificationData data) {
    if (kDebugMode) {
      debugPrint('[PushNotification] Notification tapped: $data');
    }

    if (data.orderId != null && data.status != null) {
      LiveActivityService.instance.updateOrderActivity(
        orderId: data.orderId!,
        orderNumber: data.orderNumber,
        status: data.status,
      );
    }

    if (data.orderId != null) {
      state = state.copyWith(pendingOrderId: data.orderId);
    }
  }

  void _onForegroundNotification(OrderNotificationData data) {
    if (kDebugMode) {
      debugPrint('[PushNotification] Foreground notification received: $data');
    }

    // Store the notification data for in-app display
    state = state.copyWith(foregroundNotification: data);

    if (data.orderId != null && data.status != null) {
      LiveActivityService.instance.updateOrderActivity(
        orderId: data.orderId!,
        orderNumber: data.orderNumber,
        status: data.status,
      );
    }
  }

  void clearPendingOrderId() {
    state = state.copyWith(pendingOrderId: null);
  }

  void clearForegroundNotification() {
    state = state.copyWith(clearForegroundNotification: true);
  }

  Future<void> loginUser({
    required String userId,
    String? email,
    String? phone,
  }) async {
    await OneSignalService.instance.login(userId);

    if (email != null) {
      await OneSignalService.instance.setEmail(email);
    }

    if (phone != null) {
      await OneSignalService.instance.setPhoneNumber(phone);
    }

    state = state.copyWith(userId: userId);

    if (kDebugMode) {
      debugPrint('[PushNotification] User logged in: $userId');
    }
  }

  Future<void> logoutUser() async {
    await OneSignalService.instance.logout();
    state = state.copyWith(userId: null);

    if (kDebugMode) {
      debugPrint('[PushNotification] User logged out');
    }
  }

  Future<bool> requestPermission() async {
    final granted = await OneSignalService.instance.requestPermission();
    state = state.copyWith(hasPermission: granted);
    return granted;
  }

  Future<void> setTags(Map<String, String> tags) async {
    await OneSignalService.instance.setTags(tags);
  }

  Future<void> updateUserInfo({
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
  }) async {
    if (email != null) {
      await OneSignalService.instance.setEmail(email);
    }

    if (phone != null) {
      await OneSignalService.instance.setPhoneNumber(phone);
    }

    final tags = <String, String>{};
    if (firstName != null) tags['first_name'] = firstName;
    if (lastName != null) tags['last_name'] = lastName;

    if (tags.isNotEmpty) {
      await OneSignalService.instance.setTags(tags);
    }
  }
}
