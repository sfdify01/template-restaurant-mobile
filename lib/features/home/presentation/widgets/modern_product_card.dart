import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/models.dart';

/// Premium product card with elegant vertical layout
/// Refined butcher shop aesthetic - warm, inviting, premium
class ModernProductCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final void Function(double qty) onAddToCart;

  const ModernProductCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  State<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<ModernProductCard>
    with TickerProviderStateMixin {
  late double _quantity;
  late AnimationController _addButtonController;
  late AnimationController _quantityController;
  late Animation<double> _addButtonScale;
  late Animation<double> _quantityBounce;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.isWeightBased
        ? widget.item.priceUnit.minimumQty
        : 1.0;

    _addButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _addButtonScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _addButtonController, curve: Curves.easeOutCubic),
    );

    _quantityController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _quantityBounce = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _quantityController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _addButtonController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQty() {
    HapticFeedback.lightImpact();
    _quantityController.forward().then((_) => _quantityController.reverse());
    setState(() {
      if (widget.item.isWeightBased) {
        _quantity += widget.item.priceUnit.stepQty;
        _quantity = double.parse(_quantity.toStringAsFixed(2));
      } else if (_quantity < 99) {
        _quantity += 1;
      }
    });
  }

  void _decrementQty() {
    HapticFeedback.lightImpact();
    _quantityController.forward().then((_) => _quantityController.reverse());
    setState(() {
      if (widget.item.isWeightBased) {
        final minQty = widget.item.priceUnit.minimumQty;
        if (_quantity > minQty) {
          _quantity -= widget.item.priceUnit.stepQty;
          _quantity = double.parse(_quantity.toStringAsFixed(2));
        }
      } else if (_quantity > 1) {
        _quantity -= 1;
      }
    });
  }

  void _handleAddToCart() {
    HapticFeedback.mediumImpact();
    _addButtonController.forward().then((_) {
      _addButtonController.reverse();
    });
    widget.onAddToCart(_quantity);

    // Reset quantity to default
    setState(() {
      _quantity = widget.item.isWeightBased
          ? widget.item.priceUnit.minimumQty
          : 1.0;
    });
  }

  String get _formattedQty {
    if (widget.item.isWeightBased) {
      if (_quantity == _quantity.truncate()) {
        return _quantity.toInt().toString();
      }
      // Show up to 2 decimal places, trimming trailing zeros
      final formatted = _quantity.toStringAsFixed(2);
      if (formatted.endsWith('0')) {
        return _quantity.toStringAsFixed(1);
      }
      return formatted;
    }
    return _quantity.toInt().toString();
  }

  String get _unitLabel {
    if (widget.item.isWeightBased) {
      return widget.item.priceUnit.label;
    }
    return '';
  }

  bool get _canDecrement {
    if (widget.item.isWeightBased) {
      return _quantity > widget.item.priceUnit.minimumQty;
    }
    return _quantity > 1;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colors.primary;
    final isDark = context.isDark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.borderLight.withOpacity(0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: primaryColor.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with overlay badge
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: context.colors.surfaceVariant,
                      child: widget.item.imageUrl != null
                          ? Image.network(
                              widget.item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),

                  // Subtle bottom gradient for depth
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.08),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Popular badge
                  if (_isPopular)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.flame,
                              size: 11,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content section
            Expanded(
              flex: 13,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        height: 1.2,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Price display
                    Text(
                      widget.item.formattedPrice,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const Spacer(),

                    // Quantity selector row
                    _buildQuantitySelector(primaryColor),

                    const SizedBox(height: 8),

                    // Add to cart button - full width
                    _buildAddButton(primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Elegant quantity selector with pill-shaped stepper
  Widget _buildQuantitySelector(Color primaryColor) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.colors.borderLight.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Minus button
          _buildStepperButton(
            icon: LucideIcons.minus,
            onTap: _decrementQty,
            enabled: _canDecrement,
            isLeft: true,
          ),

          // Quantity display - center with unit
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _quantityBounce,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _quantityBounce.value,
                    child: child,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedQty,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_unitLabel.isNotEmpty) ...[
                      const SizedBox(width: 3),
                      Text(
                        _unitLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Plus button
          _buildStepperButton(
            icon: LucideIcons.plus,
            onTap: _incrementQty,
            enabled: _quantity < 99,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required bool isLeft,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(9) : Radius.zero,
          right: !isLeft ? const Radius.circular(9) : Radius.zero,
        ),
        child: Container(
          width: 40,
          height: double.infinity,
          alignment: Alignment.center,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: enabled ? context.colors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 14,
              color: enabled
                  ? context.colors.textPrimary
                  : context.colors.textTertiary.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  /// Full-width add button with satisfying press animation
  Widget _buildAddButton(Color primaryColor) {
    return ScaleTransition(
      scale: _addButtonScale,
      child: Material(
        color: primaryColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: _handleAddToCart,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          child: Container(
            height: 40,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    LucideIcons.plus,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: context.colors.surfaceVariant,
      child: Center(
        child: Icon(
          LucideIcons.beef,
          size: 36,
          color: context.colors.textTertiary.withOpacity(0.4),
        ),
      ),
    );
  }

  bool get _isPopular {
    final metadata = widget.item.metadata;
    if (metadata != null && metadata['popular'] == true) {
      return true;
    }
    return false;
  }
}
