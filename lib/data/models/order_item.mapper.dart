// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_item.dart';

class OrderItemMapper extends ClassMapperBase<OrderItem> {
  OrderItemMapper._();

  static OrderItemMapper? _instance;
  static OrderItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderItemMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OrderItem';

  static String _$id(OrderItem v) => v.id;
  static const Field<OrderItem, String> _f$id = Field('id', _$id);
  static String _$orderId(OrderItem v) => v.orderId;
  static const Field<OrderItem, String> _f$orderId =
      Field('orderId', _$orderId, key: r'order_id');
  static String _$tenantId(OrderItem v) => v.tenantId;
  static const Field<OrderItem, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String? _$menuItemId(OrderItem v) => v.menuItemId;
  static const Field<OrderItem, String> _f$menuItemId =
      Field('menuItemId', _$menuItemId, key: r'menu_item_id', opt: true);
  static String? _$menuItemKey(OrderItem v) => v.menuItemKey;
  static const Field<OrderItem, String> _f$menuItemKey =
      Field('menuItemKey', _$menuItemKey, key: r'menu_item_key', opt: true);
  static String _$name(OrderItem v) => v.name;
  static const Field<OrderItem, String> _f$name = Field('name', _$name);
  static String? _$description(OrderItem v) => v.description;
  static const Field<OrderItem, String> _f$description =
      Field('description', _$description, opt: true);
  static String? _$imageUrl(OrderItem v) => v.imageUrl;
  static const Field<OrderItem, String> _f$imageUrl =
      Field('imageUrl', _$imageUrl, key: r'image_url', opt: true);
  static int _$unitPriceCents(OrderItem v) => v.unitPriceCents;
  static const Field<OrderItem, int> _f$unitPriceCents =
      Field('unitPriceCents', _$unitPriceCents, key: r'unit_price_cents');
  static double _$quantity(OrderItem v) => v.quantity;
  static const Field<OrderItem, double> _f$quantity =
      Field('quantity', _$quantity);
  static String _$unitLabel(OrderItem v) => v.unitLabel;
  static const Field<OrderItem, String> _f$unitLabel = Field(
      'unitLabel', _$unitLabel,
      key: r'unit_label', opt: true, def: 'each');
  static int _$totalPriceCents(OrderItem v) => v.totalPriceCents;
  static const Field<OrderItem, int> _f$totalPriceCents =
      Field('totalPriceCents', _$totalPriceCents, key: r'total_price_cents');
  static List<Map<String, dynamic>> _$modifiers(OrderItem v) => v.modifiers;
  static const Field<OrderItem, List<Map<String, dynamic>>> _f$modifiers =
      Field('modifiers', _$modifiers, opt: true, def: const []);
  static Map<String, dynamic>? _$metadata(OrderItem v) => v.metadata;
  static const Field<OrderItem, Map<String, dynamic>> _f$metadata =
      Field('metadata', _$metadata, opt: true);

  @override
  final MappableFields<OrderItem> fields = const {
    #id: _f$id,
    #orderId: _f$orderId,
    #tenantId: _f$tenantId,
    #menuItemId: _f$menuItemId,
    #menuItemKey: _f$menuItemKey,
    #name: _f$name,
    #description: _f$description,
    #imageUrl: _f$imageUrl,
    #unitPriceCents: _f$unitPriceCents,
    #quantity: _f$quantity,
    #unitLabel: _f$unitLabel,
    #totalPriceCents: _f$totalPriceCents,
    #modifiers: _f$modifiers,
    #metadata: _f$metadata,
  };

  static OrderItem _instantiate(DecodingData data) {
    return OrderItem(
        id: data.dec(_f$id),
        orderId: data.dec(_f$orderId),
        tenantId: data.dec(_f$tenantId),
        menuItemId: data.dec(_f$menuItemId),
        menuItemKey: data.dec(_f$menuItemKey),
        name: data.dec(_f$name),
        description: data.dec(_f$description),
        imageUrl: data.dec(_f$imageUrl),
        unitPriceCents: data.dec(_f$unitPriceCents),
        quantity: data.dec(_f$quantity),
        unitLabel: data.dec(_f$unitLabel),
        totalPriceCents: data.dec(_f$totalPriceCents),
        modifiers: data.dec(_f$modifiers),
        metadata: data.dec(_f$metadata));
  }

  @override
  final Function instantiate = _instantiate;

