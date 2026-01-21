import 'package:dart_mappable/dart_mappable.dart';
import 'enums.dart';
import 'order_item.dart';
import 'address.dart';

part 'order.mapper.dart';

/// Order model matching Supabase orders table
@MappableClass(caseStyle: CaseStyle.snakeCase)
class Order with OrderMappable {
  final String id;
  final int orderNumber;
  final String tenantId;
  final String? customerId;
  final String? deliveryAddressId;
  final FulfillmentType fulfillmentType;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final OrderSource source;
  final DateTime? scheduledFor;
  final String currency;
  final int subtotalCents;
  final int taxCents;
  final int tipCents;
  final int deliveryFeeCents;
  final int serviceFeeCents;
  final int discountCents;
  final int totalCents;
  final int itemsCount;
  final double weightOz;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? specialInstructions;
  final String? fulfillmentInstructions;
  final DateTime? pickupEta;
  final DateTime? deliveryEta;
  final String? createdBy;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (populated from joins)
  final List<OrderItem>? items;
  final Address? deliveryAddress;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.tenantId,
    this.customerId,
    this.deliveryAddressId,
    required this.fulfillmentType,
    this.status = OrderStatus.created,
    this.paymentStatus = PaymentStatus.unpaid,
    this.source = OrderSource.mobile,
    this.scheduledFor,
    this.currency = 'USD',
    this.subtotalCents = 0,
    this.taxCents = 0,
    this.tipCents = 0,
    this.deliveryFeeCents = 0,
    this.serviceFeeCents = 0,
    this.discountCents = 0,
    required this.totalCents,
    this.itemsCount = 0,
    this.weightOz = 0,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.specialInstructions,
    this.fulfillmentInstructions,
    this.pickupEta,
    this.deliveryEta,
    this.createdBy,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.deliveryAddress,
  });

  /// Order number formatted for display
  String get orderNumberDisplay => '#$orderNumber';

  /// Subtotal in dollars
  double get subtotalInDollars => subtotalCents / 100.0;

  /// Tax in dollars
  double get taxInDollars => taxCents / 100.0;

  /// Tip in dollars
  double get tipInDollars => tipCents / 100.0;

  /// Delivery fee in dollars
  double get deliveryFeeInDollars => deliveryFeeCents / 100.0;

  /// Service fee in dollars
  double get serviceFeeInDollars => serviceFeeCents / 100.0;

  /// Discount in dollars
  double get discountInDollars => discountCents / 100.0;

  /// Total in dollars
  double get totalInDollars => totalCents / 100.0;

  /// Formatted total
  String get formattedTotal => '\$${totalInDollars.toStringAsFixed(2)}';

  /// Formatted subtotal
  String get formattedSubtotal => '\$${subtotalInDollars.toStringAsFixed(2)}';

  /// Formatted tax
  String get formattedTax => '\$${taxInDollars.toStringAsFixed(2)}';

  /// Whether order is for delivery
  bool get isDelivery => fulfillmentType == FulfillmentType.delivery;

  /// Whether order is for pickup
  bool get isPickup => fulfillmentType == FulfillmentType.pickup;

  /// Whether order is completed
  bool get isCompleted =>
      status == OrderStatus.delivered ||
      (isPickup && status == OrderStatus.ready);

  /// Whether order can be canceled
  bool get canCancel =>
      !status.isTerminal &&
      status != OrderStatus.outForDelivery &&
      status != OrderStatus.pickedUp;

  /// Estimated time of arrival
  DateTime? get eta => isDelivery ? deliveryEta : pickupEta;
}
