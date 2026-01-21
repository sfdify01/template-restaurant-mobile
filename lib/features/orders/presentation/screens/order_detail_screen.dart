import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/push_notification_provider.dart';
import '../../../../core/services/market_api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../data/models/models.dart';
import '../../providers/orders_provider.dart';

// ===========================================================================
// STORE CONTACT INFO (matching web config)
// ===========================================================================
const String _storePhone = '(347) 206-0218';
const String _storeEmail = 'shahirizadafreshmarket@gmail.com';
const String _storeName = 'Shahirizada Fresh Market';

@RoutePage()
class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, @PathParam('id') required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen>
    with WidgetsBindingObserver {
  Timer? _countdownTimer;
  Timer? _refreshTimer;
  Duration _remainingTime = Duration.zero;
  bool _isCancelling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      _silentRefresh();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    // Silently refresh order data without showing loading indicator
    ref.invalidate(orderProvider(widget.orderId));
    ref.invalidate(orderCourierTaskProvider(widget.orderId));
  }

  Future<void> _onRefresh() async {
    // Manual pull-to-refresh
    ref.invalidate(orderProvider(widget.orderId));
    ref.invalidate(orderCourierTaskProvider(widget.orderId));
    // Wait for the provider to complete
    await ref.read(orderProvider(widget.orderId).future);
  }

  void _startCountdown(DateTime createdAt) {
    _updateRemainingTime(createdAt);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime(createdAt);
    });
  }

  void _updateRemainingTime(DateTime createdAt) {
    final remaining = calculateCancelWindowRemaining(createdAt);
    if (mounted) {
      setState(() {
        _remainingTime = remaining;
      });
    }

    if (remaining <= Duration.zero) {
      _countdownTimer?.cancel();
    }
  }

  bool get canCancel => _remainingTime > Duration.zero;

  String get countdownText {
    if (_remainingTime <= Duration.zero) return 'Cancel window closed';
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelOrder(Order order) async {
    setState(() {
      _isCancelling = true;
      _error = null;
    });

    try {
      final api = MarketApiService.instance;
      await api.cancelOrder(
        orderId: order.id,
        customerPhone: order.contactPhone,
        customerEmail: order.contactEmail,
        reason: 'Cancelled by customer',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Invalidate orders and navigate back
      ref.invalidate(ordersProvider);
      ref.invalidate(guestOrdersProvider);
      context.router.maybePop();
    } catch (e) {
      setState(() {
        _error = UserErrorMessage.from(
          e,
          fallback: 'Unable to cancel your order. Please try again.',
        );
        _isCancelling = false;
      });
    }
  }

  void _showCancelDialog(Order order) {
    final totalDollars = order.totalInDollars;
    final processingFeeEstimate = totalDollars * 0.029 + 0.30;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dialogColors.errorBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.triangleAlert,
                  color: dialogColors.error,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Cancel Order?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to cancel this order?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dialogColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Total',
                          style: TextStyle(color: dialogColors.textSecondary),
                        ),
                        Text('\$${totalDollars.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Refund Amount',
                          style: TextStyle(color: dialogColors.success),
                        ),
                        Text(
                          '\$${totalDollars.toStringAsFixed(2)}',
                          style: TextStyle(color: dialogColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dialogColors.warningBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.info,
                      color: dialogColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Processing fees may apply',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: dialogColors.warning,
                            ),
                          ),
                          Text(
                            'Stripe fees (~\$${processingFeeEstimate.toStringAsFixed(2)}) may not be refunded.',
                            style: TextStyle(
                              fontSize: 12,
                              color: dialogColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Refunds typically take 5-10 business days.',
                style: TextStyle(
                  fontSize: 12,
                  color: dialogColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Keep Order'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _cancelOrder(order);
              },
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final courierTaskAsync = ref.watch(
      orderCourierTaskProvider(widget.orderId),
    );

    // Listen for push notifications related to this order
    ref.listen<PushNotificationState>(pushNotificationProvider, (prev, next) {
      final notification = next.foregroundNotification;
      if (notification != null &&
          notification.orderId == widget.orderId &&
          prev?.foregroundNotification != notification) {
        if (kDebugMode) {
          debugPrint(
            '[OrderDetail] Received notification for this order, refreshing...',
          );
        }
        // Auto-refresh order data when we get a notification for this order
        _silentRefresh();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: orderAsync.when(
          data: (order) {
            if (order == null) {
              return const Center(child: Text('Order not found'));
            }

            // Start countdown if order is recent
            if (canCancelOrder(order.createdAt) && _countdownTimer == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startCountdown(order.createdAt);
              });
            }

            // Get courier task data
            final courierTask = courierTaskAsync.valueOrNull;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order number header
                  _buildOrderHeader(order),
                  const SizedBox(height: 16),

                  // Status card with progress
                  _buildStatusCard(order),
                  const SizedBox(height: 16),

                  // Live courier tracking card (for delivery orders with tracking)
                  if (order.isDelivery &&
                      courierTask != null &&
                      courierTask.trackingUrl != null) ...[
                    _buildCourierTrackingCard(courierTask),
                    const SizedBox(height: 16),
                  ],

                  // Cancel window countdown (if applicable)
                  if (canCancelOrder(order.createdAt) &&
                      !order.status.isTerminal) ...[
                    _buildCancelWindowCard(order),
                    const SizedBox(height: 16),
                  ],

                  // Error message
                  if (_error != null) ...[
                    _buildErrorCard(),
                    const SizedBox(height: 16),
                  ],

                  // Order items
                  _buildOrderItems(order),
                  const SizedBox(height: 16),

                  // Fulfillment info
                  _buildFulfillmentInfo(order),
                  const SizedBox(height: 16),

                  // Contact info
                  if (order.contactName != null || order.contactPhone != null)
                    _buildContactInfo(order),
                  if (order.contactName != null || order.contactPhone != null)
                    const SizedBox(height: 16),

                  // Payment summary
                  _buildPaymentSummary(order),
                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(order),
                ],
              ),
            );
          },
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 200),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.circleAlert,
                      size: 48,
                      color: context.colors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load order',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.refresh(orderProvider(widget.orderId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              order.isPickup ? LucideIcons.store : LucideIcons.truck,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${order.orderNumberDisplay}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  order.isPickup ? 'Pickup Order' : 'Delivery Order',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            order.formattedTotal,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Order order) {
    // Check for cancelled/failed/rejected statuses - show error state
    final isFailed = [
      OrderStatus.rejected,
      OrderStatus.canceled,
      OrderStatus.failed,
    ].contains(order.status);

    if (isFailed) {
      return _buildFailedStatusCard(order);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (!order.status.isTerminal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.successBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: context.colors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Live',
                          style: TextStyle(
                            color: context.colors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Linear status tracker matching website
            _buildLinearStatusTracker(order),
            if (!order.status.isTerminal && order.eta != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estimated ${order.isPickup ? 'ready' : 'delivery'}: ${_formatDateTime(order.eta!)}',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFailedStatusCard(Order order) {
    final colors = context.colors;
    final statusLabel = order.status == OrderStatus.canceled
        ? 'Canceled'
        : order.status == OrderStatus.rejected
        ? 'Rejected'
        : 'Failed';
    final statusMessage = order.status == OrderStatus.canceled
        ? 'This order has been canceled.'
        : order.status == OrderStatus.rejected
        ? 'Your order could not be confirmed. Please contact us.'
        : 'There was an error processing your order.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleX, color: colors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order $statusLabel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: TextStyle(color: colors.error, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build linear status tracker matching website's StatusTracker component
  /// Uses exact same status enums as web for consistency
  Widget _buildLinearStatusTracker(Order order) {
    // Define status steps based on fulfillment type (matching website exactly)
    final List<_StatusStep> steps = order.isPickup
        ? [
            _StatusStep(
              status: OrderStatus.created,
              label: 'Order Placed',
              description: 'Your order has been received',
            ),
            _StatusStep(
              status: OrderStatus.accepted,
              label: 'Confirmed',
              description: 'Restaurant confirmed your order',
            ),
            _StatusStep(
              status: OrderStatus.inKitchen,
              label: 'Preparing',
              description: 'Your order is being prepared',
            ),
            _StatusStep(
              status: OrderStatus.ready,
              label: 'Ready for Pickup',
              description: 'Your order is ready!',
            ),
            _StatusStep(
              status: OrderStatus.delivered,
              label: 'Picked Up',
              description: 'Order completed',
            ),
          ]
        : [
            _StatusStep(
              status: OrderStatus.created,
              label: 'Order Placed',
              description: 'Your order has been received',
            ),
            _StatusStep(
              status: OrderStatus.accepted,
              label: 'Confirmed',
              description: 'Restaurant confirmed your order',
            ),
            _StatusStep(
              status: OrderStatus.inKitchen,
              label: 'Preparing',
              description: 'Your order is being prepared',
            ),
            _StatusStep(
              status: OrderStatus.ready,
              label: 'Ready for Courier',
              description: 'Prepping for courier handoff',
            ),
            _StatusStep(
              status: OrderStatus.courierRequested,
              label: 'Courier Requested',
              description: 'Looking for an available courier',
            ),
            _StatusStep(
              status: OrderStatus.driverEnRoute,
              label: 'Driver En Route',
              description: 'Driver is on the way to the store',
            ),
            _StatusStep(
              status: OrderStatus.pickedUp,
              label: 'Out for Delivery',
              description: 'Your order is on its way',
            ),
            _StatusStep(
              status: OrderStatus.delivered,
              label: 'Delivered',
              description: 'Order completed',
            ),
          ];

    // Find current step index
    int currentIndex = _findCurrentStepIndex(order.status, steps);

    // Check if order is in a terminal completed state (delivered)
    final isTerminalComplete = order.status == OrderStatus.delivered;

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        // When order is delivered, all steps including the last one should be complete
        final isComplete =
            index < currentIndex ||
            (isTerminalComplete && index == currentIndex);
        // Only show as "current" (with spinner) if not terminal complete
        final isCurrent = index == currentIndex && !isTerminalComplete;
        final isLast = index == steps.length - 1;

        return _buildStatusStep(
          step: step,
          isComplete: isComplete,
          isCurrent: isCurrent,
          isLast: isLast,
        );
      }),
    );
  }

  int _findCurrentStepIndex(OrderStatus status, List<_StatusStep> steps) {
    // Map statuses that might come from backend to their step equivalents
    OrderStatus normalizedStatus = status;

    // Handle status aliases
    if (status == OrderStatus.confirmed) {
      normalizedStatus = OrderStatus.accepted;
    } else if (status == OrderStatus.preparing) {
      normalizedStatus = OrderStatus.inKitchen;
    } else if (status == OrderStatus.outForDelivery) {
      normalizedStatus = OrderStatus.pickedUp;
    }

    for (int i = 0; i < steps.length; i++) {
      if (steps[i].status == normalizedStatus) {
        return i;
      }
    }

    // Default to first step if not found
    return 0;
  }

  Widget _buildStatusStep({
    required _StatusStep step,
    required bool isComplete,
    required bool isCurrent,
    required bool isLast,
  }) {
    final colors = context.colors;
    final Color textColor = isComplete || isCurrent
        ? colors.textPrimary
        : colors.textTertiary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isComplete
                    ? colors.success
                    : (isCurrent ? colors.info : colors.surfaceVariant),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isComplete
                    ? const Icon(
                        LucideIcons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : isCurrent
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        _getStepIcon(step.status),
                        color: colors.textTertiary,
                        size: 14,
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isComplete ? colors.success : colors.surfaceVariant,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontWeight: isComplete || isCurrent
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStepIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return LucideIcons.receipt;
      case OrderStatus.accepted:
      case OrderStatus.confirmed:
        return LucideIcons.thumbsUp;
      case OrderStatus.inKitchen:
      case OrderStatus.preparing:
        return LucideIcons.chefHat;
      case OrderStatus.ready:
        return LucideIcons.circleCheck;
      case OrderStatus.courierRequested:
        return LucideIcons.search;
      case OrderStatus.driverEnRoute:
        return LucideIcons.bike;
      case OrderStatus.pickedUp:
      case OrderStatus.outForDelivery:
        return LucideIcons.truck;
      case OrderStatus.delivered:
        return LucideIcons.circleCheck;
      default:
        return LucideIcons.circle;
    }
  }

  Widget _buildCourierTrackingCard(CourierTask courierTask) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.info,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.truck, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Live Tracking',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Live indicator dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.success.withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  courierTask.provider == CourierProvider.uber
                      ? 'Uber Direct'
                      : courierTask.provider == CourierProvider.doordash
                      ? 'DoorDash Drive'
                      : 'Courier',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _openTrackingUrl(courierTask.trackingUrl!),
            icon: const Icon(LucideIcons.externalLink, size: 16),
            label: const Text('Track'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTrackingUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open tracking link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCancelWindowCard(Order order) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.timer, color: colors.info),
              const SizedBox(width: 8),
              Text(
                'Cancel window: $countdownText',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCancelling
                      ? null
                      : () => _showCancelDialog(order),
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(LucideIcons.circleX, color: colors.error),
                  label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, color: colors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_error!, style: TextStyle(color: colors.error)),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, color: colors.error, size: 18),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              if (order.items != null && order.items!.isNotEmpty)
                ...order.items!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      _OrderItemTile(item: item),
                      if (index < order.items!.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                })
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.package,
                        color: context.colors.textTertiary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${order.itemsCount} item${order.itemsCount != 1 ? 's' : ''}',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFulfillmentInfo(Order order) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.isDelivery ? 'Delivery Address' : 'Pickup Location',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      order.isDelivery ? LucideIcons.mapPin : LucideIcons.store,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.isDelivery ? 'Delivery Address' : 'Pickup Location',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (order.isDelivery && order.deliveryAddress != null)
                  Text(
                    '${order.deliveryAddress!.streetLine1}'
                    '${order.deliveryAddress!.streetLine2 != null ? ', ${order.deliveryAddress!.streetLine2}' : ''}\n'
                    '${order.deliveryAddress!.city}, ${order.deliveryAddress!.state} ${order.deliveryAddress!.postalCode}',
                    style: TextStyle(color: colors.textSecondary),
                  )
                else if (order.isPickup)
                  Text(
                    'Shahirizada Fresh Market\n3124 Illinois Rte 59 Suite 154\nNaperville, IL 60564',
                    style: TextStyle(color: colors.textSecondary),
                  )
                else
                  Text(
                    'Address not available',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                if (order.specialInstructions != null &&
                    order.specialInstructions!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.messageSquare,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.specialInstructions!,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(Order order) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.contactName != null) ...[
                  Row(
                    children: [
                      Icon(
                        LucideIcons.user,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(order.contactName!),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (order.contactEmail != null) ...[
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mail,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(order.contactEmail!),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (order.contactPhone != null)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.phone,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(order.contactPhone!),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PaymentRow(label: 'Subtotal', value: order.formattedSubtotal),
                const SizedBox(height: 8),
                if (order.taxCents > 0) ...[
                  _PaymentRow(label: 'Tax', value: order.formattedTax),
                  const SizedBox(height: 8),
                ],
                if (order.isDelivery)
                  _PaymentRow(
                    label: 'Delivery',
                    value: order.deliveryFeeCents > 0
                        ? '\$${order.deliveryFeeInDollars.toStringAsFixed(2)}'
                        : 'FREE',
                    valueColor: order.deliveryFeeCents == 0
                        ? AppTheme.successColor
                        : null,
                  ),
                if (order.tipCents > 0) ...[
                  const SizedBox(height: 8),
                  _PaymentRow(
                    label: 'Tip',
                    value: '\$${order.tipInDollars.toStringAsFixed(2)}',
                  ),
                ],
                if (order.discountCents > 0) ...[
                  const SizedBox(height: 8),
                  _PaymentRow(
                    label: 'Discount',
                    value: '-\$${order.discountInDollars.toStringAsFixed(2)}',
                    valueColor: AppTheme.successColor,
                  ),
                ],
                const Divider(height: 24),
                _PaymentRow(
                  label: 'Total',
                  value: order.formattedTotal,
                  isBold: true,
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final colors = context.colors;
                    return Row(
                      children: [
                        Icon(
                          order.paymentStatus == PaymentStatus.paid
                              ? LucideIcons.circleCheck
                              : LucideIcons.creditCard,
                          color: order.paymentStatus == PaymentStatus.paid
                              ? colors.success
                              : colors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.paymentStatus == PaymentStatus.paid
                              ? 'Paid'
                              : order.paymentStatus.name.toUpperCase(),
                          style: TextStyle(
                            color: order.paymentStatus == PaymentStatus.paid
                                ? colors.success
                                : colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Order order) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement reorder functionality
            },
            icon: Icon(LucideIcons.repeat),
            label: const Text('Reorder'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => _showHelpDialog(order),
            child: const Text('Need help? Contact Support'),
          ),
        ),
      ],
    );
  }

  /// Show help dialog with call/email options (matching web AccountOrderDetail)
  void _showHelpDialog(Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dialogColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.headset, color: dialogColors.primary),
              ),
              const SizedBox(width: 12),
              const Text('Need Help?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact $_storeName for assistance with your order #${order.orderNumberDisplay}.',
                style: TextStyle(color: dialogColors.textSecondary),
              ),
              const SizedBox(height: 16),
              // Call button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _callSupport();
                  },
                  icon: const Icon(LucideIcons.phone),
                  label: Text('Call $_storePhone'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Email button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _emailSupport(order);
                  },
                  icon: const Icon(LucideIcons.mail),
                  label: const Text('Send Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _callSupport() async {
    // Remove non-numeric characters except + for tel: URI
    final phoneNumber = _storePhone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _emailSupport(Order order) async {
    final subject = Uri.encodeComponent(
      'Help with Order #${order.orderNumberDisplay}',
    );
    final body = Uri.encodeComponent(
      'Hi,\n\n'
      'I need help with my order.\n\n'
      'Order Number: ${order.orderNumberDisplay}\n'
      'Order ID: ${order.id}\n'
      'Order Status: ${order.status.label}\n'
      'Order Total: ${order.formattedTotal}\n\n'
      'Please describe your issue here:\n\n',
    );
    final uri = Uri.parse('mailto:$_storeEmail?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.day == now.day && dt.month == now.month && dt.year == now.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');

    if (isToday) {
      return '$hour:$minute $period';
    }
    return '${dt.month}/${dt.day} at $hour:$minute $period';
  }
}

/// Status step model for linear tracker (matching web StatusTracker)
class _StatusStep {
  final OrderStatus status;
  final String label;
  final String description;

  const _StatusStep({
    required this.status,
    required this.label,
    required this.description,
  });
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(LucideIcons.image, color: colors.textTertiary),
                    ),
                  )
                : Icon(LucideIcons.image, color: colors.textTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  item.formattedQuantity,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            item.formattedTotal,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? (isBold ? colors.primary : null),
          ),
        ),
      ],
    );
  }
}
