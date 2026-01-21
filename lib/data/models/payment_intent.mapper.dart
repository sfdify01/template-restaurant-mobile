// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment_intent.dart';

class PaymentIntentStatusMapper extends EnumMapper<PaymentIntentStatus> {
  PaymentIntentStatusMapper._();

  static PaymentIntentStatusMapper? _instance;
  static PaymentIntentStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentIntentStatusMapper._());
    }
    return _instance!;
  }

  static PaymentIntentStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PaymentIntentStatus decode(dynamic value) {
    switch (value) {
      case 'requires_payment_method':
        return PaymentIntentStatus.requiresPaymentMethod;
      case 'requires_confirmation':
        return PaymentIntentStatus.requiresConfirmation;
      case 'requires_action':
        return PaymentIntentStatus.requiresAction;
      case 'processing':
        return PaymentIntentStatus.processing;
      case 'requires_capture':
        return PaymentIntentStatus.requiresCapture;
      case 'canceled':
        return PaymentIntentStatus.canceled;
      case 'succeeded':
        return PaymentIntentStatus.succeeded;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PaymentIntentStatus self) {
    switch (self) {
      case PaymentIntentStatus.requiresPaymentMethod:
        return 'requires_payment_method';
      case PaymentIntentStatus.requiresConfirmation:
        return 'requires_confirmation';
      case PaymentIntentStatus.requiresAction:
        return 'requires_action';
      case PaymentIntentStatus.processing:
        return 'processing';
      case PaymentIntentStatus.requiresCapture:
        return 'requires_capture';
      case PaymentIntentStatus.canceled:
        return 'canceled';
      case PaymentIntentStatus.succeeded:
        return 'succeeded';
    }
  }
}

extension PaymentIntentStatusMapperExtension on PaymentIntentStatus {
  dynamic toValue() {
    PaymentIntentStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PaymentIntentStatus>(this);
  }
}

class PaymentIntentMapper extends ClassMapperBase<PaymentIntent> {
  PaymentIntentMapper._();

  static PaymentIntentMapper? _instance;
  static PaymentIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentIntentMapper._());
      PaymentIntentStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PaymentIntent';

  static String _$id(PaymentIntent v) => v.id;
  static const Field<PaymentIntent, String> _f$id = Field('id', _$id);
  static String _$tenantId(PaymentIntent v) => v.tenantId;
  static const Field<PaymentIntent, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static String _$orderId(PaymentIntent v) => v.orderId;
  static const Field<PaymentIntent, String> _f$orderId =
      Field('orderId', _$orderId, key: r'order_id');
  static String _$stripePaymentIntentId(PaymentIntent v) =>
      v.stripePaymentIntentId;
  static const Field<PaymentIntent, String> _f$stripePaymentIntentId = Field(
      'stripePaymentIntentId', _$stripePaymentIntentId,
      key: r'stripe_payment_intent_id');
  static int _$amountCents(PaymentIntent v) => v.amountCents;
  static const Field<PaymentIntent, int> _f$amountCents =
      Field('amountCents', _$amountCents, key: r'amount_cents');
  static String _$currency(PaymentIntent v) => v.currency;
  static const Field<PaymentIntent, String> _f$currency =
      Field('currency', _$currency, opt: true, def: 'USD');
  static PaymentIntentStatus _$status(PaymentIntent v) => v.status;
  static const Field<PaymentIntent, PaymentIntentStatus> _f$status = Field(
      'status', _$status,
      opt: true, def: PaymentIntentStatus.requiresPaymentMethod);
  static String? _$clientSecret(PaymentIntent v) => v.clientSecret;
  static const Field<PaymentIntent, String> _f$clientSecret =
      Field('clientSecret', _$clientSecret, key: r'client_secret', opt: true);
  static String? _$customerId(PaymentIntent v) => v.customerId;
  static const Field<PaymentIntent, String> _f$customerId =
      Field('customerId', _$customerId, key: r'customer_id', opt: true);
  static String? _$stripeCustomerId(PaymentIntent v) => v.stripeCustomerId;
  static const Field<PaymentIntent, String> _f$stripeCustomerId = Field(
      'stripeCustomerId', _$stripeCustomerId,
      key: r'stripe_customer_id', opt: true);
  static int? _$applicationFeeCents(PaymentIntent v) => v.applicationFeeCents;
  static const Field<PaymentIntent, int> _f$applicationFeeCents = Field(
      'applicationFeeCents', _$applicationFeeCents,
      key: r'application_fee_cents', opt: true);
  static Map<String, dynamic>? _$metadata(PaymentIntent v) => v.metadata;
  static const Field<PaymentIntent, Map<String, dynamic>> _f$metadata =
      Field('metadata', _$metadata, opt: true);
  static DateTime _$createdAt(PaymentIntent v) => v.createdAt;
  static const Field<PaymentIntent, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$updatedAt(PaymentIntent v) => v.updatedAt;
  static const Field<PaymentIntent, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, key: r'updated_at');

  @override
  final MappableFields<PaymentIntent> fields = const {
    #id: _f$id,
    #tenantId: _f$tenantId,
    #orderId: _f$orderId,
    #stripePaymentIntentId: _f$stripePaymentIntentId,
    #amountCents: _f$amountCents,
    #currency: _f$currency,
    #status: _f$status,
    #clientSecret: _f$clientSecret,
    #customerId: _f$customerId,
    #stripeCustomerId: _f$stripeCustomerId,
    #applicationFeeCents: _f$applicationFeeCents,
    #metadata: _f$metadata,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static PaymentIntent _instantiate(DecodingData data) {
    return PaymentIntent(
        id: data.dec(_f$id),
        tenantId: data.dec(_f$tenantId),
        orderId: data.dec(_f$orderId),
        stripePaymentIntentId: data.dec(_f$stripePaymentIntentId),
        amountCents: data.dec(_f$amountCents),
        currency: data.dec(_f$currency),
        status: data.dec(_f$status),
        clientSecret: data.dec(_f$clientSecret),
        customerId: data.dec(_f$customerId),
        stripeCustomerId: data.dec(_f$stripeCustomerId),
        applicationFeeCents: data.dec(_f$applicationFeeCents),
        metadata: data.dec(_f$metadata),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static PaymentIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PaymentIntent>(map);
  }

  static PaymentIntent fromJson(String json) {
    return ensureInitialized().decodeJson<PaymentIntent>(json);
  }
}

