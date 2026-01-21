// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'loyalty_profile.dart';

class LoyaltyEventTypeMapper extends EnumMapper<LoyaltyEventType> {
  LoyaltyEventTypeMapper._();

  static LoyaltyEventTypeMapper? _instance;
  static LoyaltyEventTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoyaltyEventTypeMapper._());
    }
    return _instance!;
  }

  static LoyaltyEventType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  LoyaltyEventType decode(dynamic value) {
    switch (value) {
      case 'purchase':
        return LoyaltyEventType.purchase;
      case 'referral_inviter':
        return LoyaltyEventType.referralInviter;
      case 'referral_friend':
        return LoyaltyEventType.referralFriend;
      case 'bonus':
        return LoyaltyEventType.bonus;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(LoyaltyEventType self) {
    switch (self) {
      case LoyaltyEventType.purchase:
        return 'purchase';
      case LoyaltyEventType.referralInviter:
        return 'referral_inviter';
      case LoyaltyEventType.referralFriend:
        return 'referral_friend';
      case LoyaltyEventType.bonus:
        return 'bonus';
    }
  }
}

extension LoyaltyEventTypeMapperExtension on LoyaltyEventType {
  dynamic toValue() {
    LoyaltyEventTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<LoyaltyEventType>(this);
  }
}

class LoyaltyProfileMapper extends ClassMapperBase<LoyaltyProfile> {
  LoyaltyProfileMapper._();

  static LoyaltyProfileMapper? _instance;
  static LoyaltyProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoyaltyProfileMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LoyaltyProfile';

  static String _$id(LoyaltyProfile v) => v.id;
  static const Field<LoyaltyProfile, String> _f$id = Field('id', _$id);
  static String _$tenantId(LoyaltyProfile v) => v.tenantId;
  static const Field<LoyaltyProfile, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String? _$email(LoyaltyProfile v) => v.email;
  static const Field<LoyaltyProfile, String> _f$email =
      Field('email', _$email, opt: true);
  static String? _$phone(LoyaltyProfile v) => v.phone;
  static const Field<LoyaltyProfile, String> _f$phone =
      Field('phone', _$phone, opt: true);
  static String? _$name(LoyaltyProfile v) => v.name;
  static const Field<LoyaltyProfile, String> _f$name =
      Field('name', _$name, opt: true);
  static int _$stars(LoyaltyProfile v) => v.stars;
  static const Field<LoyaltyProfile, int> _f$stars =
      Field('stars', _$stars, opt: true, def: 0);
  static String _$referralCode(LoyaltyProfile v) => v.referralCode;
  static const Field<LoyaltyProfile, String> _f$referralCode =
      Field('referralCode', _$referralCode, key: r'referral_code');
  static String? _$referredBy(LoyaltyProfile v) => v.referredBy;
  static const Field<LoyaltyProfile, String> _f$referredBy =
      Field('referredBy', _$referredBy, key: r'referred_by', opt: true);
  static bool _$firstOrderCompleted(LoyaltyProfile v) => v.firstOrderCompleted;
  static const Field<LoyaltyProfile, bool> _f$firstOrderCompleted = Field(
      'firstOrderCompleted', _$firstOrderCompleted,
      key: r'first_order_completed', opt: true, def: false);
  static DateTime _$createdAt(LoyaltyProfile v) => v.createdAt;
  static const Field<LoyaltyProfile, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$updatedAt(LoyaltyProfile v) => v.updatedAt;
  static const Field<LoyaltyProfile, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, key: r'updated_at');

  @override
  final MappableFields<LoyaltyProfile> fields = const {
    #id: _f$id,
    #tenantId: _f$tenantId,
    #email: _f$email,
    #phone: _f$phone,
    #name: _f$name,
    #stars: _f$stars,
    #referralCode: _f$referralCode,
    #referredBy: _f$referredBy,
    #firstOrderCompleted: _f$firstOrderCompleted,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static LoyaltyProfile _instantiate(DecodingData data) {
    return LoyaltyProfile(
        id: data.dec(_f$id),
        tenantId: data.dec(_f$tenantId),
        email: data.dec(_f$email),
        phone: data.dec(_f$phone),
        name: data.dec(_f$name),
        stars: data.dec(_f$stars),
        referralCode: data.dec(_f$referralCode),
        referredBy: data.dec(_f$referredBy),
        firstOrderCompleted: data.dec(_f$firstOrderCompleted),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static LoyaltyProfile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LoyaltyProfile>(map);
  }

  static LoyaltyProfile fromJson(String json) {
    return ensureInitialized().decodeJson<LoyaltyProfile>(json);
  }
}

mixin LoyaltyProfileMappable {
  String toJson() {
    return LoyaltyProfileMapper.ensureInitialized()
        .encodeJson<LoyaltyProfile>(this as LoyaltyProfile);
  }

  Map<String, dynamic> toMap() {
    return LoyaltyProfileMapper.ensureInitialized()
        .encodeMap<LoyaltyProfile>(this as LoyaltyProfile);
  }

  LoyaltyProfileCopyWith<LoyaltyProfile, LoyaltyProfile, LoyaltyProfile>
      get copyWith =>
          _LoyaltyProfileCopyWithImpl<LoyaltyProfile, LoyaltyProfile>(
              this as LoyaltyProfile, $identity, $identity);
  @override
  String toString() {
    return LoyaltyProfileMapper.ensureInitialized()
        .stringifyValue(this as LoyaltyProfile);
  }

  @override
  bool operator ==(Object other) {
    return LoyaltyProfileMapper.ensureInitialized()
        .equalsValue(this as LoyaltyProfile, other);
  }

  @override
  int get hashCode {
    return LoyaltyProfileMapper.ensureInitialized()
        .hashValue(this as LoyaltyProfile);
  }
}

extension LoyaltyProfileValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LoyaltyProfile, $Out> {
  LoyaltyProfileCopyWith<$R, LoyaltyProfile, $Out> get $asLoyaltyProfile =>
      $base.as((v, t, t2) => _LoyaltyProfileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LoyaltyProfileCopyWith<$R, $In extends LoyaltyProfile, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? id,
      String? tenantId,
      String? email,
      String? phone,
      String? name,
      int? stars,
      String? referralCode,
      String? referredBy,
      bool? firstOrderCompleted,
      DateTime? createdAt,
      DateTime? updatedAt});
  LoyaltyProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _LoyaltyProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LoyaltyProfile, $Out>
    implements LoyaltyProfileCopyWith<$R, LoyaltyProfile, $Out> {
  _LoyaltyProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LoyaltyProfile> $mapper =
      LoyaltyProfileMapper.ensureInitialized();
  @override
  $R call(
          {String? id,
          String? tenantId,
          Object? email = $none,
          Object? phone = $none,
          Object? name = $none,
          int? stars,
          String? referralCode,
          Object? referredBy = $none,
          bool? firstOrderCompleted,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (tenantId != null) #tenantId: tenantId,
        if (email != $none) #email: email,
        if (phone != $none) #phone: phone,
        if (name != $none) #name: name,
        if (stars != null) #stars: stars,
        if (referralCode != null) #referralCode: referralCode,
        if (referredBy != $none) #referredBy: referredBy,
        if (firstOrderCompleted != null)
          #firstOrderCompleted: firstOrderCompleted,
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt
      }));
  @override
  LoyaltyProfile $make(CopyWithData data) => LoyaltyProfile(
      id: data.get(#id, or: $value.id),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      email: data.get(#email, or: $value.email),
      phone: data.get(#phone, or: $value.phone),
      name: data.get(#name, or: $value.name),
      stars: data.get(#stars, or: $value.stars),
      referralCode: data.get(#referralCode, or: $value.referralCode),
      referredBy: data.get(#referredBy, or: $value.referredBy),
      firstOrderCompleted:
          data.get(#firstOrderCompleted, or: $value.firstOrderCompleted),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  LoyaltyProfileCopyWith<$R2, LoyaltyProfile, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _LoyaltyProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LoyaltyEventMapper extends ClassMapperBase<LoyaltyEvent> {
  LoyaltyEventMapper._();

  static LoyaltyEventMapper? _instance;
  static LoyaltyEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoyaltyEventMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LoyaltyEvent';

  static String _$id(LoyaltyEvent v) => v.id;
  static const Field<LoyaltyEvent, String> _f$id = Field('id', _$id);
  static String _$profileId(LoyaltyEvent v) => v.profileId;
  static const Field<LoyaltyEvent, String> _f$profileId =
      Field('profileId', _$profileId, key: r'profile_id');
  static String _$tenantId(LoyaltyEvent v) => v.tenantId;
  static const Field<LoyaltyEvent, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String _$eventType(LoyaltyEvent v) => v.eventType;
  static const Field<LoyaltyEvent, String> _f$eventType =
      Field('eventType', _$eventType, key: r'type');
  static int _$starsAmount(LoyaltyEvent v) => v.starsAmount;
  static const Field<LoyaltyEvent, int> _f$starsAmount =
      Field('starsAmount', _$starsAmount, key: r'stars');
  static String? _$orderId(LoyaltyEvent v) => v.orderId;
  static const Field<LoyaltyEvent, String> _f$orderId =
      Field('orderId', _$orderId, key: r'order_id', opt: true);
  static String? _$description(LoyaltyEvent v) => v.description;
  static const Field<LoyaltyEvent, String> _f$description =
      Field('description', _$description, opt: true);
  static DateTime _$createdAt(LoyaltyEvent v) => v.createdAt;
  static const Field<LoyaltyEvent, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');

  @override
  final MappableFields<LoyaltyEvent> fields = const {
    #id: _f$id,
    #profileId: _f$profileId,
    #tenantId: _f$tenantId,
    #eventType: _f$eventType,
    #starsAmount: _f$starsAmount,
    #orderId: _f$orderId,
    #description: _f$description,
    #createdAt: _f$createdAt,
  };

  static LoyaltyEvent _instantiate(DecodingData data) {
    return LoyaltyEvent(
        id: data.dec(_f$id),
        profileId: data.dec(_f$profileId),
        tenantId: data.dec(_f$tenantId),
        eventType: data.dec(_f$eventType),
        starsAmount: data.dec(_f$starsAmount),
        orderId: data.dec(_f$orderId),
        description: data.dec(_f$description),
        createdAt: data.dec(_f$createdAt));
  }

  @override
  final Function instantiate = _instantiate;

  static LoyaltyEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LoyaltyEvent>(map);
  }

  static LoyaltyEvent fromJson(String json) {
    return ensureInitialized().decodeJson<LoyaltyEvent>(json);
  }
}

mixin LoyaltyEventMappable {
  String toJson() {
    return LoyaltyEventMapper.ensureInitialized()
        .encodeJson<LoyaltyEvent>(this as LoyaltyEvent);
  }

  Map<String, dynamic> toMap() {
    return LoyaltyEventMapper.ensureInitialized()
        .encodeMap<LoyaltyEvent>(this as LoyaltyEvent);
  }

  LoyaltyEventCopyWith<LoyaltyEvent, LoyaltyEvent, LoyaltyEvent> get copyWith =>
      _LoyaltyEventCopyWithImpl<LoyaltyEvent, LoyaltyEvent>(
          this as LoyaltyEvent, $identity, $identity);
  @override
  String toString() {
    return LoyaltyEventMapper.ensureInitialized()
        .stringifyValue(this as LoyaltyEvent);
  }

  @override
  bool operator ==(Object other) {
    return LoyaltyEventMapper.ensureInitialized()
        .equalsValue(this as LoyaltyEvent, other);
  }

  @override
  int get hashCode {
    return LoyaltyEventMapper.ensureInitialized()
        .hashValue(this as LoyaltyEvent);
  }
}

extension LoyaltyEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LoyaltyEvent, $Out> {
  LoyaltyEventCopyWith<$R, LoyaltyEvent, $Out> get $asLoyaltyEvent =>
      $base.as((v, t, t2) => _LoyaltyEventCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LoyaltyEventCopyWith<$R, $In extends LoyaltyEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? id,
      String? profileId,
      String? tenantId,
      String? eventType,
      int? starsAmount,
      String? orderId,
      String? description,
      DateTime? createdAt});
  LoyaltyEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LoyaltyEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LoyaltyEvent, $Out>
    implements LoyaltyEventCopyWith<$R, LoyaltyEvent, $Out> {
  _LoyaltyEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LoyaltyEvent> $mapper =
      LoyaltyEventMapper.ensureInitialized();
  @override
  $R call(
          {String? id,
          String? profileId,
          String? tenantId,
          String? eventType,
          int? starsAmount,
          Object? orderId = $none,
          Object? description = $none,
          DateTime? createdAt}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (profileId != null) #profileId: profileId,
        if (tenantId != null) #tenantId: tenantId,
        if (eventType != null) #eventType: eventType,
        if (starsAmount != null) #starsAmount: starsAmount,
        if (orderId != $none) #orderId: orderId,
        if (description != $none) #description: description,
        if (createdAt != null) #createdAt: createdAt
      }));
  @override
  LoyaltyEvent $make(CopyWithData data) => LoyaltyEvent(
      id: data.get(#id, or: $value.id),
      profileId: data.get(#profileId, or: $value.profileId),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      eventType: data.get(#eventType, or: $value.eventType),
      starsAmount: data.get(#starsAmount, or: $value.starsAmount),
      orderId: data.get(#orderId, or: $value.orderId),
      description: data.get(#description, or: $value.description),
      createdAt: data.get(#createdAt, or: $value.createdAt));

  @override
  LoyaltyEventCopyWith<$R2, LoyaltyEvent, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _LoyaltyEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
