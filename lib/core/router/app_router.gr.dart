// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AboutScreen]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute({List<PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutScreen();
    },
  );
}

/// generated route for
/// [AddressesScreen]
class AddressesRoute extends PageRouteInfo<void> {
  const AddressesRoute({List<PageRouteInfo>? children})
    : super(AddressesRoute.name, initialChildren: children);

  static const String name = 'AddressesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddressesScreen();
    },
  );
}

/// generated route for
/// [CartScreen]
class CartRoute extends PageRouteInfo<void> {
  const CartRoute({List<PageRouteInfo>? children})
    : super(CartRoute.name, initialChildren: children);

  static const String name = 'CartRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CartScreen();
    },
  );
}

/// generated route for
/// [CartTabPage]
class CartTab extends PageRouteInfo<void> {
  const CartTab({List<PageRouteInfo>? children})
    : super(CartTab.name, initialChildren: children);

  static const String name = 'CartTab';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CartTabPage();
    },
  );
}

/// generated route for
/// [CategoryProductsScreen]
class CategoryProductsRoute extends PageRouteInfo<CategoryProductsRouteArgs> {
  CategoryProductsRoute({
    Key? key,
    required String categoryId,
    String? categoryName,
    List<PageRouteInfo>? children,
  }) : super(
         CategoryProductsRoute.name,
         args: CategoryProductsRouteArgs(
           key: key,
           categoryId: categoryId,
           categoryName: categoryName,
         ),
         rawPathParams: {'id': categoryId},
         rawQueryParams: {'name': categoryName},
         initialChildren: children,
       );

  static const String name = 'CategoryProductsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<CategoryProductsRouteArgs>(
        orElse: () => CategoryProductsRouteArgs(
          categoryId: pathParams.getString('id'),
          categoryName: queryParams.optString('name'),
        ),
      );
      return CategoryProductsScreen(
        key: args.key,
        categoryId: args.categoryId,
        categoryName: args.categoryName,
      );
    },
  );
}

class CategoryProductsRouteArgs {
  const CategoryProductsRouteArgs({
    this.key,
    required this.categoryId,
    this.categoryName,
  });

  final Key? key;

  final String categoryId;

  final String? categoryName;

  @override
  String toString() {
    return 'CategoryProductsRouteArgs{key: $key, categoryId: $categoryId, categoryName: $categoryName}';
  }
}

/// generated route for
/// [CheckoutScreen]
class CheckoutRoute extends PageRouteInfo<void> {
  const CheckoutRoute({List<PageRouteInfo>? children})
    : super(CheckoutRoute.name, initialChildren: children);

  static const String name = 'CheckoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CheckoutScreen();
    },
  );
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfileScreen();
    },
  );
}

/// generated route for
/// [HelpCenterScreen]
class HelpCenterRoute extends PageRouteInfo<void> {
  const HelpCenterRoute({List<PageRouteInfo>? children})
    : super(HelpCenterRoute.name, initialChildren: children);

  static const String name = 'HelpCenterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HelpCenterScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [HomeTabPage]
class HomeTab extends PageRouteInfo<void> {
  const HomeTab({List<PageRouteInfo>? children})
    : super(HomeTab.name, initialChildren: children);

  static const String name = 'HomeTab';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeTabPage();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [LoyaltyScreen]
class LoyaltyRoute extends PageRouteInfo<void> {
  const LoyaltyRoute({List<PageRouteInfo>? children})
    : super(LoyaltyRoute.name, initialChildren: children);

  static const String name = 'LoyaltyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoyaltyScreen();
    },
  );
}

/// generated route for
/// [MainShellScreen]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellScreen();
    },
  );
}

/// generated route for
/// [OrderConfirmationScreen]
class OrderConfirmationRoute extends PageRouteInfo<OrderConfirmationRouteArgs> {
  OrderConfirmationRoute({
    Key? key,
    required String orderId,
    String? orderNumber,
    String? pickupCode,
    required String fulfillmentType,
    required int totalCents,
    int? starsEarned,
    int? newStarBalance,
    required DateTime orderCreatedAt,
    String? customerPhone,
    String? customerEmail,
    List<PageRouteInfo>? children,
  }) : super(
         OrderConfirmationRoute.name,
         args: OrderConfirmationRouteArgs(
           key: key,
           orderId: orderId,
           orderNumber: orderNumber,
           pickupCode: pickupCode,
           fulfillmentType: fulfillmentType,
           totalCents: totalCents,
           starsEarned: starsEarned,
           newStarBalance: newStarBalance,
           orderCreatedAt: orderCreatedAt,
           customerPhone: customerPhone,
           customerEmail: customerEmail,
         ),
         initialChildren: children,
       );

