import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:motor/motor.dart';
import 'package:toastification/toastification.dart';

/// Modern minimal toast service with glassmorphism design
/// Inspired by iOS toast patterns with warm Shahirizada brand accents
class AppToast {
  AppToast._();

  /// Show a success toast (e.g., item added to cart)
  static ToastificationItem showSuccess({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return _show(
      context: context,
      type: _ToastType.success,
      title: title,
      description: description,
      duration: duration,
      icon: LucideIcons.check,
      onTap: onTap,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show an error toast
  static ToastificationItem showError({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _show(
      context: context,
      type: _ToastType.error,
      title: title,
      description: description,
      duration: duration,
      icon: LucideIcons.x,
    );
  }

  /// Show an info toast
  static ToastificationItem showInfo({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 2),
  }) {
    return _show(
      context: context,
      type: _ToastType.info,
      title: title,
      description: description,
      duration: duration,
      icon: LucideIcons.info,
    );
  }

  /// Show a warning toast
  static ToastificationItem showWarning({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _show(
      context: context,
      type: _ToastType.warning,
      title: title,
      description: description,
      duration: duration,
      icon: LucideIcons.triangleAlert,
    );
  }

  /// Show cart added toast with action
  static ToastificationItem showCartAdded({
    required BuildContext context,
    required String itemName,
    required double quantity,
    required VoidCallback onViewCart,
    bool isWeightBased = false,
    String? unitLabel,
  }) {
    final formattedQty = quantity == quantity.truncate()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);

    final message = isWeightBased && unitLabel != null
        ? '$formattedQty $unitLabel added'
        : '${formattedQty}x $itemName added';

    return showSuccess(
      context: context,
      title: message,
      actionLabel: 'View Cart',
      onAction: onViewCart,
    );
  }

  /// Internal show method
  static ToastificationItem _show({
    required BuildContext context,
    required _ToastType type,
    required String title,
    String? description,
    required Duration duration,
    required IconData icon,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Dismiss any existing toasts first
    toastification.dismissAll();

    return toastification.showCustom(
      context: context,
      autoCloseDuration: duration,
      alignment: Alignment.bottomCenter,
      animationDuration: const Duration(milliseconds: 350),
      animationBuilder: _springAnimationBuilder,
      builder: (context, holder) {
        return _MinimalToast(
          holder: holder,
          type: type,
          title: title,
          description: description,
          icon: icon,
          onTap: onTap,
          actionLabel: actionLabel,
          onAction: onAction,
        );
      },
    );
  }

  /// Spring-based animation for natural feel
  static Widget _springAnimationBuilder(
    BuildContext context,
    Animation<double> animation,
    Alignment alignment,
    Widget child,
  ) {
    return _SpringAnimatedToast(animation: animation, child: child);
  }
}

/// Toast type enum for internal use
enum _ToastType { success, error, warning, info }

/// Spring-powered animated toast wrapper
class _SpringAnimatedToast extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _SpringAnimatedToast({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;

        // Subtle scale with bounce
        final scale = 0.92 + (0.08 * value);

        // Slide up from bottom
        final translateY = 24 * (1 - value);

        // Fade in
        final opacity = value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: Opacity(opacity: opacity, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

/// Minimal glassmorphic toast widget
class _MinimalToast extends StatefulWidget {
  final ToastificationItem holder;
  final _ToastType type;
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MinimalToast({
    required this.holder,
    required this.type,
    required this.title,
    this.description,
    required this.icon,
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_MinimalToast> createState() => _MinimalToastState();
}

class _MinimalToastState extends State<_MinimalToast>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  double _dragOffsetX = 0;
  double _dragOffsetY = 0;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.holder.autoCloseDuration ?? const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // Minimal color palette - warm neutrals with subtle accent hints
  Color get _accentColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.type) {
      case _ToastType.success:
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
      case _ToastType.error:
        return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      case _ToastType.warning:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      case _ToastType.info:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    }
  }

  Color get _backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.9);
  }

  Color get _textColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : const Color(0xFF1A1A1A);
  }

  Color get _secondaryTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
  }

  Color get _borderColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffsetX += details.delta.dx;
      _dragOffsetY += details.delta.dy;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocityX = details.velocity.pixelsPerSecond.dx.abs();
    final velocityY = details.velocity.pixelsPerSecond.dy.abs();

    final shouldDismissX = _dragOffsetX.abs() > 60 || velocityX > 400;
    final shouldDismissY = _dragOffsetY > 40 || velocityY > 300;

    if (shouldDismissX || shouldDismissY) {
      toastification.dismiss(widget.holder);
    } else {
      setState(() {
        _dragOffsetX = 0;
        _dragOffsetY = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dragDistance = (_dragOffsetX.abs() + _dragOffsetY.abs()) / 2;
    final dragOpacity = (1.0 - (dragDistance / 100)).clamp(0.4, 1.0);

    // Use Align to position the toast and let the rest of the area pass through taps
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: SingleMotionBuilder(
            motion: CupertinoMotion.bouncy(),
            value: _isPressed ? 0.98 : 1.0,
            builder: (context, scale, child) {
              return MotionBuilder(
                motion: CupertinoMotion.snappy(),
                value: Offset(_dragOffsetX, _dragOffsetY),
                converter: const OffsetMotionConverter(),
                builder: (context, offset, child) {
                  return Transform.translate(
                    offset: offset,
                    child: Opacity(
                      opacity: dragOpacity,
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        child: Row(
                          children: [
                            // Minimal icon with accent color
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                widget.icon,
                                color: _accentColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.description != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.description!,
                                      style: TextStyle(
                                        color: _secondaryTextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Action button or close
                            if (widget.actionLabel != null &&
                                widget.onAction != null)
                              _buildActionButton()
                            else
                              _buildCloseButton(),
                          ],
                        ),
                      ),

                      // Subtle progress bar
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            height: 2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(14),
                              ),
                              color: _accentColor.withValues(alpha: 0.1),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 1 - _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _accentColor.withValues(alpha: 0.4),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: () {
        widget.onAction?.call();
        toastification.dismiss(widget.holder);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.actionLabel!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => toastification.dismiss(widget.holder),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(LucideIcons.x, color: _secondaryTextColor, size: 18),
      ),
    );
  }
}