  static OrderItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderItem>(map);
  }

  static OrderItem fromJson(String json) {
    return ensureInitialized().decodeJson<OrderItem>(json);
  }
}

mixin OrderItemMappable {
  String toJson() {
    return OrderItemMapper.ensureInitialized()
        .encodeJson<OrderItem>(this as OrderItem);
  }

  Map<String, dynamic> toMap() {
    return OrderItemMapper.ensureInitialized()
        .encodeMap<OrderItem>(this as OrderItem);
  }

  OrderItemCopyWith<OrderItem, OrderItem, OrderItem> get copyWith =>
      _OrderItemCopyWithImpl<OrderItem, OrderItem>(
          this as OrderItem, $identity, $identity);
  @override
  String toString() {
    return OrderItemMapper.ensureInitialized()
        .stringifyValue(this as OrderItem);
  }

  @override
  bool operator ==(Object other) {
    return OrderItemMapper.ensureInitialized()
        .equalsValue(this as OrderItem, other);
  }

  @override
  int get hashCode {
    return OrderItemMapper.ensureInitialized().hashValue(this as OrderItem);
  }
}

extension OrderItemValueCopy<$R, $Out> on ObjectCopyWith<$R, OrderItem, $Out> {
  OrderItemCopyWith<$R, OrderItem, $Out> get $asOrderItem =>
      $base.as((v, t, t2) => _OrderItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderItemCopyWith<$R, $In extends OrderItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Map<String, dynamic>,
          ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>>
      get modifiers;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata;
  $R call(
      {String? id,
      String? orderId,
      String? tenantId,
      String? menuItemId,
      String? menuItemKey,
      String? name,
      String? description,
      String? imageUrl,
      int? unitPriceCents,
      double? quantity,
      String? unitLabel,
      int? totalPriceCents,
      List<Map<String, dynamic>>? modifiers,
      Map<String, dynamic>? metadata});
  OrderItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrderItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderItem, $Out>
    implements OrderItemCopyWith<$R, OrderItem, $Out> {
  _OrderItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderItem> $mapper =
      OrderItemMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Map<String, dynamic>,
          ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>>
      get modifiers => ListCopyWith($value.modifiers,
          (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(modifiers: v));
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata => $value.metadata != null
          ? MapCopyWith(
              $value.metadata!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(metadata: v))
          : null;
  @override
  $R call(
          {String? id,
          String? orderId,
          String? tenantId,
          Object? menuItemId = $none,
          Object? menuItemKey = $none,
          String? name,
          Object? description = $none,
          Object? imageUrl = $none,
          int? unitPriceCents,
          double? quantity,
          String? unitLabel,
          int? totalPriceCents,
          List<Map<String, dynamic>>? modifiers,
          Object? metadata = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (orderId != null) #orderId: orderId,
        if (tenantId != null) #tenantId: tenantId,
        if (menuItemId != $none) #menuItemId: menuItemId,
        if (menuItemKey != $none) #menuItemKey: menuItemKey,
        if (name != null) #name: name,
        if (description != $none) #description: description,
        if (imageUrl != $none) #imageUrl: imageUrl,
        if (unitPriceCents != null) #unitPriceCents: unitPriceCents,
        if (quantity != null) #quantity: quantity,
        if (unitLabel != null) #unitLabel: unitLabel,
        if (totalPriceCents != null) #totalPriceCents: totalPriceCents,
        if (modifiers != null) #modifiers: modifiers,
        if (metadata != $none) #metadata: metadata
      }));
  @override
  OrderItem $make(CopyWithData data) => OrderItem(
      id: data.get(#id, or: $value.id),
      orderId: data.get(#orderId, or: $value.orderId),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      menuItemId: data.get(#menuItemId, or: $value.menuItemId),
      menuItemKey: data.get(#menuItemKey, or: $value.menuItemKey),
      name: data.get(#name, or: $value.name),
      description: data.get(#description, or: $value.description),
      imageUrl: data.get(#imageUrl, or: $value.imageUrl),
      unitPriceCents: data.get(#unitPriceCents, or: $value.unitPriceCents),
      quantity: data.get(#quantity, or: $value.quantity),
      unitLabel: data.get(#unitLabel, or: $value.unitLabel),
      totalPriceCents: data.get(#totalPriceCents, or: $value.totalPriceCents),
      modifiers: data.get(#modifiers, or: $value.modifiers),
      metadata: data.get(#metadata, or: $value.metadata));

  @override
  OrderItemCopyWith<$R2, OrderItem, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _OrderItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