  static const String name = 'OrderConfirmationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OrderConfirmationRouteArgs>();
      return OrderConfirmationScreen(
        key: args.key,
        orderId: args.orderId,
        orderNumber: args.orderNumber,
        pickupCode: args.pickupCode,
        fulfillmentType: args.fulfillmentType,
        totalCents: args.totalCents,
        starsEarned: args.starsEarned,
        newStarBalance: args.newStarBalance,
        orderCreatedAt: args.orderCreatedAt,
        customerPhone: args.customerPhone,
        customerEmail: args.customerEmail,
      );
    },
  );
}

class OrderConfirmationRouteArgs {
  const OrderConfirmationRouteArgs({
    this.key,
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

  final Key? key;

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

  @override
  String toString() {
    return 'OrderConfirmationRouteArgs{key: $key, orderId: $orderId, orderNumber: $orderNumber, pickupCode: $pickupCode, fulfillmentType: $fulfillmentType, totalCents: $totalCents, starsEarned: $starsEarned, newStarBalance: $newStarBalance, orderCreatedAt: $orderCreatedAt, customerPhone: $customerPhone, customerEmail: $customerEmail}';
  }
}

/// generated route for
/// [OrderDetailScreen]
class OrderDetailRoute extends PageRouteInfo<OrderDetailRouteArgs> {
  OrderDetailRoute({
    Key? key,
    required String orderId,
    List<PageRouteInfo>? children,
  }) : super(
         OrderDetailRoute.name,
         args: OrderDetailRouteArgs(key: key, orderId: orderId),
         rawPathParams: {'id': orderId},
         initialChildren: children,
       );

  static const String name = 'OrderDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrderDetailRouteArgs>(
        orElse: () => OrderDetailRouteArgs(orderId: pathParams.getString('id')),
      );
      return OrderDetailScreen(key: args.key, orderId: args.orderId);
    },
  );
}

class OrderDetailRouteArgs {
  const OrderDetailRouteArgs({this.key, required this.orderId});

  final Key? key;

  final String orderId;

  @override
  String toString() {
    return 'OrderDetailRouteArgs{key: $key, orderId: $orderId}';
  }
}

/// generated route for
/// [OrdersScreen]
class OrdersRoute extends PageRouteInfo<void> {
  const OrdersRoute({List<PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersScreen();
    },
  );
}

/// generated route for
/// [OrdersTabPage]
class OrdersTab extends PageRouteInfo<void> {
  const OrdersTab({List<PageRouteInfo>? children})
    : super(OrdersTab.name, initialChildren: children);

  static const String name = 'OrdersTab';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersTabPage();
    },
  );
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyScreen();
    },
  );
}

/// generated route for
/// [ProductDetailScreen]
class ProductDetailRoute extends PageRouteInfo<ProductDetailRouteArgs> {
  ProductDetailRoute({
    Key? key,
    required String productId,
    List<PageRouteInfo>? children,
  }) : super(
         ProductDetailRoute.name,
         args: ProductDetailRouteArgs(key: key, productId: productId),
         rawPathParams: {'id': productId},
         initialChildren: children,
       );

  static const String name = 'ProductDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProductDetailRouteArgs>(
        orElse: () =>
            ProductDetailRouteArgs(productId: pathParams.getString('id')),
      );
      return ProductDetailScreen(key: args.key, productId: args.productId);
    },
  );
}

class ProductDetailRouteArgs {
  const ProductDetailRouteArgs({this.key, required this.productId});

  final Key? key;

  final String productId;

  @override
  String toString() {
    return 'ProductDetailRouteArgs{key: $key, productId: $productId}';
  }
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [ProfileTabPage]
class ProfileTab extends PageRouteInfo<void> {
  const ProfileTab({List<PageRouteInfo>? children})
    : super(ProfileTab.name, initialChildren: children);

  static const String name = 'ProfileTab';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileTabPage();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}