mixin PaymentIntentMappable {
  String toJson() {
    return PaymentIntentMapper.ensureInitialized()
        .encodeJson<PaymentIntent>(this as PaymentIntent);
  }

  Map<String, dynamic> toMap() {
    return PaymentIntentMapper.ensureInitialized()
        .encodeMap<PaymentIntent>(this as PaymentIntent);
  }

  PaymentIntentCopyWith<PaymentIntent, PaymentIntent, PaymentIntent>
      get copyWith => _PaymentIntentCopyWithImpl<PaymentIntent, PaymentIntent>(
          this as PaymentIntent, $identity, $identity);
  @override
  String toString() {
    return PaymentIntentMapper.ensureInitialized()
        .stringifyValue(this as PaymentIntent);
  }

  @override
  bool operator ==(Object other) {
    return PaymentIntentMapper.ensureInitialized()
        .equalsValue(this as PaymentIntent, other);
  }

  @override
  int get hashCode {
    return PaymentIntentMapper.ensureInitialized()
        .hashValue(this as PaymentIntent);
  }
}

extension PaymentIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PaymentIntent, $Out> {
  PaymentIntentCopyWith<$R, PaymentIntent, $Out> get $asPaymentIntent =>
      $base.as((v, t, t2) => _PaymentIntentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PaymentIntentCopyWith<$R, $In extends PaymentIntent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get metadata;
  $R call(
      {String? id,
      String? tenantId,
      String? orderId,
      String? stripePaymentIntentId,
      int? amountCents,
      String? currency,
      PaymentIntentStatus? status,
      String? clientSecret,
      String? customerId,
      String? stripeCustomerId,
      int? applicationFeeCents,
      Map<String, dynamic>? metadata,
      DateTime? createdAt,
      DateTime? updatedAt});
  PaymentIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PaymentIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PaymentIntent, $Out>
    implements PaymentIntentCopyWith<$R, PaymentIntent, $Out> {
  _PaymentIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PaymentIntent> $mapper =
      PaymentIntentMapper.ensureInitialized();
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
          String? orderId,
          String? stripePaymentIntentId,
          int? amountCents,
          String? currency,
          PaymentIntentStatus? status,
          Object? clientSecret = $none,
          Object? customerId = $none,
          Object? stripeCustomerId = $none,
          Object? applicationFeeCents = $none,
          Object? metadata = $none,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (tenantId != null) #tenantId: tenantId,
        if (orderId != null) #orderId: orderId,
        if (stripePaymentIntentId != null)
          #stripePaymentIntentId: stripePaymentIntentId,
        if (amountCents != null) #amountCents: amountCents,
        if (currency != null) #currency: currency,
        if (status != null) #status: status,
        if (clientSecret != $none) #clientSecret: clientSecret,
        if (customerId != $none) #customerId: customerId,
        if (stripeCustomerId != $none) #stripeCustomerId: stripeCustomerId,
        if (applicationFeeCents != $none)
          #applicationFeeCents: applicationFeeCents,
        if (metadata != $none) #metadata: metadata,
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt
      }));
  @override
  PaymentIntent $make(CopyWithData data) => PaymentIntent(
      id: data.get(#id, or: $value.id),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      orderId: data.get(#orderId, or: $value.orderId),
      stripePaymentIntentId:
          data.get(#stripePaymentIntentId, or: $value.stripePaymentIntentId),
      amountCents: data.get(#amountCents, or: $value.amountCents),
      currency: data.get(#currency, or: $value.currency),
      status: data.get(#status, or: $value.status),
      clientSecret: data.get(#clientSecret, or: $value.clientSecret),
      customerId: data.get(#customerId, or: $value.customerId),
      stripeCustomerId:
          data.get(#stripeCustomerId, or: $value.stripeCustomerId),
      applicationFeeCents:
          data.get(#applicationFeeCents, or: $value.applicationFeeCents),
      metadata: data.get(#metadata, or: $value.metadata),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  PaymentIntentCopyWith<$R2, PaymentIntent, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PaymentIntentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
