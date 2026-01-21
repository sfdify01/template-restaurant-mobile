import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/providers/cart_provider.dart';

@RoutePage()
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartItemCountProvider);

    return AutoTabsScaffold(
      routes: const [HomeTab(), CartTab(), OrdersTab(), ProfileTab()],
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.house),
              activeIcon: Icon(LucideIcons.house),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(
                  cartItemCount > 99 ? '99+' : '$cartItemCount',
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: context.colors.error,
                isLabelVisible: cartItemCount > 0,
                child: const Icon(LucideIcons.shoppingCart),
              ),
              activeIcon: Badge(
                label: Text(
                  cartItemCount > 99 ? '99+' : '$cartItemCount',
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: context.colors.error,
                isLabelVisible: cartItemCount > 0,
                child: const Icon(LucideIcons.shoppingCart),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList),
              activeIcon: Icon(LucideIcons.clipboardList),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              activeIcon: Icon(LucideIcons.user),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
