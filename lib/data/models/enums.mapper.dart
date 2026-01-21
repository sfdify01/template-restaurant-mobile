// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'enums.dart';

class FulfillmentTypeMapper extends EnumMapper<FulfillmentType> {
  FulfillmentTypeMapper._();

  static FulfillmentTypeMapper? _instance;
  static FulfillmentTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FulfillmentTypeMapper._());
    }
    return _instance!;
  }

  static FulfillmentType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  FulfillmentType decode(dynamic value) {
    switch (value) {
      case 'pickup':
        return FulfillmentType.pickup;
      case 'delivery':
        return FulfillmentType.delivery;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(FulfillmentType self) {
    switch (self) {
      case FulfillmentType.pickup:
        return 'pickup';
      case FulfillmentType.delivery:
        return 'delivery';
    }
  }
}

extension FulfillmentTypeMapperExtension on FulfillmentType {
  dynamic toValue() {
    FulfillmentTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<FulfillmentType>(this);
  }
}

class OrderStatusMapper extends EnumMapper<OrderStatus> {
  OrderStatusMapper._();

  static OrderStatusMapper? _instance;
  static OrderStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusMapper._());
    }
    return _instance!;
  }

  static OrderStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderStatus decode(dynamic value) {
    switch (value) {
      case 'draft':
        return OrderStatus.draft;
      case 'pending':
        return OrderStatus.pending;
      case 'submitted':
        return OrderStatus.submitted;
      case 'created':
        return OrderStatus.created;
      case 'accepted':
        return OrderStatus.accepted;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'in_kitchen':
        return OrderStatus.inKitchen;
      case 'ready':
        return OrderStatus.ready;
      case 'courier_requested':
        return OrderStatus.courierRequested;
      case 'driver_en_route':
        return OrderStatus.driverEnRoute;
      case 'picked_up':
        return OrderStatus.pickedUp;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'rejected':
        return OrderStatus.rejected;
      case 'canceled':
        return OrderStatus.canceled;
      case 'failed':
        return OrderStatus.failed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderStatus self) {
    switch (self) {
      case OrderStatus.draft:
        return 'draft';
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.submitted:
        return 'submitted';
      case OrderStatus.created:
        return 'created';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.inKitchen:
        return 'in_kitchen';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.courierRequested:
        return 'courier_requested';
      case OrderStatus.driverEnRoute:
        return 'driver_en_route';
      case OrderStatus.pickedUp:
        return 'picked_up';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.rejected:
        return 'rejected';
      case OrderStatus.canceled:
        return 'canceled';
      case OrderStatus.failed:
        return 'failed';
    }
  }
}

extension OrderStatusMapperExtension on OrderStatus {
  dynamic toValue() {
    OrderStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderStatus>(this);
  }
}

class PaymentStatusMapper extends EnumMapper<PaymentStatus> {
  PaymentStatusMapper._();

  static PaymentStatusMapper? _instance;
  static PaymentStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentStatusMapper._());
    }
    return _instance!;
  }

  static PaymentStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PaymentStatus decode(dynamic value) {
    switch (value) {
      case 'unpaid':
        return PaymentStatus.unpaid;
      case 'authorized':
        return PaymentStatus.authorized;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'voided':
        return PaymentStatus.voided;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PaymentStatus self) {
    switch (self) {
      case PaymentStatus.unpaid:
        return 'unpaid';
      case PaymentStatus.authorized:
        return 'authorized';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.voided:
        return 'voided';
    }
  }
}

extension PaymentStatusMapperExtension on PaymentStatus {
  dynamic toValue() {
    PaymentStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PaymentStatus>(this);
  }
}

class OrderSourceMapper extends EnumMapper<OrderSource> {
  OrderSourceMapper._();

