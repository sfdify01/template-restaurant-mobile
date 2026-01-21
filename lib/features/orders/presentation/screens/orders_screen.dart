import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../data/models/models.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/orders_provider.dart';

@RoutePage()
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // Guest experience: show stored/lookup orders with sign-in CTA
    if (!auth.isAuthenticated) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Orders'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viewing guest orders',
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to sync orders across devices and manage your account.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.router.push(const LoginRoute()),
                        child: const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _OrdersList(
                      ordersAsync: ref.watch(guestActiveOrdersProvider),
                      emptyMessage: 'No active orders',
                      emptySubtitle:
                          'Your recent guest orders will appear here',
                      showStartShopping: true,
                      onRefresh: () =>
                          ref.invalidate(guestOrdersProvider),
                    ),
                    _OrdersList(
                      ordersAsync: ref.watch(guestPastOrdersProvider),
                      emptyMessage: 'No past orders',
                      emptySubtitle:
                          'Your guest order history will appear here',
                      showStartShopping: true,
                      onRefresh: () =>
                          ref.invalidate(guestOrdersProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active orders tab
            _OrdersList(
              ordersAsync: ref.watch(activeOrdersProvider),
              emptyMessage: 'No active orders',
              emptySubtitle: 'Your current orders will appear here',
              showStartShopping: true,
              onRefresh: () => ref.invalidate(ordersProvider),
            ),
            // Past orders tab
            _OrdersList(
              ordersAsync: ref.watch(pastOrdersProvider),
              emptyMessage: 'No past orders',
              emptySubtitle: 'Your order history will appear here',
              showStartShopping: true,
              onRefresh: () => ref.invalidate(ordersProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final AsyncValue<List<Order>> ordersAsync;
  final String emptyMessage;
  final String emptySubtitle;
  final bool showStartShopping;
  final VoidCallback onRefresh;

  const _OrdersList({
    required this.ordersAsync,
    required this.emptyMessage,
    required this.emptySubtitle,
    this.showStartShopping = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.receipt, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(emptySubtitle, style: TextStyle(color: Colors.grey[600])),
                if (showStartShopping) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.tabsRouter.setActiveIndex(0),
                    child: const Text('Start Shopping'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(
                order: order,
                onTap: () {
                  context.router.push(OrderDetailRoute(orderId: order.id));
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.circleAlert, size: 48),
            const SizedBox(height: 16),
            Text(
              UserErrorMessage.from(
                e,
                fallback: 'Unable to load orders. Please try again.',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final itemsCount = order.items?.length ?? order.itemsCount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumberDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 12),

              // Date and delivery type
              Row(
                children: [
                  Icon(LucideIcons.calendar, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(order.createdAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    order.isDelivery ? LucideIcons.truck : LucideIcons.store,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.isDelivery ? 'Delivery' : 'Pickup',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count
              Row(
                children: [
                  Icon(
                    LucideIcons.shoppingBag,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$itemsCount ${itemsCount == 1 ? 'item' : 'items'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text(
                    order.formattedTotal,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              // Active order tracking hint
              if (!order.status.isTerminal) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        LucideIcons.radar,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tap to track your order',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        LucideIcons.chevronRight,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.draft:
      case OrderStatus.pending:
      case OrderStatus.submitted:
        return Colors.orange;
      case OrderStatus.created:
      case OrderStatus.accepted:
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
      case OrderStatus.inKitchen:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.courierRequested:
      case OrderStatus.driverEnRoute:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
      case OrderStatus.pickedUp:
        return AppTheme.successColor;
      case OrderStatus.rejected:
      case OrderStatus.canceled:
      case OrderStatus.failed:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
