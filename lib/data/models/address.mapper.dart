// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'address.dart';

class AddressMapper extends ClassMapperBase<Address> {
  AddressMapper._();

  static AddressMapper? _instance;
  static AddressMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddressMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Address';

  static String _$id(Address v) => v.id;
  static const Field<Address, String> _f$id = Field('id', _$id);
  static String _$tenantId(Address v) => v.tenantId;
  static const Field<Address, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String? _$customerId(Address v) => v.customerId;
  static const Field<Address, String> _f$customerId =
      Field('customerId', _$customerId, key: r'customer_id', opt: true);
  static String? _$label(Address v) => v.label;
  static const Field<Address, String> _f$label =
      Field('label', _$label, opt: true);
  static String _$streetLine1(Address v) => v.streetLine1;
  static const Field<Address, String> _f$streetLine1 =
      Field('streetLine1', _$streetLine1, key: r'street_line1');
  static String? _$streetLine2(Address v) => v.streetLine2;
  static const Field<Address, String> _f$streetLine2 =
      Field('streetLine2', _$streetLine2, key: r'street_line2', opt: true);
  static String _$city(Address v) => v.city;
  static const Field<Address, String> _f$city = Field('city', _$city);
  static String _$state(Address v) => v.state;
  static const Field<Address, String> _f$state = Field('state', _$state);
  static String _$postalCode(Address v) => v.postalCode;
  static const Field<Address, String> _f$postalCode =
      Field('postalCode', _$postalCode, key: r'postal_code');
  static String _$country(Address v) => v.country;
  static const Field<Address, String> _f$country =
      Field('country', _$country, opt: true, def: 'US');
  static double? _$latitude(Address v) => v.latitude;
  static const Field<Address, double> _f$latitude =
      Field('latitude', _$latitude, opt: true);
  static double? _$longitude(Address v) => v.longitude;
  static const Field<Address, double> _f$longitude =
      Field('longitude', _$longitude, opt: true);
  static String? _$deliveryInstructions(Address v) => v.deliveryInstructions;
  static const Field<Address, String> _f$deliveryInstructions = Field(
      'deliveryInstructions', _$deliveryInstructions,
      key: r'delivery_instructions', opt: true);
  static bool _$isDefault(Address v) => v.isDefault;
  static const Field<Address, bool> _f$isDefault = Field(
      'isDefault', _$isDefault,
      key: r'is_default', opt: true, def: false);
  static DateTime _$createdAt(Address v) => v.createdAt;
  static const Field<Address, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$updatedAt(Address v) => v.updatedAt;
  static const Field<Address, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, key: r'updated_at');

  @override
  final MappableFields<Address> fields = const {
    #id: _f$id,
    #tenantId: _f$tenantId,
    #customerId: _f$customerId,
    #label: _f$label,
    #streetLine1: _f$streetLine1,
    #streetLine2: _f$streetLine2,
    #city: _f$city,
    #state: _f$state,
    #postalCode: _f$postalCode,
    #country: _f$country,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
    #deliveryInstructions: _f$deliveryInstructions,
    #isDefault: _f$isDefault,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static Address _instantiate(DecodingData data) {
    return Address(
        id: data.dec(_f$id),
        tenantId: data.dec(_f$tenantId),
        customerId: data.dec(_f$customerId),
        label: data.dec(_f$label),
        streetLine1: data.dec(_f$streetLine1),
        streetLine2: data.dec(_f$streetLine2),
        city: data.dec(_f$city),
        state: data.dec(_f$state),
        postalCode: data.dec(_f$postalCode),
        country: data.dec(_f$country),
        latitude: data.dec(_f$latitude),
        longitude: data.dec(_f$longitude),
        deliveryInstructions: data.dec(_f$deliveryInstructions),
        isDefault: data.dec(_f$isDefault),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static Address fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Address>(map);
  }

  static Address fromJson(String json) {
    return ensureInitialized().decodeJson<Address>(json);
  }
}

mixin AddressMappable {
  String toJson() {
    return AddressMapper.ensureInitialized()
        .encodeJson<Address>(this as Address);
  }

  Map<String, dynamic> toMap() {
    return AddressMapper.ensureInitialized()
        .encodeMap<Address>(this as Address);
  }

  AddressCopyWith<Address, Address, Address> get copyWith =>
      _AddressCopyWithImpl<Address, Address>(
          this as Address, $identity, $identity);
  @override
  String toString() {
    return AddressMapper.ensureInitialized().stringifyValue(this as Address);
  }

  @override
  bool operator ==(Object other) {
    return AddressMapper.ensureInitialized()
        .equalsValue(this as Address, other);
  }

  @override
  int get hashCode {
    return AddressMapper.ensureInitialized().hashValue(this as Address);
  }
}

extension AddressValueCopy<$R, $Out> on ObjectCopyWith<$R, Address, $Out> {
  AddressCopyWith<$R, Address, $Out> get $asAddress =>
      $base.as((v, t, t2) => _AddressCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AddressCopyWith<$R, $In extends Address, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? id,
      String? tenantId,
      String? customerId,
      String? label,
      String? streetLine1,
      String? streetLine2,
      String? city,
      String? state,
      String? postalCode,
      String? country,
      double? latitude,
      double? longitude,
      String? deliveryInstructions,
      bool? isDefault,
      DateTime? createdAt,
      DateTime? updatedAt});
  AddressCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AddressCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Address, $Out>
    implements AddressCopyWith<$R, Address, $Out> {
  _AddressCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Address> $mapper =
      AddressMapper.ensureInitialized();
  @override
  $R call(
          {String? id,
          String? tenantId,
          Object? customerId = $none,
          Object? label = $none,
          String? streetLine1,
          Object? streetLine2 = $none,
          String? city,
          String? state,
          String? postalCode,
          String? country,
          Object? latitude = $none,
          Object? longitude = $none,
          Object? deliveryInstructions = $none,
          bool? isDefault,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (tenantId != null) #tenantId: tenantId,
        if (customerId != $none) #customerId: customerId,
        if (label != $none) #label: label,
        if (streetLine1 != null) #streetLine1: streetLine1,
        if (streetLine2 != $none) #streetLine2: streetLine2,
        if (city != null) #city: city,
        if (state != null) #state: state,
        if (postalCode != null) #postalCode: postalCode,
        if (country != null) #country: country,
        if (latitude != $none) #latitude: latitude,
        if (longitude != $none) #longitude: longitude,
        if (deliveryInstructions != $none)
          #deliveryInstructions: deliveryInstructions,
        if (isDefault != null) #isDefault: isDefault,
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt
      }));
  @override
  Address $make(CopyWithData data) => Address(
      id: data.get(#id, or: $value.id),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      customerId: data.get(#customerId, or: $value.customerId),
      label: data.get(#label, or: $value.label),
      streetLine1: data.get(#streetLine1, or: $value.streetLine1),
      streetLine2: data.get(#streetLine2, or: $value.streetLine2),
      city: data.get(#city, or: $value.city),
      state: data.get(#state, or: $value.state),
      postalCode: data.get(#postalCode, or: $value.postalCode),
      country: data.get(#country, or: $value.country),
      latitude: data.get(#latitude, or: $value.latitude),
      longitude: data.get(#longitude, or: $value.longitude),
      deliveryInstructions:
          data.get(#deliveryInstructions, or: $value.deliveryInstructions),
      isDefault: data.get(#isDefault, or: $value.isDefault),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  AddressCopyWith<$R2, Address, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AddressCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
