import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Auth screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

// Home screens
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

// Product screens
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/category_products_screen.dart';

// Cart screens
import '../../features/cart/presentation/screens/cart_screen.dart';

// Checkout screens
import '../../features/checkout/presentation/screens/checkout_screen.dart';

// Order screens
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_confirmation_screen.dart';

// Profile screens
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
import '../../features/profile/presentation/screens/help_center_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';

// Loyalty screens
import '../../features/loyalty/presentation/screens/loyalty_screen.dart';

part 'app_router.gr.dart';

/// Main router configuration for the app
/// Uses auto_route v9 with declarative routing
@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Splash & Auth
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),

    // Order confirmation (outside shell - full screen experience)
    AutoRoute(page: OrderConfirmationRoute.page),

    // Main App Shell with bottom navigation
    AutoRoute(
      page: MainShellRoute.page,
      children: [
        AutoRoute(
          page: HomeTab.page,
          children: [
            AutoRoute(page: HomeRoute.page, initial: true),
            AutoRoute(page: ProductDetailRoute.page),
            AutoRoute(page: CategoryProductsRoute.page),
          ],
        ),
        AutoRoute(
          page: CartTab.page,
          children: [
            AutoRoute(page: CartRoute.page, initial: true),
            AutoRoute(page: CheckoutRoute.page),
          ],
        ),
        AutoRoute(
          page: OrdersTab.page,
          children: [
            AutoRoute(page: OrdersRoute.page, initial: true),
            AutoRoute(page: OrderDetailRoute.page),
          ],
        ),
        AutoRoute(
          page: ProfileTab.page,
          children: [
            AutoRoute(page: ProfileRoute.page, initial: true),
            AutoRoute(page: EditProfileRoute.page),
            AutoRoute(page: AddressesRoute.page),
            AutoRoute(page: LoyaltyRoute.page),
            AutoRoute(page: HelpCenterRoute.page),
            AutoRoute(page: AboutRoute.page),
            AutoRoute(page: PrivacyPolicyRoute.page),
          ],
        ),
      ],
    ),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    // Add auth guard here later
  ];
}

// Tab route wrappers for nested navigation
@RoutePage(name: 'HomeTab')
class HomeTabPage extends AutoRouter {
  const HomeTabPage({super.key});
}

@RoutePage(name: 'CartTab')
class CartTabPage extends AutoRouter {
  const CartTabPage({super.key});
}

@RoutePage(name: 'OrdersTab')
class OrdersTabPage extends AutoRouter {
  const OrdersTabPage({super.key});
}

@RoutePage(name: 'ProfileTab')
class ProfileTabPage extends AutoRouter {
  const ProfileTabPage({super.key});
}
