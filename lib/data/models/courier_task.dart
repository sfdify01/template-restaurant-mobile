import 'package:dart_mappable/dart_mappable.dart';
import 'enums.dart';

part 'courier_task.mapper.dart';

/// Courier task model for delivery tracking
@MappableClass(caseStyle: CaseStyle.snakeCase)
class CourierTask with CourierTaskMappable {
  final String id;
  final String orderId;
  final String tenantId;
  final CourierProvider provider;
  final CourierStatus status;
  final String? quoteId;
  final String? deliveryId;
  final String? trackingUrl;
  final int? feeCents;
  final String currency;
  final Map<String, dynamic>? rawQuote;
  final Map<String, dynamic>? rawStatus;
  final DateTime? requestedAt;
  final DateTime? lastStatusAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? liveMode;

  const CourierTask({
    required this.id,
    required this.orderId,
    required this.tenantId,
    this.provider = CourierProvider.none,
    this.status = CourierStatus.notRequested,
    this.quoteId,
    this.deliveryId,
    this.trackingUrl,
    this.feeCents,
    this.currency = 'USD',
    this.rawQuote,
    this.rawStatus,
    this.requestedAt,
    this.lastStatusAt,
    required this.createdAt,
    required this.updatedAt,
    this.liveMode,
  });

  /// Fee in dollars
  double? get feeInDollars => feeCents != null ? feeCents! / 100.0 : null;

  /// Formatted fee
  String? get formattedFee =>
      feeInDollars != null ? '\$${feeInDollars!.toStringAsFixed(2)}' : null;

  /// Whether delivery is in progress
  bool get isInProgress => [
    CourierStatus.dispatching,
    CourierStatus.enRoute,
    CourierStatus.arrived,
  ].contains(status);

  /// Whether delivery has a driver assigned
  bool get hasDriver =>
      status == CourierStatus.enRoute || status == CourierStatus.arrived;

  /// Provider display name
  String get providerName {
    switch (provider) {
      case CourierProvider.doordash:
        return 'DoorDash';
      case CourierProvider.uber:
        return 'Uber';
      case CourierProvider.none:
        return 'None';
    }
  }
}
