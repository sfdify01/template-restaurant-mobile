import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/push_notification_provider.dart';
import '../router/app_router.dart';
import '../services/onesignal_service.dart';
import '../theme/app_theme.dart';

class NotificationHandler extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationHandler({super.key, required this.child});

  @override
  ConsumerState<NotificationHandler> createState() =>
      _NotificationHandlerState();
}

class _NotificationHandlerState extends ConsumerState<NotificationHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingNotification();
    });
  }

  void _checkPendingNotification() {
    final pushState = ref.read(pushNotificationProvider);
    if (pushState.pendingOrderId != null) {
      _navigateToOrder(pushState.pendingOrderId!);
    }
  }

  void _navigateToOrder(String orderId) {
    if (kDebugMode) {
      debugPrint('[NotificationHandler] Navigating to order: $orderId');
    }

    ref.read(pushNotificationProvider.notifier).clearPendingOrderId();

    final router = AutoRouter.of(context);

    router.pushAll([
      MainShellRoute(children: [
        OrdersTab(children: [
          const OrdersRoute(),
          OrderDetailRoute(orderId: orderId),
        ]),
      ]),
    ]);
  }

  void _showOrderStatusSnackbar(OrderNotificationData data) {
    if (kDebugMode) {
      debugPrint('[NotificationHandler] Showing snackbar for: $data');
    }

    ref.read(pushNotificationProvider.notifier).clearForegroundNotification();

    final colors = context.colors;
    final title = data.title ?? 'Order Update';
    final body = data.body ?? 'Your order status has changed';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.bell,
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: colors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
        ),
        duration: const Duration(seconds: 5),
        action: data.orderId != null
            ? SnackBarAction(
                label: 'View',
                textColor: colors.primary,
                onPressed: () => _navigateToOrder(data.orderId!),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PushNotificationState>(pushNotificationProvider, (prev, next) {
      // Handle notification tap (background → navigate to order)
      if (next.pendingOrderId != null &&
          prev?.pendingOrderId != next.pendingOrderId) {
        _navigateToOrder(next.pendingOrderId!);
      }

      // Handle foreground notification (show in-app snackbar)
      if (next.foregroundNotification != null &&
          prev?.foregroundNotification != next.foregroundNotification) {
        _showOrderStatusSnackbar(next.foregroundNotification!);
      }
    });

    return widget.child;
  }
}
