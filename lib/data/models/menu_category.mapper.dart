// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_category.dart';

class MenuCategoryMapper extends ClassMapperBase<MenuCategory> {
  MenuCategoryMapper._();

  static MenuCategoryMapper? _instance;
  static MenuCategoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuCategoryMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MenuCategory';

  static String _$id(MenuCategory v) => v.id;
  static const Field<MenuCategory, String> _f$id = Field('id', _$id);
  static String _$name(MenuCategory v) => v.name;
  static const Field<MenuCategory, String> _f$name = Field('name', _$name);
  static String? _$description(MenuCategory v) => v.description;
  static const Field<MenuCategory, String> _f$description =
      Field('description', _$description, opt: true);
  static String _$icon(MenuCategory v) => v.icon;
  static const Field<MenuCategory, String> _f$icon = Field('icon', _$icon);

  @override
  final MappableFields<MenuCategory> fields = const {
    #id: _f$id,
    #name: _f$name,
    #description: _f$description,
    #icon: _f$icon,
  };

  static MenuCategory _instantiate(DecodingData data) {
    return MenuCategory(
        id: data.dec(_f$id),
        name: data.dec(_f$name),
        description: data.dec(_f$description),
        icon: data.dec(_f$icon));
  }

  @override
  final Function instantiate = _instantiate;

  static MenuCategory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuCategory>(map);
  }

  static MenuCategory fromJson(String json) {
    return ensureInitialized().decodeJson<MenuCategory>(json);
  }
}

mixin MenuCategoryMappable {
  String toJson() {
    return MenuCategoryMapper.ensureInitialized()
        .encodeJson<MenuCategory>(this as MenuCategory);
  }

  Map<String, dynamic> toMap() {
    return MenuCategoryMapper.ensureInitialized()
        .encodeMap<MenuCategory>(this as MenuCategory);
  }

  MenuCategoryCopyWith<MenuCategory, MenuCategory, MenuCategory> get copyWith =>
      _MenuCategoryCopyWithImpl<MenuCategory, MenuCategory>(
          this as MenuCategory, $identity, $identity);
  @override
  String toString() {
    return MenuCategoryMapper.ensureInitialized()
        .stringifyValue(this as MenuCategory);
  }

  @override
  bool operator ==(Object other) {
    return MenuCategoryMapper.ensureInitialized()
        .equalsValue(this as MenuCategory, other);
  }

  @override
  int get hashCode {
    return MenuCategoryMapper.ensureInitialized()
        .hashValue(this as MenuCategory);
  }
}

extension MenuCategoryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuCategory, $Out> {
  MenuCategoryCopyWith<$R, MenuCategory, $Out> get $asMenuCategory =>
      $base.as((v, t, t2) => _MenuCategoryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuCategoryCopyWith<$R, $In extends MenuCategory, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, String? description, String? icon});
  MenuCategoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuCategoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuCategory, $Out>
    implements MenuCategoryCopyWith<$R, MenuCategory, $Out> {
  _MenuCategoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuCategory> $mapper =
      MenuCategoryMapper.ensureInitialized();
  @override
  $R call(
          {String? id,
          String? name,
          Object? description = $none,
          String? icon}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (name != null) #name: name,
        if (description != $none) #description: description,
        if (icon != null) #icon: icon
      }));
  @override
  MenuCategory $make(CopyWithData data) => MenuCategory(
      id: data.get(#id, or: $value.id),
      name: data.get(#name, or: $value.name),
      description: data.get(#description, or: $value.description),
      icon: data.get(#icon, or: $value.icon));

  @override
  MenuCategoryCopyWith<$R2, MenuCategory, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MenuCategoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
