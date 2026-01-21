// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'courier_task.dart';

class CourierTaskMapper extends ClassMapperBase<CourierTask> {
  CourierTaskMapper._();

  static CourierTaskMapper? _instance;
  static CourierTaskMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CourierTaskMapper._());
      CourierProviderMapper.ensureInitialized();
      CourierStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CourierTask';

  static String _$id(CourierTask v) => v.id;
  static const Field<CourierTask, String> _f$id = Field('id', _$id);
  static String _$orderId(CourierTask v) => v.orderId;
  static const Field<CourierTask, String> _f$orderId =
      Field('orderId', _$orderId, key: r'order_id');
  static String _$tenantId(CourierTask v) => v.tenantId;
  static const Field<CourierTask, String> _f$tenantId =
      Field('tenantId', _$tenantId, key: r'tenant_id');
  static CourierProvider _$provider(CourierTask v) => v.provider;
  static const Field<CourierTask, CourierProvider> _f$provider =
      Field('provider', _$provider, opt: true, def: CourierProvider.none);
  static CourierStatus _$status(CourierTask v) => v.status;
  static const Field<CourierTask, CourierStatus> _f$status =
      Field('status', _$status, opt: true, def: CourierStatus.notRequested);
  static String? _$quoteId(CourierTask v) => v.quoteId;
  static const Field<CourierTask, String> _f$quoteId =
      Field('quoteId', _$quoteId, key: r'quote_id', opt: true);
  static String? _$deliveryId(CourierTask v) => v.deliveryId;
  static const Field<CourierTask, String> _f$deliveryId =
      Field('deliveryId', _$deliveryId, key: r'delivery_id', opt: true);
  static String? _$trackingUrl(CourierTask v) => v.trackingUrl;
  static const Field<CourierTask, String> _f$trackingUrl =
      Field('trackingUrl', _$trackingUrl, key: r'tracking_url', opt: true);
  static int? _$feeCents(CourierTask v) => v.feeCents;
  static const Field<CourierTask, int> _f$feeCents =
      Field('feeCents', _$feeCents, key: r'fee_cents', opt: true);
  static String _$currency(CourierTask v) => v.currency;
  static const Field<CourierTask, String> _f$currency =
      Field('currency', _$currency, opt: true, def: 'USD');
  static Map<String, dynamic>? _$rawQuote(CourierTask v) => v.rawQuote;
  static const Field<CourierTask, Map<String, dynamic>> _f$rawQuote =
      Field('rawQuote', _$rawQuote, key: r'raw_quote', opt: true);
  static Map<String, dynamic>? _$rawStatus(CourierTask v) => v.rawStatus;
  static const Field<CourierTask, Map<String, dynamic>> _f$rawStatus =
      Field('rawStatus', _$rawStatus, key: r'raw_status', opt: true);
  static DateTime? _$requestedAt(CourierTask v) => v.requestedAt;
  static const Field<CourierTask, DateTime> _f$requestedAt =
      Field('requestedAt', _$requestedAt, key: r'requested_at', opt: true);
  static DateTime? _$lastStatusAt(CourierTask v) => v.lastStatusAt;
  static const Field<CourierTask, DateTime> _f$lastStatusAt =
      Field('lastStatusAt', _$lastStatusAt, key: r'last_status_at', opt: true);
  static DateTime _$createdAt(CourierTask v) => v.createdAt;
  static const Field<CourierTask, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$updatedAt(CourierTask v) => v.updatedAt;
  static const Field<CourierTask, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, key: r'updated_at');
  static bool? _$liveMode(CourierTask v) => v.liveMode;
  static const Field<CourierTask, bool> _f$liveMode =
      Field('liveMode', _$liveMode, key: r'live_mode', opt: true);

  @override
  final MappableFields<CourierTask> fields = const {
    #id: _f$id,
    #orderId: _f$orderId,
    #tenantId: _f$tenantId,
    #provider: _f$provider,
    #status: _f$status,
    #quoteId: _f$quoteId,
    #deliveryId: _f$deliveryId,
    #trackingUrl: _f$trackingUrl,
    #feeCents: _f$feeCents,
    #currency: _f$currency,
    #rawQuote: _f$rawQuote,
    #rawStatus: _f$rawStatus,
    #requestedAt: _f$requestedAt,
    #lastStatusAt: _f$lastStatusAt,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #liveMode: _f$liveMode,
  };

  static CourierTask _instantiate(DecodingData data) {
    return CourierTask(
        id: data.dec(_f$id),
        orderId: data.dec(_f$orderId),
        tenantId: data.dec(_f$tenantId),
        provider: data.dec(_f$provider),
        status: data.dec(_f$status),
        quoteId: data.dec(_f$quoteId),
        deliveryId: data.dec(_f$deliveryId),
        trackingUrl: data.dec(_f$trackingUrl),
        feeCents: data.dec(_f$feeCents),
        currency: data.dec(_f$currency),
        rawQuote: data.dec(_f$rawQuote),
        rawStatus: data.dec(_f$rawStatus),
        requestedAt: data.dec(_f$requestedAt),
        lastStatusAt: data.dec(_f$lastStatusAt),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt),
        liveMode: data.dec(_f$liveMode));
  }

  @override
  final Function instantiate = _instantiate;

  static CourierTask fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CourierTask>(map);
  }

  static CourierTask fromJson(String json) {
    return ensureInitialized().decodeJson<CourierTask>(json);
  }
}

