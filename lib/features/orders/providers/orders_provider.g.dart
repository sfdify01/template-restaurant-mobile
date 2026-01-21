// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersHash() => r'5bce8a745cd1ddb3c56432b5f0d8840cae27af84';

/// Fetch orders for the current user
///
/// Copied from [orders].
@ProviderFor(orders)
final ordersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  orders,
  name: r'ordersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$guestOrdersHash() => r'6dc94fe3a403f7b30bf46add6fe20ce56df0ed56';

/// Fetch orders for guest users (local + customer lookup)
///
/// Copied from [guestOrders].
@ProviderFor(guestOrders)
final guestOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  guestOrders,
  name: r'guestOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$guestOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GuestOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$guestActiveOrdersHash() => r'e8e6082e2a05ec73810a065142a5c943e7026b8d';

/// See also [guestActiveOrders].
@ProviderFor(guestActiveOrders)
final guestActiveOrdersProvider =
    AutoDisposeFutureProvider<List<Order>>.internal(
      guestActiveOrders,
      name: r'guestActiveOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$guestActiveOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GuestActiveOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$guestPastOrdersHash() => r'7f8c348bca6ce8b271fd1100ab91b769cdfc757f';

/// See also [guestPastOrders].
@ProviderFor(guestPastOrders)
final guestPastOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  guestPastOrders,
  name: r'guestPastOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$guestPastOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GuestPastOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$activeOrdersHash() => r'7a7f39028b2ec47e258e1842bdfc4e26173f412b';

/// Fetch active orders (not completed or cancelled)
///
/// Copied from [activeOrders].
@ProviderFor(activeOrders)
final activeOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  activeOrders,
  name: r'activeOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$pastOrdersHash() => r'5845264016e246de6cfa0376aea5d7933d002131';

/// Fetch past orders (completed or cancelled)
///
/// Copied from [pastOrders].
@ProviderFor(pastOrders)
final pastOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  pastOrders,
  name: r'pastOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pastOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PastOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$orderHash() => r'53d33ad39171fb1d063e45d20f1206ca912ec1ed';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetch a single order by ID
///
/// First checks local guest order storage (like web's localStorage),
/// then falls back to Supabase for authenticated users.
///
/// Copied from [order].
@ProviderFor(order)
const orderProvider = OrderFamily();

/// Fetch a single order by ID
///
/// First checks local guest order storage (like web's localStorage),
/// then falls back to Supabase for authenticated users.
///
/// Copied from [order].
class OrderFamily extends Family<AsyncValue<Order?>> {
  /// Fetch a single order by ID
  ///
  /// First checks local guest order storage (like web's localStorage),
  /// then falls back to Supabase for authenticated users.
  ///
  /// Copied from [order].
  const OrderFamily();

  /// Fetch a single order by ID
  ///
  /// First checks local guest order storage (like web's localStorage),
  /// then falls back to Supabase for authenticated users.
  ///
  /// Copied from [order].
  OrderProvider call(String orderId) {
    return OrderProvider(orderId);
  }

  @override
  OrderProvider getProviderOverride(covariant OrderProvider provider) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderProvider';
}

/// Fetch a single order by ID
///
/// First checks local guest order storage (like web's localStorage),
/// then falls back to Supabase for authenticated users.
///
/// Copied from [order].
class OrderProvider extends AutoDisposeFutureProvider<Order?> {
  /// Fetch a single order by ID
  ///
  /// First checks local guest order storage (like web's localStorage),
  /// then falls back to Supabase for authenticated users.
  ///
  /// Copied from [order].
  OrderProvider(String orderId)
    : this._internal(
        (ref) => order(ref as OrderRef, orderId),
        from: orderProvider,
        name: r'orderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderHash,
        dependencies: OrderFamily._dependencies,
        allTransitiveDependencies: OrderFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(FutureOr<Order?> Function(OrderRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: OrderProvider._internal(
        (ref) => create(ref as OrderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Order?> createElement() {
    return _OrderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderRef on AutoDisposeFutureProviderRef<Order?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderProviderElement extends AutoDisposeFutureProviderElement<Order?>
    with OrderRef {
  _OrderProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderProvider).orderId;
}

String _$orderStreamHash() => r'bf3861483ee05aefdbfb9833b06557099677b2a2';

/// Stream order updates for real-time tracking
///
/// Copied from [orderStream].
@ProviderFor(orderStream)
const orderStreamProvider = OrderStreamFamily();

/// Stream order updates for real-time tracking
///
/// Copied from [orderStream].
class OrderStreamFamily extends Family<AsyncValue<Order?>> {
  /// Stream order updates for real-time tracking
  ///
  /// Copied from [orderStream].
  const OrderStreamFamily();

  /// Stream order updates for real-time tracking
  ///
  /// Copied from [orderStream].
  OrderStreamProvider call(String orderId) {
    return OrderStreamProvider(orderId);
  }

  @override
  OrderStreamProvider getProviderOverride(
    covariant OrderStreamProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderStreamProvider';
}

/// Stream order updates for real-time tracking
///
/// Copied from [orderStream].
class OrderStreamProvider extends AutoDisposeStreamProvider<Order?> {
  /// Stream order updates for real-time tracking
  ///
  /// Copied from [orderStream].
  OrderStreamProvider(String orderId)
    : this._internal(
        (ref) => orderStream(ref as OrderStreamRef, orderId),
        from: orderStreamProvider,
        name: r'orderStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderStreamHash,
        dependencies: OrderStreamFamily._dependencies,
        allTransitiveDependencies: OrderStreamFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    Stream<Order?> Function(OrderStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderStreamProvider._internal(
        (ref) => create(ref as OrderStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Order?> createElement() {
    return _OrderStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderStreamProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderStreamRef on AutoDisposeStreamProviderRef<Order?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderStreamProviderElement
    extends AutoDisposeStreamProviderElement<Order?>
    with OrderStreamRef {
  _OrderStreamProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderStreamProvider).orderId;
}

String _$orderCourierTaskHash() => r'f8dad50648d4b550768011ba6fe9564f1aa7e64b';

/// Fetch courier task for an order
///
/// Copied from [orderCourierTask].
@ProviderFor(orderCourierTask)
const orderCourierTaskProvider = OrderCourierTaskFamily();

/// Fetch courier task for an order
///
/// Copied from [orderCourierTask].
class OrderCourierTaskFamily extends Family<AsyncValue<CourierTask?>> {
  /// Fetch courier task for an order
  ///
  /// Copied from [orderCourierTask].
  const OrderCourierTaskFamily();

  /// Fetch courier task for an order
  ///
  /// Copied from [orderCourierTask].
  OrderCourierTaskProvider call(String orderId) {
    return OrderCourierTaskProvider(orderId);
  }

  @override
  OrderCourierTaskProvider getProviderOverride(
    covariant OrderCourierTaskProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderCourierTaskProvider';
}

/// Fetch courier task for an order
///
/// Copied from [orderCourierTask].
class OrderCourierTaskProvider extends AutoDisposeFutureProvider<CourierTask?> {
  /// Fetch courier task for an order
  ///
  /// Copied from [orderCourierTask].
  OrderCourierTaskProvider(String orderId)
    : this._internal(
        (ref) => orderCourierTask(ref as OrderCourierTaskRef, orderId),
        from: orderCourierTaskProvider,
        name: r'orderCourierTaskProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderCourierTaskHash,
        dependencies: OrderCourierTaskFamily._dependencies,
        allTransitiveDependencies:
            OrderCourierTaskFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderCourierTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    FutureOr<CourierTask?> Function(OrderCourierTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderCourierTaskProvider._internal(
        (ref) => create(ref as OrderCourierTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CourierTask?> createElement() {
    return _OrderCourierTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderCourierTaskProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderCourierTaskRef on AutoDisposeFutureProviderRef<CourierTask?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderCourierTaskProviderElement
    extends AutoDisposeFutureProviderElement<CourierTask?>
    with OrderCourierTaskRef {
  _OrderCourierTaskProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderCourierTaskProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