  static OrderSourceMapper? _instance;
  static OrderSourceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderSourceMapper._());
    }
    return _instance!;
  }

  static OrderSource fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderSource decode(dynamic value) {
    switch (value) {
      case 'web':
        return OrderSource.web;
      case 'mobile':
        return OrderSource.mobile;
      case 'kiosk':
        return OrderSource.kiosk;
      case 'phone':
        return OrderSource.phone;
      case 'admin':
        return OrderSource.admin;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderSource self) {
    switch (self) {
      case OrderSource.web:
        return 'web';
      case OrderSource.mobile:
        return 'mobile';
      case OrderSource.kiosk:
        return 'kiosk';
      case OrderSource.phone:
        return 'phone';
      case OrderSource.admin:
        return 'admin';
    }
  }
}

extension OrderSourceMapperExtension on OrderSource {
  dynamic toValue() {
    OrderSourceMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderSource>(this);
  }
}

class PriceUnitMapper extends EnumMapper<PriceUnit> {
  PriceUnitMapper._();

  static PriceUnitMapper? _instance;
  static PriceUnitMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PriceUnitMapper._());
    }
    return _instance!;
  }

  static PriceUnit fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PriceUnit decode(dynamic value) {
    switch (value) {
      case 'each':
        return PriceUnit.each;
      case 'lb':
        return PriceUnit.lb;
      case 'oz':
        return PriceUnit.oz;
      case 'kg':
        return PriceUnit.kg;
      case 'g':
        return PriceUnit.g;
      case 'pack':
        return PriceUnit.pack;
      case 'dozen':
        return PriceUnit.dozen;
      case 'bunch':
        return PriceUnit.bunch;
      case 'piece':
        return PriceUnit.piece;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PriceUnit self) {
    switch (self) {
      case PriceUnit.each:
        return 'each';
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
        return 'piece';
    }
  }
}

extension PriceUnitMapperExtension on PriceUnit {
  dynamic toValue() {
    PriceUnitMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PriceUnit>(this);
  }
}

class CourierProviderMapper extends EnumMapper<CourierProvider> {
  CourierProviderMapper._();

  static CourierProviderMapper? _instance;
  static CourierProviderMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CourierProviderMapper._());
    }
    return _instance!;
  }

  static CourierProvider fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CourierProvider decode(dynamic value) {
    switch (value) {
      case 'none':
        return CourierProvider.none;
      case 'doordash':
        return CourierProvider.doordash;
      case 'uber':
        return CourierProvider.uber;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CourierProvider self) {
    switch (self) {
      case CourierProvider.none:
        return 'none';
      case CourierProvider.doordash:
        return 'doordash';
      case CourierProvider.uber:
        return 'uber';
    }
  }
}

extension CourierProviderMapperExtension on CourierProvider {
  dynamic toValue() {
    CourierProviderMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CourierProvider>(this);
  }
}

class CourierStatusMapper extends EnumMapper<CourierStatus> {
  CourierStatusMapper._();

  static CourierStatusMapper? _instance;
  static CourierStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CourierStatusMapper._());
    }
    return _instance!;
  }

  static CourierStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CourierStatus decode(dynamic value) {
    switch (value) {
      case 'not_requested':
        return CourierStatus.notRequested;
      case 'quote_pending':
        return CourierStatus.quotePending;
      case 'quote_received':
        return CourierStatus.quoteReceived;
      case 'dispatching':
        return CourierStatus.dispatching;
      case 'en_route':
        return CourierStatus.enRoute;
      case 'arrived':
        return CourierStatus.arrived;
      case 'completed':
        return CourierStatus.completed;
      case 'failed':
        return CourierStatus.failed;
      case 'cancelled':
        return CourierStatus.cancelled;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CourierStatus self) {
    switch (self) {
      case CourierStatus.notRequested:
        return 'not_requested';
      case CourierStatus.quotePending:
        return 'quote_pending';
      case CourierStatus.quoteReceived:
        return 'quote_received';
      case CourierStatus.dispatching:
        return 'dispatching';
      case CourierStatus.enRoute:
        return 'en_route';
      case CourierStatus.arrived:
        return 'arrived';
      case CourierStatus.completed:
        return 'completed';
      case CourierStatus.failed:
        return 'failed';
      case CourierStatus.cancelled:
        return 'cancelled';
    }
  }
}

extension CourierStatusMapperExtension on CourierStatus {
  dynamic toValue() {
    CourierStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CourierStatus>(this);
  }
}