mixin CourierTaskMappable {
  String toJson() {
    return CourierTaskMapper.ensureInitialized()
        .encodeJson<CourierTask>(this as CourierTask);
  }

  Map<String, dynamic> toMap() {
    return CourierTaskMapper.ensureInitialized()
        .encodeMap<CourierTask>(this as CourierTask);
  }

  CourierTaskCopyWith<CourierTask, CourierTask, CourierTask> get copyWith =>
      _CourierTaskCopyWithImpl<CourierTask, CourierTask>(
          this as CourierTask, $identity, $identity);
  @override
  String toString() {
    return CourierTaskMapper.ensureInitialized()
        .stringifyValue(this as CourierTask);
  }

  @override
  bool operator ==(Object other) {
    return CourierTaskMapper.ensureInitialized()
        .equalsValue(this as CourierTask, other);
  }

  @override
  int get hashCode {
    return CourierTaskMapper.ensureInitialized().hashValue(this as CourierTask);
  }
}

extension CourierTaskValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CourierTask, $Out> {
  CourierTaskCopyWith<$R, CourierTask, $Out> get $asCourierTask =>
      $base.as((v, t, t2) => _CourierTaskCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CourierTaskCopyWith<$R, $In extends CourierTask, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get rawQuote;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get rawStatus;
  $R call(
      {String? id,
      String? orderId,
      String? tenantId,
      CourierProvider? provider,
      CourierStatus? status,
      String? quoteId,
      String? deliveryId,
      String? trackingUrl,
      int? feeCents,
      String? currency,
      Map<String, dynamic>? rawQuote,
      Map<String, dynamic>? rawStatus,
      DateTime? requestedAt,
      DateTime? lastStatusAt,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool? liveMode});
  CourierTaskCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CourierTaskCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CourierTask, $Out>
    implements CourierTaskCopyWith<$R, CourierTask, $Out> {
  _CourierTaskCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CourierTask> $mapper =
      CourierTaskMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get rawQuote => $value.rawQuote != null
          ? MapCopyWith(
              $value.rawQuote!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(rawQuote: v))
          : null;
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get rawStatus => $value.rawStatus != null
          ? MapCopyWith(
              $value.rawStatus!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(rawStatus: v))
          : null;
  @override
  $R call(
          {String? id,
          String? orderId,
          String? tenantId,
          CourierProvider? provider,
          CourierStatus? status,
          Object? quoteId = $none,
          Object? deliveryId = $none,
          Object? trackingUrl = $none,
          Object? feeCents = $none,
          String? currency,
          Object? rawQuote = $none,
          Object? rawStatus = $none,
          Object? requestedAt = $none,
          Object? lastStatusAt = $none,
          DateTime? createdAt,
          DateTime? updatedAt,
          Object? liveMode = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (orderId != null) #orderId: orderId,
        if (tenantId != null) #tenantId: tenantId,
        if (provider != null) #provider: provider,
        if (status != null) #status: status,
        if (quoteId != $none) #quoteId: quoteId,
        if (deliveryId != $none) #deliveryId: deliveryId,
        if (trackingUrl != $none) #trackingUrl: trackingUrl,
        if (feeCents != $none) #feeCents: feeCents,
        if (currency != null) #currency: currency,
        if (rawQuote != $none) #rawQuote: rawQuote,
        if (rawStatus != $none) #rawStatus: rawStatus,
        if (requestedAt != $none) #requestedAt: requestedAt,
        if (lastStatusAt != $none) #lastStatusAt: lastStatusAt,
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt,
        if (liveMode != $none) #liveMode: liveMode
      }));
  @override
  CourierTask $make(CopyWithData data) => CourierTask(
      id: data.get(#id, or: $value.id),
      orderId: data.get(#orderId, or: $value.orderId),
      tenantId: data.get(#tenantId, or: $value.tenantId),
      provider: data.get(#provider, or: $value.provider),
      status: data.get(#status, or: $value.status),
      quoteId: data.get(#quoteId, or: $value.quoteId),
      deliveryId: data.get(#deliveryId, or: $value.deliveryId),
      trackingUrl: data.get(#trackingUrl, or: $value.trackingUrl),
      feeCents: data.get(#feeCents, or: $value.feeCents),
      currency: data.get(#currency, or: $value.currency),
      rawQuote: data.get(#rawQuote, or: $value.rawQuote),
      rawStatus: data.get(#rawStatus, or: $value.rawStatus),
      requestedAt: data.get(#requestedAt, or: $value.requestedAt),
      lastStatusAt: data.get(#lastStatusAt, or: $value.lastStatusAt),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      liveMode: data.get(#liveMode, or: $value.liveMode));

  @override
  CourierTaskCopyWith<$R2, CourierTask, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _CourierTaskCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
