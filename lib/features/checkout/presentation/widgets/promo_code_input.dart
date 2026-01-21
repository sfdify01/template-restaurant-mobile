import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/toast_service.dart';
import '../../providers/checkout_provider.dart';

class PromoCodeInput extends ConsumerStatefulWidget {
  const PromoCodeInput({super.key});

  @override
  ConsumerState<PromoCodeInput> createState() => _PromoCodeInputState();
}

class _PromoCodeInputState extends ConsumerState<PromoCodeInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppToast.showWarning(
        context: context,
        title: 'Please enter a promo code',
      );
      return;
    }

    setState(() => _isLoading = true);
    _focusNode.unfocus();

    try {
      await ref.read(checkoutProvider.notifier).validatePromo(code);

      // Check the result
      final state = ref.read(checkoutProvider);

      if (state.hasPromo) {
        // Success!
        AppToast.showSuccess(
          context: context,
          title: 'Promo applied!',
          description: 'You save \$${(state.promoDiscountCents / 100).toStringAsFixed(2)}',
        );
      } else if (state.error != null) {
        // Error from validation
        AppToast.showError(
          context: context,
          title: state.error!,
        );
      }
    } catch (e) {
      AppToast.showError(
        context: context,
        title: 'Failed to validate promo code',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearPromo() {
    ref.read(checkoutProvider.notifier).clearPromo();
    _controller.clear();
    AppToast.showInfo(
      context: context,
      title: 'Promo code removed',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final hasPromo = state.hasPromo;
    final colors = context.colors;
    final isDark = context.isDark;

    // Applied promo state
    if (hasPromo) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.successColor.withValues(alpha: 0.15),
                    AppTheme.successColor.withValues(alpha: 0.08),
                  ]
                : [
                    AppTheme.successLight,
                    AppTheme.successLight.withValues(alpha: 0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.successColor.withValues(alpha: isDark ? 0.3 : 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.badgeCheck,
                color: AppTheme.successColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            // Promo details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          state.promoCode ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '-\$${(state.promoDiscountCents / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  if (state.promoDescription != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      state.promoDescription!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Remove button
            GestureDetector(
              onTap: _clearPromo,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.textTertiary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.x,
                  size: 14,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Input state
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Tag icon
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              LucideIcons.tag,
              size: 18,
              color: colors.textTertiary,
            ),
          ),
          // Input field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.textTertiary,
                  letterSpacing: 0,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _applyPromo(),
            ),
          ),
          // Apply button
          Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              color: _isLoading
                  ? colors.primary.withValues(alpha: 0.6)
                  : colors.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _isLoading ? null : _applyPromo,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 36,
                  width: 70,
                  alignment: Alignment.center,
                  child: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        )
                      : Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
