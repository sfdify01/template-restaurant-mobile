// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order.dart';

class OrderMapper extends ClassMapperBase<Order> {
  OrderMapper._();

  static OrderMapper? _instance;
  static OrderMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderMapper._());
      FulfillmentTypeMapper.ensureInitialized();
      OrderStatusMapper.ensureInitialized();
      PaymentStatusMapper.ensureInitialized();
      OrderSourceMapper.ensureInitialized();
      OrderItemMapper.ensureInitialized();
      AddressMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Order';

  static String _$id(Order v) => v.id;
  static const Field<Order, String> _f$id = Field('id', _$id);
  static int _$orderNumber(Order v) => v.orderNumber;
  static const Field<Order, int> _f$orderNumber =
      Field('orderNumber', _$orderNumber, key: r'order_number');
  static String _$tenantId(Order v) => v.tenantId;
  static const Field<Order, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String? _$customerId(Order v) => v.customerId;
  static const Field<Order, String> _f$customerId =
      Field('customerId', _$customerId, key: r'customer_id', opt: true);
  static String? _$deliveryAddressId(Order v) => v.deliveryAddressId;
  static const Field<Order, String> _f$deliveryAddressId = Field(
      'deliveryAddressId', _$deliveryAddressId,
      key: r'delivery_address_id', opt: true);
  static FulfillmentType _$fulfillmentType(Order v) => v.fulfillmentType;
  static const Field<Order, FulfillmentType> _f$fulfillmentType =
      Field('fulfillmentType', _$fulfillmentType, key: r'fulfillment_type');
  static OrderStatus _$status(Order v) => v.status;
  static const Field<Order, OrderStatus> _f$status =
      Field('status', _$status, opt: true, def: OrderStatus.created);
  static PaymentStatus _$paymentStatus(Order v) => v.paymentStatus;
  static const Field<Order, PaymentStatus> _f$paymentStatus = Field(
      'paymentStatus', _$paymentStatus,
      key: r'payment_status', opt: true, def: PaymentStatus.unpaid);
  static OrderSource _$source(Order v) => v.source;
  static const Field<Order, OrderSource> _f$source =
      Field('source', _$source, opt: true, def: OrderSource.mobile);
  static DateTime? _$scheduledFor(Order v) => v.scheduledFor;
  static const Field<Order, DateTime> _f$scheduledFor =
      Field('scheduledFor', _$scheduledFor, key: r'scheduled_for', opt: true);
  static String _$currency(Order v) => v.currency;
  static const Field<Order, String> _f$currency =
      Field('currency', _$currency, opt: true, def: 'USD');
  static int _$subtotalCents(Order v) => v.subtotalCents;
  static const Field<Order, int> _f$subtotalCents = Field(
      'subtotalCents', _$subtotalCents,
      key: r'subtotal_cents', opt: true, def: 0);
  static int _$taxCents(Order v) => v.taxCents;
  static const Field<Order, int> _f$taxCents =
      Field('taxCents', _$taxCents, key: r'tax_cents', opt: true, def: 0);
  static int _$tipCents(Order v) => v.tipCents;
  static const Field<Order, int> _f$tipCents =
      Field('tipCents', _$tipCents, key: r'tip_cents', opt: true, def: 0);
  static int _$deliveryFeeCents(Order v) => v.deliveryFeeCents;
  static const Field<Order, int> _f$deliveryFeeCents = Field(
      'deliveryFeeCents', _$deliveryFeeCents,
      key: r'delivery_fee_cents', opt: true, def: 0);
  static int _$serviceFeeCents(Order v) => v.serviceFeeCents;
  static const Field<Order, int> _f$serviceFeeCents = Field(
      'serviceFeeCents', _$serviceFeeCents,
      key: r'service_fee_cents', opt: true, def: 0);
  static int _$discountCents(Order v) => v.discountCents;
  static const Field<Order, int> _f$discountCents = Field(
      'discountCents', _$discountCents,
      key: r'discount_cents', opt: true, def: 0);
  static int _$totalCents(Order v) => v.totalCents;
  static const Field<Order, int> _f$totalCents =
      Field('totalCents', _$totalCents, key: r'total_cents');
  static int _$itemsCount(Order v) => v.itemsCount;
  static const Field<Order, int> _f$itemsCount =
      Field('itemsCount', _$itemsCount, key: r'items_count', opt: true, def: 0);
  static double _$weightOz(Order v) => v.weightOz;
  static const Field<Order, double> _f$weightOz =
      Field('weightOz', _$weightOz, key: r'weight_oz', opt: true, def: 0);
  static String? _$contactName(Order v) => v.contactName;
  static const Field<Order, String> _f$contactName =
      Field('contactName', _$contactName, key: r'contact_name', opt: true);
  static String? _$contactEmail(Order v) => v.contactEmail;
  static const Field<Order, String> _f$contactEmail =
      Field('contactEmail', _$contactEmail, key: r'contact_email', opt: true);
  static String? _$contactPhone(Order v) => v.contactPhone;
  static const Field<Order, String> _f$contactPhone =
      Field('contactPhone', _$contactPhone, key: r'contact_phone', opt: true);
  static String? _$specialInstructions(Order v) => v.specialInstructions;
  static const Field<Order, String> _f$specialInstructions = Field(
      'specialInstructions', _$specialInstructions,
      key: r'special_instructions', opt: true);
  static String? _$fulfillmentInstructions(Order v) =>
      v.fulfillmentInstructions;
  static const Field<Order, String> _f$fulfillmentInstructions = Field(
      'fulfillmentInstructions', _$fulfillmentInstructions,
      key: r'fulfillment_instructions', opt: true);
  static DateTime? _$pickupEta(Order v) => v.pickupEta;
  static const Field<Order, DateTime> _f$pickupEta =
      Field('pickupEta', _$pickupEta, key: r'pickup_eta', opt: true);
  static DateTime? _$deliveryEta(Order v) => v.deliveryEta;
  static const Field<Order, DateTime> _f$deliveryEta =
      Field('deliveryEta', _$deliveryEta, key: r'delivery_eta', opt: true);
  static String? _$createdBy(Order v) => v.createdBy;
  static const Field<Order, String> _f$createdBy =
      Field('createdBy', _$createdBy, key: r'created_by', opt: true);
  static Map<String, dynamic>? _$metadata(Order v) => v.metadata;
  static const Field<Order, Map<String, dynamic>> _f$metadata =
      Field('metadata', _$metadata, opt: true);
  static DateTime _$createdAt(Order v) => v.createdAt;
  static const Field<Order, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$updatedAt(Order v) => v.updatedAt;
  static const Field<Order, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, key: r'updated_at');
  static List<OrderItem>? _$items(Order v) => v.items;
  static const Field<Order, List<OrderItem>> _f$items =
      Field('items', _$items, opt: true);
  static Address? _$deliveryAddress(Order v) => v.deliveryAddress;
  static const Field<Order, Address> _f$deliveryAddress = Field(
      'deliveryAddress', _$deliveryAddress,
      key: r'delivery_address', opt: true);

  @override
  final MappableFields<Order> fields = const {
    #id: _f$id,
    #orderNumber: _f$orderNumber,
    #tenantId: _f$tenantId,
    #customerId: _f$customerId,
    #deliveryAddressId: _f$deliveryAddressId,
    #fulfillmentType: _f$fulfillmentType,
    #status: _f$status,
    #paymentStatus: _f$paymentStatus,
    #source: _f$source,
    #scheduledFor: _f$scheduledFor,
    #currency: _f$currency,
    #subtotalCents: _f$subtotalCents,
    #taxCents: _f$taxCents,
    #tipCents: _f$tipCents,
    #deliveryFeeCents: _f$deliveryFeeCents,
    #serviceFeeCents: _f$serviceFeeCents,
    #discountCents: _f$discountCents,
    #totalCents: _f$totalCents,
    #itemsCount: _f$itemsCount,
    #weightOz: _f$weightOz,
    #contactName: _f$contactName,
    #contactEmail: _f$contactEmail,
    #contactPhone: _f$contactPhone,
    #specialInstructions: _f$specialInstructions,
    #fulfillmentInstructions: _f$fulfillmentInstructions,
    #pickupEta: _f$pickupEta,
    #deliveryEta: _f$deliveryEta,
    #createdBy: _f$createdBy,
    #metadata: _f$metadata,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #items: _f$items,
    #deliveryAddress: _f$deliveryAddress,
  };

  static Order _instantiate(DecodingData data) {
    return Order(
        id: data.dec(_f$id),
        orderNumber: data.dec(_f$orderNumber),
        tenantId: data.dec(_f$tenantId),
        customerId: data.dec(_f$customerId),
        deliveryAddressId: data.dec(_f$deliveryAddressId),
        fulfillmentType: data.dec(_f$fulfillmentType),
        status: data.dec(_f$status),
        paymentStatus: data.dec(_f$paymentStatus),
        source: data.dec(_f$source),
        scheduledFor: data.dec(_f$scheduledFor),
        currency: data.dec(_f$currency),
        subtotalCents: data.dec(_f$subtotalCents),
        taxCents: data.dec(_f$taxCents),
        tipCents: data.dec(_f$tipCents),
        deliveryFeeCents: data.dec(_f$deliveryFeeCents),
        serviceFeeCents: data.dec(_f$serviceFeeCents),
        discountCents: data.dec(_f$discountCents),
        totalCents: data.dec(_f$totalCents),
        itemsCount: data.dec(_f$itemsCount),
        weightOz: data.dec(_f$weightOz),
        contactName: data.dec(_f$contactName),
        contactEmail: data.dec(_f$contactEmail),
        contactPhone: data.dec(_f$contactPhone),
        specialInstructions: data.dec(_f$specialInstructions),
        fulfillmentInstructions: data.dec(_f$fulfillmentInstructions),
        pickupEta: data.dec(_f$pickupEta),
        deliveryEta: data.dec(_f$deliveryEta),
        createdBy: data.dec(_f$createdBy),
        metadata: data.dec(_f$metadata),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt),
        items: data.dec(_f$items),
        deliveryAddress: data.dec(_f$deliveryAddress));
  }

  @override
  final Function instantiate = _instantiate;

  static Order fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Order>(map);
  }

  static Order fromJson(String json) {
    return ensureInitialized().decodeJson<Order>(json);
  }
}

