import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/services/toast_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../data/models/models.dart';
import '../../../home/providers/menu_provider.dart';
import '../../../cart/providers/cart_provider.dart';

@RoutePage()
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    @PathParam('id') required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  double _quantity = 1.0;

  /// Format quantity for display: whole numbers show as int, decimals show appropriate precision
  String _formatQuantity(double qty) {
    if (qty == qty.truncate()) {
      return qty.toInt().toString();
    }
    // Show up to 2 decimal places, trimming trailing zeros
    final formatted = qty.toStringAsFixed(2);
    if (formatted.endsWith('0')) {
      return qty.toStringAsFixed(1);
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(menuItemProvider(widget.productId));

    return productAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Product not found')),
          );
        }
        return _buildProductDetail(context, item);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.circleAlert, size: 48),
              const SizedBox(height: 16),
              Text(
                UserErrorMessage.from(
                  e,
                  fallback: 'Unable to load product. Please try again.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(menuItemProvider(widget.productId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetail(BuildContext context, MenuItem item) {
    final isWeightBased = item.isWeightBased;
    final step = item.priceUnit.step;
    final minQty = item.priceUnit.minimum;
    final unitLabel = item.priceUnit.quantitySuffix;
    final total = item.priceInDollars * _quantity;
    final colors = context.colors;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colors.surfaceVariant,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colors.surfaceVariant,
                        child: Icon(
                          LucideIcons.image,
                          size: 100,
                          color: colors.textTertiary,
                        ),
                      ),
                    )
                  : Container(
                      color: colors.surfaceVariant,
                      child: Icon(
                        LucideIcons.image,
                        size: 100,
                        color: colors.textTertiary,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (item.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category!,
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Product name
                  Text(item.name, style: context.textTheme.displaySmall),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item.formattedPrice,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (item.description != null) ...[
                    Text('Description', style: context.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Dietary tags
                  if (item.dietaryTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.dietaryTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: colors.surfaceVariant,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quantity selector
                  Text(
                    isWeightBased ? 'Quantity ($unitLabel)' : 'Quantity',
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  // Quick quantity buttons for weight-based items
                  if (isWeightBased) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            minQty,
                            minQty * 2,
                            minQty * 3,
                            minQty * 4,
                            minQty * 5,
                            minQty * 6,
                          ].map((qty) {
                            final isSelected = _quantity == qty;
                            return GestureDetector(
                              onTap: () => setState(() => _quantity = qty),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: colors.primary.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                ),
                                child: Text(
                                  '${_formatQuantity(qty)} $unitLabel',
                                  style: TextStyle(
                                    color: isSelected
                                        ? context.colorScheme.onPrimary
                                        : colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Manual quantity selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(
                          icon: LucideIcons.minus,
                          onPressed: () {
                            if (_quantity > minQty) {
                              setState(() => _quantity -= step);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            isWeightBased
                                ? '${_formatQuantity(_quantity)} $unitLabel'
                                : _quantity.toInt().toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: LucideIcons.plus,
                          onPressed: () {
                            setState(() => _quantity += step);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Use the factory constructor to create cart item from menu item
                    final cartItem = CartItem.fromMenuItem(
                      item,
                      qty: _quantity,
                    );
                    ref.read(cartProvider.notifier).addItem(cartItem);

                    AppToast.showCartAdded(
                      context: context,
                      itemName: item.name,
                      quantity: _quantity,
                      isWeightBased: isWeightBased,
                      unitLabel: unitLabel,
                      onViewCart: () {
                        context.router.maybePop();
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.shoppingCart),
                        SizedBox(width: 8),
                        Text('Add to Cart'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colors.primary),
      ),
    );
  }
}
