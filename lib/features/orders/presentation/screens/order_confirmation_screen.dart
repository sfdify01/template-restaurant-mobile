import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/market_api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/orders_provider.dart';

/// Order confirmation screen shown after successful checkout
/// Matches web Confirmation.tsx with:
/// - 3-minute edit window countdown
/// - Edit/Cancel buttons
/// - Loyalty stars earned display
/// - Pickup code for pickup orders
@RoutePage()
class OrderConfirmationScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String? orderNumber;
  final String? pickupCode;
  final String fulfillmentType;
  final int totalCents;
  final int? starsEarned;
  final int? newStarBalance;
  final DateTime orderCreatedAt;
  final String? customerPhone;
  final String? customerEmail;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    this.orderNumber,
    this.pickupCode,
    required this.fulfillmentType,
    required this.totalCents,
    this.starsEarned,
    this.newStarBalance,
    required this.orderCreatedAt,
    this.customerPhone,
    this.customerEmail,
  });

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isCancelling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final remaining = calculateCancelWindowRemaining(widget.orderCreatedAt);
    setState(() {
      _remainingTime = remaining;
    });

    if (remaining <= Duration.zero) {
      _countdownTimer?.cancel();
    }
  }

  bool get canCancel => _remainingTime > Duration.zero;

  String get countdownText {
    if (_remainingTime <= Duration.zero) return 'Cancel window closed';
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelOrder() async {
    setState(() {
      _isCancelling = true;
      _error = null;
    });

    try {
      final api = MarketApiService.instance;

      // Use contact info passed from checkout, fall back to fetching if needed
      var customerPhone = widget.customerPhone;
      var customerEmail = widget.customerEmail;

      // Fallback: fetch order if contact info wasn't passed
      if (customerPhone == null && customerEmail == null) {
        final order = await ref.read(orderProvider(widget.orderId).future);
        customerPhone = order?.contactPhone;
        customerEmail = order?.contactEmail;
      }

      if (customerPhone == null && customerEmail == null) {
        throw Exception(
          'Missing customer phone/email for cancellation verification',
        );
      }

      await api.cancelOrder(
        orderId: widget.orderId,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        reason: 'Cancelled by customer within edit window',
      );

      if (!mounted) return;

      // Show success and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      context.router.replaceAll([const MainShellRoute()]);
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

  void _showCancelDialog() {
    final totalDollars = widget.totalCents / 100;
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
                _cancelOrder();
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
    final isPickup = widget.fulfillmentType == 'pickup';
    final totalDollars = widget.totalCents / 100;
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.circleCheck,
                  color: AppTheme.successColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Success message
              const Text(
                'Order Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for your order',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Order number
              if (widget.orderNumber != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Order Number',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                      Text(
                        '#${widget.orderNumber}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pickup code for pickup orders
              if (isPickup && widget.pickupCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.qrCode,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Pickup Code',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.pickupCode!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Show this code when picking up your order',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Loyalty stars earned
              if (widget.starsEarned != null && widget.starsEarned! > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.star,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You earned',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '+${widget.starsEarned} Stars',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.newStarBalance != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '${widget.newStarBalance}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Order total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Paid',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${totalDollars.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (!auth.isAuthenticated) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.infoBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save your order history',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.colors.info,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to manage orders and sync across devices.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.info,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.router.push(const LoginRoute());
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Cancel window countdown
              if (canCancel) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.infoBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.timer, color: context.colors.info),
                          const SizedBox(width: 8),
                          Text(
                            'Cancel window: $countdownText',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: context.colors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can cancel your order within this time',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.info,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isCancelling ? null : _showCancelDialog,
                    icon: _isCancelling
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            LucideIcons.circleX,
                            color: context.colors.error,
                          ),
                    label: Text(
                      _isCancelling ? 'Cancelling...' : 'Cancel Order',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.error,
                      side: BorderSide(color: context.colors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.errorBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.circleAlert,
                        color: context.colors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: context.colors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Track Order button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.router.replaceAll([
                      MainShellRoute(
                        children: [
                          OrdersTab(
                            children: [
                              const OrdersRoute(),
                              OrderDetailRoute(orderId: widget.orderId),
                            ],
                          ),
                        ],
                      ),
                    ]);
                  },
                  icon: const Icon(LucideIcons.truck),
                  label: const Text('Track Order'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Continue Shopping button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    context.router.replaceAll([const MainShellRoute()]);
                  },
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