mixin OrderMappable {
  String toJson() {
    return OrderMapper.ensureInitialized().encodeJson<Order>(this as Order);
  }

  Map<String, dynamic> toMap() {
    return OrderMapper.ensureInitialized().encodeMap<Order>(this as Order);
  }

  OrderCopyWith<Order, Order, Order> get copyWith =>
      _OrderCopyWithImpl<Order, Order>(this as Order, $identity, $identity);
  @override
  String toString() {
    return OrderMapper.ensureInitialized().stringifyValue(this as Order);
  }

  @override
  bool operator ==(Object other) {
    return OrderMapper.ensureInitialized().equalsValue(this as Order, other);
  }

  @override
  int get hashCode {
    return OrderMapper.ensureInitialized().hashValue(this as Order);
  }
}

extension OrderValueCopy<$R, $Out> on ObjectCopyWith<$R, Order, $Out> {
  OrderCopyWith<$R, Order, $Out> get $asOrder =>
      $base.as((v, t, t2) => _OrderCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderCopyWith<$R, $In extends Order, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata;
  ListCopyWith<$R, OrderItem, OrderItemCopyWith<$R, OrderItem, OrderItem>>?
      get items;
  AddressCopyWith<$R, Address, Address>? get deliveryAddress;
  $R call(
      {String? id,
      int? orderNumber,
      String? tenantId,
      String? customerId,
      String? deliveryAddressId,
      FulfillmentType? fulfillmentType,
      OrderStatus? status,
      PaymentStatus? paymentStatus,
      OrderSource? source,
      DateTime? scheduledFor,
      String? currency,
      int? subtotalCents,
      int? taxCents,
      int? tipCents,
      int? deliveryFeeCents,
      int? serviceFeeCents,
      int? discountCents,
      int? totalCents,
      int? itemsCount,
      double? weightOz,
      String? contactName,
      String? contactEmail,
      String? contactPhone,
      String? specialInstructions,
      String? fulfillmentInstructions,
      DateTime? pickupEta,
      DateTime? deliveryEta,
      String? createdBy,
      Map<String, dynamic>? metadata,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<OrderItem>? items,
      Address? deliveryAddress});
  OrderCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrderCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Order, $Out>
    implements OrderCopyWith<$R, Order, $Out> {
  _OrderCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Order> $mapper = OrderMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata => $value.metadata != null
          ? MapCopyWith(
              $value.metadata!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(metadata: v))
          : null;
  @override
  ListCopyWith<$R, OrderItem, OrderItemCopyWith<$R, OrderItem, OrderItem>>?
      get items => $value.items != null
          ? ListCopyWith($value.items!, (v, t) => v.copyWith.$chain(t),
              (v) => call(items: v))
          : null;
  @override
  AddressCopyWith<$R, Address, Address>? get deliveryAddress =>
      $value.deliveryAddress?.copyWith.$chain((v) => call(deliveryAddress: v));
  @override
  $R call(
          {String? id,
          int? orderNumber,
          String? tenantId,
          Object? customerId = $none,
          Object? deliveryAddressId = $none,
          FulfillmentType? fulfillmentType,
          OrderStatus? status,
          PaymentStatus? paymentStatus,
          OrderSource? source,
          Object? scheduledFor = $none,
          String? currency,
          int? subtotalCents,
          int? taxCents,
          int? tipCents,
          int? deliveryFeeCents,
          int? serviceFeeCents,
          int? discountCents,
          int? totalCents,
          int? itemsCount,
          double? weightOz,
          Object? contactName = $none,
          Object? contactEmail = $none,
          Object? contactPhone = $none,
          Object? specialInstructions = $none,
          Object? fulfillmentInstructions = $none,
          Object? pickupEta = $none,
          Object? deliveryEta = $none,
          Object? createdBy = $none,
          Object? metadata = $none,
          DateTime? createdAt,
          DateTime? updatedAt,
          Object? items = $none,
          Object? deliveryAddress = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (orderNumber != null) #orderNumber: orderNumber,
        if (tenantId != null) #tenantId: tenantId,
        if (customerId != $none) #customerId: customerId,
        if (deliveryAddressId != $none) #deliveryAddressId: deliveryAddressId,
        if (fulfillmentType != null) #fulfillmentType: fulfillmentType,
        if (status != null) #status: status,
        if (paymentStatus != null) #paymentStatus: paymentStatus,
        if (source != null) #source: source,
        if (scheduledFor != $none) #scheduledFor: scheduledFor,
        if (currency != null) #currency: currency,
        if (subtotalCents != null) #subtotalCents: subtotalCents,
        if (taxCents != null) #taxCents: taxCents,
        if (tipCents != null) #tipCents: tipCents,
        if (deliveryFeeCents != null) #deliveryFeeCents: deliveryFeeCents,
        if (serviceFeeCents != null) #serviceFeeCents: serviceFeeCents,
        if (discountCents != null) #discountCents: discountCents,
        if (totalCents != null) #totalCents: totalCents,
        if (itemsCount != null) #itemsCount: itemsCount,
        if (weightOz != null) #weightOz: weightOz,
        if (contactName != $none) #contactName: contactName,
        if (contactEmail != $none) #contactEmail: contactEmail,
        if (contactPhone != $none) #contactPhone: contactPhone,
        if (specialInstructions != $none)
          #specialInstructions: specialInstructions,
        if (fulfillmentInstructions != $none)
          #fulfillmentInstructions: fulfillmentInstructions,
        if (pickupEta != $none) #pickupEta: pickupEta,
        if (deliveryEta != $none) #deliveryEta: deliveryEta,
        if (createdBy != $none) #createdBy: createdBy,
        if (metadata != $none) #metadata: metadata,
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt,
        if (items != $none) #items: items,
        if (deliveryAddress != $none) #deliveryAddress: deliveryAddress
      }));
  @override
  Order $make(CopyWithData data) => Order(
      id: data.get(#id, or: $value.id),
      orderNumber: data.get(#orderNumber, or: $value.orderNumber),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      customerId: data.get(#customerId, or: $value.customerId),
      deliveryAddressId:
          data.get(#deliveryAddressId, or: $value.deliveryAddressId),
      fulfillmentType: data.get(#fulfillmentType, or: $value.fulfillmentType),
      status: data.get(#status, or: $value.status),
      paymentStatus: data.get(#paymentStatus, or: $value.paymentStatus),
      source: data.get(#source, or: $value.source),
      scheduledFor: data.get(#scheduledFor, or: $value.scheduledFor),
      currency: data.get(#currency, or: $value.currency),
      subtotalCents: data.get(#subtotalCents, or: $value.subtotalCents),
      taxCents: data.get(#taxCents, or: $value.taxCents),
      tipCents: data.get(#tipCents, or: $value.tipCents),
      deliveryFeeCents:
          data.get(#deliveryFeeCents, or: $value.deliveryFeeCents),
      serviceFeeCents: data.get(#serviceFeeCents, or: $value.serviceFeeCents),
      discountCents: data.get(#discountCents, or: $value.discountCents),
      totalCents: data.get(#totalCents, or: $value.totalCents),
      itemsCount: data.get(#itemsCount, or: $value.itemsCount),
      weightOz: data.get(#weightOz, or: $value.weightOz),
      contactName: data.get(#contactName, or: $value.contactName),
      contactEmail: data.get(#contactEmail, or: $value.contactEmail),
      contactPhone: data.get(#contactPhone, or: $value.contactPhone),
      specialInstructions:
          data.get(#specialInstructions, or: $value.specialInstructions),
      fulfillmentInstructions: data.get(#fulfillmentInstructions,
          or: $value.fulfillmentInstructions),
      pickupEta: data.get(#pickupEta, or: $value.pickupEta),
      deliveryEta: data.get(#deliveryEta, or: $value.deliveryEta),
      createdBy: data.get(#createdBy, or: $value.createdBy),
      metadata: data.get(#metadata, or: $value.metadata),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      items: data.get(#items, or: $value.items),
      deliveryAddress: data.get(#deliveryAddress, or: $value.deliveryAddress));

  @override
  OrderCopyWith<$R2, Order, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrderCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
