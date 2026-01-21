// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer.dart';

class CustomerMapper extends ClassMapperBase<Customer> {
  CustomerMapper._();

  static CustomerMapper? _instance;
  static CustomerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerMapper._());
      FulfillmentTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Customer';

  static String _$id(Customer v) => v.id;
  static const Field<Customer, String> _f$id = Field('id', _$id);
  static String _$tenantId(Customer v) => v.tenantId;
  static const Field<Customer, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String? _$authUserId(Customer v) => v.authUserId;
  static const Field<Customer, String> _f$authUserId =
      Field('authUserId', _$authUserId, key: r'auth_user_id', opt: true);
  static String? _$firstName(Customer v) => v.firstName;
  static const Field<Customer, String> _f$firstName =
      Field('firstName', _$firstName, key: r'first_name', opt: true);
  static String? _$lastName(Customer v) => v.lastName;
  static const Field<Customer, String> _f$lastName =
      Field('lastName', _$lastName, key: r'last_name', opt: true);
  static String? _$email(Customer v) => v.email;
  static const Field<Customer, String> _f$email =
      Field('email', _$email, opt: true);
  static String? _$phone(Customer v) => v.phone;
  static const Field<Customer, String> _f$phone =
      Field('phone', _$phone, opt: true);
  static bool _$marketingOptIn(Customer v) => v.marketingOptIn;
  static const Field<Customer, bool> _f$marketingOptIn = Field(
      'marketingOptIn', _$marketingOptIn,
      key: r'marketing_opt_in', opt: true, def: false);
  static FulfillmentType? _$defaultFulfillmentType(Customer v) =>
      v.defaultFulfillmentType;
  static const Field<Customer, FulfillmentType> _f$defaultFulfillmentType =
      Field('defaultFulfillmentType', _$defaultFulfillmentType,
          key: r'default_fulfillment_type', opt: true);
  static Map<String, dynamic>? _$metadata(Customer v) => v.metadata;
  static const Field<Customer, Map<String, dynamic>> _f$metadata =
      Field('metadata', _$metadata, opt: true);
  static DateTime _$createdAt(Customer v) => v.createdAt;
  static const Field<Customer, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$updatedAt(Customer v) => v.updatedAt;
  static const Field<Customer, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, key: r'updated_at');

  @override
  final MappableFields<Customer> fields = const {
    #id: _f$id,
    #tenantId: _f$tenantId,
    #authUserId: _f$authUserId,
    #firstName: _f$firstName,
    #lastName: _f$lastName,
    #email: _f$email,
    #phone: _f$phone,
    #marketingOptIn: _f$marketingOptIn,
    #defaultFulfillmentType: _f$defaultFulfillmentType,
    #metadata: _f$metadata,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static Customer _instantiate(DecodingData data) {
    return Customer(
        id: data.dec(_f$id),
        tenantId: data.dec(_f$tenantId),
        authUserId: data.dec(_f$authUserId),
        firstName: data.dec(_f$firstName),
        lastName: data.dec(_f$lastName),
        email: data.dec(_f$email),
        phone: data.dec(_f$phone),
        marketingOptIn: data.dec(_f$marketingOptIn),
        defaultFulfillmentType: data.dec(_f$defaultFulfillmentType),
        metadata: data.dec(_f$metadata),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static Customer fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Customer>(map);
  }

  static Customer fromJson(String json) {
    return ensureInitialized().decodeJson<Customer>(json);
  }
}

mixin CustomerMappable {
  String toJson() {
    return CustomerMapper.ensureInitialized()
        .encodeJson<Customer>(this as Customer);
  }

  Map<String, dynamic> toMap() {
    return CustomerMapper.ensureInitialized()
        .encodeMap<Customer>(this as Customer);
  }

  CustomerCopyWith<Customer, Customer, Customer> get copyWith =>
      _CustomerCopyWithImpl<Customer, Customer>(
          this as Customer, $identity, $identity);
  @override
  String toString() {
    return CustomerMapper.ensureInitialized().stringifyValue(this as Customer);
  }

  @override
  bool operator ==(Object other) {
    return CustomerMapper.ensureInitialized()
        .equalsValue(this as Customer, other);
  }

  @override
  int get hashCode {
    return CustomerMapper.ensureInitialized().hashValue(this as Customer);
  }
}

extension CustomerValueCopy<$R, $Out> on ObjectCopyWith<$R, Customer, $Out> {
  CustomerCopyWith<$R, Customer, $Out> get $asCustomer =>
      $base.as((v, t, t2) => _CustomerCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerCopyWith<$R, $In extends Customer, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata;
  $R call(
      {String? id,
      String? tenantId,
      String? authUserId,
      String? firstName,
      String? lastName,
      String? email,
      String? phone,
      bool? marketingOptIn,
      FulfillmentType? defaultFulfillmentType,
      Map<String, dynamic>? metadata,
      DateTime? createdAt,
      DateTime? updatedAt});
  CustomerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CustomerCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Customer, $Out>
    implements CustomerCopyWith<$R, Customer, $Out> {
  _CustomerCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Customer> $mapper =
      CustomerMapper.ensureInitialized();
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
          Object? authUserId = $none,
          Object? firstName = $none,
          Object? lastName = $none,
          Object? email = $none,
          Object? phone = $none,
          bool? marketingOptIn,
          Object? defaultFulfillmentType = $none,
          Object? metadata = $none,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (tenantId != null) #tenantId: tenantId,
        if (authUserId != $none) #authUserId: authUserId,
        if (firstName != $none) #firstName: firstName,
        if (lastName != $none) #lastName: lastName,
        if (email != $none) #email: email,
        if (phone != $none) #phone: phone,
        if (marketingOptIn != null) #marketingOptIn: marketingOptIn,
        if (defaultFulfillmentType != $none)
          #defaultFulfillmentType: defaultFulfillmentType,
        if (metadata != $none) #metadata: metadata,
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt
      }));
  @override
  Customer $make(CopyWithData data) => Customer(
      id: data.get(#id, or: $value.id),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      authUserId: data.get(#authUserId, or: $value.authUserId),
      firstName: data.get(#firstName, or: $value.firstName),
      lastName: data.get(#lastName, or: $value.lastName),
      email: data.get(#email, or: $value.email),
      phone: data.get(#phone, or: $value.phone),
      marketingOptIn: data.get(#marketingOptIn, or: $value.marketingOptIn),
      defaultFulfillmentType:
          data.get(#defaultFulfillmentType, or: $value.defaultFulfillmentType),
      metadata: data.get(#metadata, or: $value.metadata),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  CustomerCopyWith<$R2, Customer, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _CustomerCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
