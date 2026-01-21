// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_item.dart';

class MenuItemMapper extends ClassMapperBase<MenuItem> {
  MenuItemMapper._();

  static MenuItemMapper? _instance;
  static MenuItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemMapper._());
      PriceUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItem';

  static String _$id(MenuItem v) => v.id;
  static const Field<MenuItem, String> _f$id = Field('id', _$id);
  static String _$tenantId(MenuItem v) => v.tenantId;
  static const Field<MenuItem, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String? _$externalId(MenuItem v) => v.externalId;
  static const Field<MenuItem, String> _f$externalId =
      Field('externalId', _$externalId, key: r'external_id', opt: true);
  static String _$name(MenuItem v) => v.name;
  static const Field<MenuItem, String> _f$name = Field('name', _$name);
  static String? _$category(MenuItem v) => v.category;
  static const Field<MenuItem, String> _f$category =
      Field('category', _$category, opt: true);
  static String? _$description(MenuItem v) => v.description;
  static const Field<MenuItem, String> _f$description =
      Field('description', _$description, opt: true);
  static String? _$imageUrl(MenuItem v) => v.imageUrl;
  static const Field<MenuItem, String> _f$imageUrl =
      Field('imageUrl', _$imageUrl, key: r'image_url', opt: true);
  static int _$priceCents(MenuItem v) => v.priceCents;
  static const Field<MenuItem, int> _f$priceCents =
      Field('priceCents', _$priceCents, key: r'price_cents');
  static PriceUnit _$priceUnit(MenuItem v) => v.priceUnit;
  static const Field<MenuItem, PriceUnit> _f$priceUnit = Field(
      'priceUnit', _$priceUnit,
      key: r'price_unit', opt: true, def: PriceUnit.each);
  static List<String> _$dietaryTags(MenuItem v) => v.dietaryTags;
  static const Field<MenuItem, List<String>> _f$dietaryTags = Field(
      'dietaryTags', _$dietaryTags,
      key: r'dietary_tags', opt: true, def: const []);
  static bool _$isActive(MenuItem v) => v.isActive;
  static const Field<MenuItem, bool> _f$isActive =
      Field('isActive', _$isActive, key: r'is_active', opt: true, def: true);
  static Map<String, dynamic>? _$metadata(MenuItem v) => v.metadata;
  static const Field<MenuItem, Map<String, dynamic>> _f$metadata =
      Field('metadata', _$metadata, opt: true);
  static DateTime _$createdAt(MenuItem v) => v.createdAt;
  static const Field<MenuItem, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$updatedAt(MenuItem v) => v.updatedAt;
  static const Field<MenuItem, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, key: r'updated_at');

  @override
  final MappableFields<MenuItem> fields = const {
    #id: _f$id,
    #tenantId: _f$tenantId,
    #externalId: _f$externalId,
    #name: _f$name,
    #category: _f$category,
    #description: _f$description,
    #imageUrl: _f$imageUrl,
    #priceCents: _f$priceCents,
    #priceUnit: _f$priceUnit,
    #dietaryTags: _f$dietaryTags,
    #isActive: _f$isActive,
    #metadata: _f$metadata,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static MenuItem _instantiate(DecodingData data) {
    return MenuItem(
        id: data.dec(_f$id),
        tenantId: data.dec(_f$tenantId),
        externalId: data.dec(_f$externalId),
        name: data.dec(_f$name),
        category: data.dec(_f$category),
        description: data.dec(_f$description),
        imageUrl: data.dec(_f$imageUrl),
        priceCents: data.dec(_f$priceCents),
        priceUnit: data.dec(_f$priceUnit),
        dietaryTags: data.dec(_f$dietaryTags),
        isActive: data.dec(_f$isActive),
        metadata: data.dec(_f$metadata),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItem>(map);
  }

  static MenuItem fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItem>(json);
  }
}

mixin MenuItemMappable {
  String toJson() {
    return MenuItemMapper.ensureInitialized()
        .encodeJson<MenuItem>(this as MenuItem);
  }

  Map<String, dynamic> toMap() {
    return MenuItemMapper.ensureInitialized()
        .encodeMap<MenuItem>(this as MenuItem);
  }

  MenuItemCopyWith<MenuItem, MenuItem, MenuItem> get copyWith =>
      _MenuItemCopyWithImpl<MenuItem, MenuItem>(
          this as MenuItem, $identity, $identity);
  @override
  String toString() {
    return MenuItemMapper.ensureInitialized().stringifyValue(this as MenuItem);
  }

  @override
  bool operator ==(Object other) {
    return MenuItemMapper.ensureInitialized()
        .equalsValue(this as MenuItem, other);
  }

  @override
  int get hashCode {
    return MenuItemMapper.ensureInitialized().hashValue(this as MenuItem);
  }
}

extension MenuItemValueCopy<$R, $Out> on ObjectCopyWith<$R, MenuItem, $Out> {
  MenuItemCopyWith<$R, MenuItem, $Out> get $asMenuItem =>
      $base.as((v, t, t2) => _MenuItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuItemCopyWith<$R, $In extends MenuItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get dietaryTags;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata;
  $R call(
      {String? id,
      String? tenantId,
      String? externalId,
      String? name,
      String? category,
      String? description,
      String? imageUrl,
      int? priceCents,
      PriceUnit? priceUnit,
      List<String>? dietaryTags,
      bool? isActive,
      Map<String, dynamic>? metadata,
      DateTime? createdAt,
      DateTime? updatedAt});
  MenuItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuItem, $Out>
    implements MenuItemCopyWith<$R, MenuItem, $Out> {
  _MenuItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuItem> $mapper =
      MenuItemMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
      get dietaryTags => ListCopyWith(
          $value.dietaryTags,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(dietaryTags: v));
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
          String? tenantId,
          Object? externalId = $none,
          String? name,
          Object? category = $none,
          Object? description = $none,
          Object? imageUrl = $none,
          int? priceCents,
          PriceUnit? priceUnit,
          List<String>? dietaryTags,
          bool? isActive,
          Object? metadata = $none,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (tenantId != null) #tenantId: tenantId,
        if (externalId != $none) #externalId: externalId,
        if (name != null) #name: name,
        if (category != $none) #category: category,
        if (description != $none) #description: description,
        if (imageUrl != $none) #imageUrl: imageUrl,
        if (priceCents != null) #priceCents: priceCents,
        if (priceUnit != null) #priceUnit: priceUnit,
        if (dietaryTags != null) #dietaryTags: dietaryTags,
        if (isActive != null) #isActive: isActive,
        if (metadata != $none) #metadata: metadata,
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt
      }));
  @override
  MenuItem $make(CopyWithData data) => MenuItem(
      id: data.get(#id, or: $value.id),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      externalId: data.get(#externalId, or: $value.externalId),
      name: data.get(#name, or: $value.name),
      category: data.get(#category, or: $value.category),
      description: data.get(#description, or: $value.description),
      imageUrl: data.get(#imageUrl, or: $value.imageUrl),
      priceCents: data.get(#priceCents, or: $value.priceCents),
      priceUnit: data.get(#priceUnit, or: $value.priceUnit),
      dietaryTags: data.get(#dietaryTags, or: $value.dietaryTags),
      isActive: data.get(#isActive, or: $value.isActive),
      metadata: data.get(#metadata, or: $value.metadata),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  MenuItemCopyWith<$R2, MenuItem, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MenuItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
