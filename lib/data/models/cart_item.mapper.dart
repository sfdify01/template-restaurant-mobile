// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_item.dart';

class CartModifierMapper extends ClassMapperBase<CartModifier> {
  CartModifierMapper._();

  static CartModifierMapper? _instance;
  static CartModifierMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartModifierMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CartModifier';

  static String _$id(CartModifier v) => v.id;
  static const Field<CartModifier, String> _f$id = Field('id', _$id);
  static String _$name(CartModifier v) => v.name;
  static const Field<CartModifier, String> _f$name = Field('name', _$name);
  static int _$priceCents(CartModifier v) => v.priceCents;
  static const Field<CartModifier, int> _f$priceCents =
      Field('priceCents', _$priceCents, opt: true, def: 0);

  @override
  final MappableFields<CartModifier> fields = const {
    #id: _f$id,
    #name: _f$name,
    #priceCents: _f$priceCents,
  };

  static CartModifier _instantiate(DecodingData data) {
    return CartModifier(
        id: data.dec(_f$id),
        name: data.dec(_f$name),
        priceCents: data.dec(_f$priceCents));
  }

  @override
  final Function instantiate = _instantiate;

  static CartModifier fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartModifier>(map);
  }

  static CartModifier fromJson(String json) {
    return ensureInitialized().decodeJson<CartModifier>(json);
  }
}

mixin CartModifierMappable {
  String toJson() {
    return CartModifierMapper.ensureInitialized()
        .encodeJson<CartModifier>(this as CartModifier);
  }

  Map<String, dynamic> toMap() {
    return CartModifierMapper.ensureInitialized()
        .encodeMap<CartModifier>(this as CartModifier);
  }

  CartModifierCopyWith<CartModifier, CartModifier, CartModifier> get copyWith =>
      _CartModifierCopyWithImpl<CartModifier, CartModifier>(
          this as CartModifier, $identity, $identity);
  @override
  String toString() {
    return CartModifierMapper.ensureInitialized()
        .stringifyValue(this as CartModifier);
  }

  @override
  bool operator ==(Object other) {
    return CartModifierMapper.ensureInitialized()
        .equalsValue(this as CartModifier, other);
  }

  @override
  int get hashCode {
    return CartModifierMapper.ensureInitialized()
        .hashValue(this as CartModifier);
  }
}

