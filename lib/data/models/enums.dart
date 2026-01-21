import 'package:dart_mappable/dart_mappable.dart';

part 'enums.mapper.dart';

/// Fulfillment type for orders
@MappableEnum()
enum FulfillmentType {
  @MappableValue('pickup')
  pickup,
  @MappableValue('delivery')
  delivery,
}

/// Order status tracking
@MappableEnum()
enum OrderStatus {
  @MappableValue('draft')
  draft,
  @MappableValue('pending')
  pending,
  @MappableValue('submitted')
  submitted,
  @MappableValue('created')
  created,
  @MappableValue('accepted')
  accepted,
  @MappableValue('confirmed')
  confirmed,
  @MappableValue('preparing')
  preparing,
  @MappableValue('in_kitchen')
  inKitchen,
  @MappableValue('ready')
  ready,
  @MappableValue('courier_requested')
  courierRequested,
  @MappableValue('driver_en_route')
  driverEnRoute,
  @MappableValue('picked_up')
  pickedUp,
  @MappableValue('out_for_delivery')
  outForDelivery,
  @MappableValue('delivered')
  delivered,
  @MappableValue('rejected')
  rejected,
  @MappableValue('canceled')
  canceled,
  @MappableValue('failed')
  failed,
}

/// Payment status
@MappableEnum()
enum PaymentStatus {
  @MappableValue('unpaid')
  unpaid,
  @MappableValue('authorized')
  authorized,
  @MappableValue('paid')
  paid,
  @MappableValue('refunded')
  refunded,
  @MappableValue('voided')
  voided,
}

/// Order source/channel
@MappableEnum()
enum OrderSource {
  @MappableValue('web')
  web,
  @MappableValue('mobile')
  mobile,
  @MappableValue('kiosk')
  kiosk,
  @MappableValue('phone')
  phone,
  @MappableValue('admin')
  admin,
}

/// Price unit for products (supports weight-based ordering)
@MappableEnum()
enum PriceUnit {
  @MappableValue('each')
  each,
  @MappableValue('lb')
  lb,
  @MappableValue('oz')
  oz,
  @MappableValue('kg')
  kg,
  @MappableValue('g')
  g,
  @MappableValue('pack')
  pack,
  @MappableValue('dozen')
  dozen,
  @MappableValue('bunch')
  bunch,
  @MappableValue('piece')
  piece,
}

/// Courier provider for delivery
@MappableEnum()
enum CourierProvider {
  @MappableValue('none')
  none,
  @MappableValue('doordash')
  doordash,
  @MappableValue('uber')
  uber,
}

/// Courier task status
@MappableEnum()
enum CourierStatus {
  @MappableValue('not_requested')
  notRequested,
  @MappableValue('quote_pending')
  quotePending,
  @MappableValue('quote_received')
  quoteReceived,
  @MappableValue('dispatching')
  dispatching,
  @MappableValue('en_route')
  enRoute,
  @MappableValue('arrived')
  arrived,
  @MappableValue('completed')
  completed,
  @MappableValue('failed')
  failed,
  @MappableValue('cancelled')
  cancelled,
}

// Extension methods for PriceUnit
extension PriceUnitX on PriceUnit {
  /// Whether this unit is weight-based
  bool get isWeight =>
      [PriceUnit.lb, PriceUnit.oz, PriceUnit.kg, PriceUnit.g].contains(this);

  /// Get the step increment for quantity selection
  double get step {
    switch (this) {
      case PriceUnit.lb:
        return 0.25;
      case PriceUnit.oz:
        return 4.0;
      case PriceUnit.kg:
        return 0.25;
      case PriceUnit.g:
        return 100.0;
      default:
        return 1.0;
    }
  }

  /// Alias for step (matching web naming)
  double get stepQty => step;

  /// Get the minimum quantity
  double get minimum {
    switch (this) {
      case PriceUnit.lb:
        return 1.0;
      case PriceUnit.oz:
        return 4.0;
      case PriceUnit.kg:
        return 1.0;
      case PriceUnit.g:
        return 100.0;
      default:
        return 1.0;
    }
  }

  /// Alias for minimum (matching web naming)
  double get minimumQty => minimum;

  /// Unit label (e.g., "lb", "oz")
  String get label {
    switch (this) {
      case PriceUnit.lb:
        return 'lb';
      case PriceUnit.oz:
        return 'oz';
      case PriceUnit.kg:
        return 'kg';
      case PriceUnit.g:
        return 'g';
      case PriceUnit.pack:
        return 'pack';
      case PriceUnit.dozen:
        return 'dz';
      case PriceUnit.bunch:
        return 'bunch';
      case PriceUnit.piece:
        return 'pc';
      case PriceUnit.each:
        return '';
    }
  }

  /// Get price suffix for display (e.g., "/lb", " each")
  String get priceSuffix {
    switch (this) {
      case PriceUnit.lb:
        return '/lb';
      case PriceUnit.oz:
        return '/oz';
      case PriceUnit.kg:
        return '/kg';
      case PriceUnit.g:
        return '/g';
      case PriceUnit.each:
        return ' each';
      case PriceUnit.pack:
        return '/pack';
      case PriceUnit.dozen:
        return '/dozen';
      case PriceUnit.bunch:
        return '/bunch';
      case PriceUnit.piece:
        return '/pc';
    }
  }

  /// Get quantity suffix for display (e.g., "lb")
  String get quantitySuffix {
    switch (this) {
      case PriceUnit.lb:
        return 'lb';
      case PriceUnit.oz:
        return 'oz';
      case PriceUnit.kg:
        return 'kg';
      case PriceUnit.g:
        return 'g';
      case PriceUnit.pack:
        return 'pack';
      case PriceUnit.dozen:
        return 'dozen';
      case PriceUnit.bunch:
        return 'bunch';
      case PriceUnit.piece:
        return 'pc';
      default:
        return '';
    }
  }
}

// Extension for OrderStatus display
extension OrderStatusX on OrderStatus {
  /// Human-readable label
  String get label {
    switch (this) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.submitted:
        return 'Submitted';
      case OrderStatus.created:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.inKitchen:
        return 'In Kitchen';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.courierRequested:
        return 'Finding Driver';
      case OrderStatus.driverEnRoute:
        return 'Driver On The Way';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.canceled:
        return 'Canceled';
      case OrderStatus.failed:
        return 'Failed';
    }
  }

  /// Whether order is in a terminal state
  bool get isTerminal => [
    OrderStatus.delivered,
    OrderStatus.rejected,
    OrderStatus.canceled,
    OrderStatus.failed,
  ].contains(this);

  /// Whether order is active (being processed)
  bool get isActive => !isTerminal && this != OrderStatus.draft;
}