extension CartModifierValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartModifier, $Out> {
  CartModifierCopyWith<$R, CartModifier, $Out> get $asCartModifier =>
      $base.as((v, t, t2) => _CartModifierCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartModifierCopyWith<$R, $In extends CartModifier, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, int? priceCents});
  CartModifierCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartModifierCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartModifier, $Out>
    implements CartModifierCopyWith<$R, CartModifier, $Out> {
  _CartModifierCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartModifier> $mapper =
      CartModifierMapper.ensureInitialized();
  @override
  $R call({String? id, String? name, int? priceCents}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (name != null) #name: name,
        if (priceCents != null) #priceCents: priceCents
      }));
  @override
  CartModifier $make(CopyWithData data) => CartModifier(
      id: data.get(#id, or: $value.id),
      name: data.get(#name, or: $value.name),
      priceCents: data.get(#priceCents, or: $value.priceCents));

  @override
  CartModifierCopyWith<$R2, CartModifier, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _CartModifierCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CartItemMapper extends ClassMapperBase<CartItem> {
  CartItemMapper._();

  static CartItemMapper? _instance;
  static CartItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartItemMapper._());
      PriceUnitMapper.ensureInitialized();
      CartModifierMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartItem';

  static String _$id(CartItem v) => v.id;
  static const Field<CartItem, String> _f$id = Field('id', _$id);
  static String _$menuItemId(CartItem v) => v.menuItemId;
  static const Field<CartItem, String> _f$menuItemId =
      Field('menuItemId', _$menuItemId, key: r'menu_item_id');
  static String _$name(CartItem v) => v.name;
  static const Field<CartItem, String> _f$name = Field('name', _$name);
  static int _$unitPriceCents(CartItem v) => v.unitPriceCents;
  static const Field<CartItem, int> _f$unitPriceCents =
      Field('unitPriceCents', _$unitPriceCents, key: r'unit_price_cents');
  static PriceUnit _$priceUnit(CartItem v) => v.priceUnit;
  static const Field<CartItem, PriceUnit> _f$priceUnit = Field(
      'priceUnit', _$priceUnit,
      key: r'price_unit', opt: true, def: PriceUnit.each);
  static String? _$unitLabel(CartItem v) => v.unitLabel;
  static const Field<CartItem, String> _f$unitLabel =
      Field('unitLabel', _$unitLabel, key: r'unit_label', opt: true);
  static double _$qty(CartItem v) => v.qty;
  static const Field<CartItem, double> _f$qty = Field('qty', _$qty);
  static String? _$imageUrl(CartItem v) => v.imageUrl;
  static const Field<CartItem, String> _f$imageUrl =
      Field('imageUrl', _$imageUrl, key: r'image_url', opt: true);
  static List<CartModifier> _$modifiers(CartItem v) => v.modifiers;
  static const Field<CartItem, List<CartModifier>> _f$modifiers =
      Field('modifiers', _$modifiers, opt: true, def: const []);
  static String? _$note(CartItem v) => v.note;
  static const Field<CartItem, String> _f$note =
      Field('note', _$note, opt: true);
  static Map<String, dynamic>? _$metadata(CartItem v) => v.metadata;
  static const Field<CartItem, Map<String, dynamic>> _f$metadata =
      Field('metadata', _$metadata, opt: true);

  @override
  final MappableFields<CartItem> fields = const {
    #id: _f$id,
    #menuItemId: _f$menuItemId,
    #name: _f$name,
    #unitPriceCents: _f$unitPriceCents,
    #priceUnit: _f$priceUnit,
    #unitLabel: _f$unitLabel,
    #qty: _f$qty,
    #imageUrl: _f$imageUrl,
    #modifiers: _f$modifiers,
    #note: _f$note,
    #metadata: _f$metadata,
  };

  static CartItem _instantiate(DecodingData data) {
    return CartItem(
        id: data.dec(_f$id),
        menuItemId: data.dec(_f$menuItemId),
        name: data.dec(_f$name),
        unitPriceCents: data.dec(_f$unitPriceCents),
        priceUnit: data.dec(_f$priceUnit),
        unitLabel: data.dec(_f$unitLabel),
        qty: data.dec(_f$qty),
        imageUrl: data.dec(_f$imageUrl),
        modifiers: data.dec(_f$modifiers),
        note: data.dec(_f$note),
        metadata: data.dec(_f$metadata));
  }

  @override
  final Function instantiate = _instantiate;

  static CartItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartItem>(map);
  }

  static CartItem fromJson(String json) {
    return ensureInitialized().decodeJson<CartItem>(json);
  }
}

mixin CartItemMappable {
  String toJson() {
    return CartItemMapper.ensureInitialized()
        .encodeJson<CartItem>(this as CartItem);
  }

  Map<String, dynamic> toMap() {
    return CartItemMapper.ensureInitialized()
        .encodeMap<CartItem>(this as CartItem);
  }

  CartItemCopyWith<CartItem, CartItem, CartItem> get copyWith =>
      _CartItemCopyWithImpl<CartItem, CartItem>(
          this as CartItem, $identity, $identity);
  @override
  String toString() {
    return CartItemMapper.ensureInitialized().stringifyValue(this as CartItem);
  }

  @override
  bool operator ==(Object other) {
    return CartItemMapper.ensureInitialized()
        .equalsValue(this as CartItem, other);
  }

  @override
  int get hashCode {
    return CartItemMapper.ensureInitialized().hashValue(this as CartItem);
  }
}

extension CartItemValueCopy<$R, $Out> on ObjectCopyWith<$R, CartItem, $Out> {
  CartItemCopyWith<$R, CartItem, $Out> get $asCartItem =>
      $base.as((v, t, t2) => _CartItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartItemCopyWith<$R, $In extends CartItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, CartModifier,
      CartModifierCopyWith<$R, CartModifier, CartModifier>> get modifiers;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata;
  $R call(
      {String? id,
      String? menuItemId,
      String? name,
      int? unitPriceCents,
      PriceUnit? priceUnit,
      String? unitLabel,
      double? qty,
      String? imageUrl,
      List<CartModifier>? modifiers,
      String? note,
      Map<String, dynamic>? metadata});
  CartItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartItem, $Out>
    implements CartItemCopyWith<$R, CartItem, $Out> {
  _CartItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartItem> $mapper =
      CartItemMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CartModifier,
          CartModifierCopyWith<$R, CartModifier, CartModifier>>
      get modifiers => ListCopyWith($value.modifiers,
          (v, t) => v.copyWith.$chain(t), (v) => call(modifiers: v));
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
          String? menuItemId,
          String? name,
          int? unitPriceCents,
          PriceUnit? priceUnit,
          Object? unitLabel = $none,
          double? qty,
          Object? imageUrl = $none,
          List<CartModifier>? modifiers,
          Object? note = $none,
          Object? metadata = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (menuItemId != null) #menuItemId: menuItemId,
        if (name != null) #name: name,
        if (unitPriceCents != null) #unitPriceCents: unitPriceCents,
        if (priceUnit != null) #priceUnit: priceUnit,
        if (unitLabel != $none) #unitLabel: unitLabel,
        if (qty != null) #qty: qty,
        if (imageUrl != $none) #imageUrl: imageUrl,
        if (modifiers != null) #modifiers: modifiers,
        if (note != $none) #note: note,
        if (metadata != $none) #metadata: metadata
      }));
  @override
  CartItem $make(CopyWithData data) => CartItem(
      id: data.get(#id, or: $value.id),
      menuItemId: data.get(#menuItemId, or: $value.menuItemId),
      name: data.get(#name, or: $value.name),
      unitPriceCents: data.get(#unitPriceCents, or: $value.unitPriceCents),
      priceUnit: data.get(#priceUnit, or: $value.priceUnit),
      unitLabel: data.get(#unitLabel, or: $value.unitLabel),
      qty: data.get(#qty, or: $value.qty),
      imageUrl: data.get(#imageUrl, or: $value.imageUrl),
      modifiers: data.get(#modifiers, or: $value.modifiers),
      note: data.get(#note, or: $value.note),
      metadata: data.get(#metadata, or: $value.metadata));

  @override
  CartItemCopyWith<$R2, CartItem, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _CartItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
