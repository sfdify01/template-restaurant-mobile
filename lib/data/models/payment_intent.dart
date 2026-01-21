import 'package:dart_mappable/dart_mappable.dart';

part 'payment_intent.mapper.dart';

/// Payment intent status enum
@MappableEnum()
enum PaymentIntentStatus {
  @MappableValue('requires_payment_method')
  requiresPaymentMethod,
  @MappableValue('requires_confirmation')
  requiresConfirmation,
  @MappableValue('requires_action')
  requiresAction,
  @MappableValue('processing')
  processing,
  @MappableValue('requires_capture')
  requiresCapture,
  @MappableValue('canceled')
  canceled,
  @MappableValue('succeeded')
  succeeded;

  bool get isTerminal => this == canceled || this == succeeded;

  bool get isPending =>
      this == requiresPaymentMethod ||
      this == requiresConfirmation ||
      this == requiresAction ||
      this == processing;
}

/// Payment intent model matching Supabase payment_intents table
@MappableClass(caseStyle: CaseStyle.snakeCase)
class PaymentIntent with PaymentIntentMappable {
  final String id;
  final String tenantId;
  final String orderId;
  final String stripePaymentIntentId;
  final int amountCents;
  final String currency;
  final PaymentIntentStatus status;
  final String? clientSecret;
  final String? customerId;
  final String? stripeCustomerId;
  final int? applicationFeeCents;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentIntent({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.stripePaymentIntentId,
    required this.amountCents,
    this.currency = 'USD',
    this.status = PaymentIntentStatus.requiresPaymentMethod,
    this.clientSecret,
    this.customerId,
    this.stripeCustomerId,
    this.applicationFeeCents,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Amount in dollars
  double get amountInDollars => amountCents / 100.0;

  /// Formatted amount
  String get formattedAmount => '\$${amountInDollars.toStringAsFixed(2)}';

  /// Application fee in dollars
  double? get applicationFeeInDollars =>
      applicationFeeCents != null ? applicationFeeCents! / 100.0 : null;

  /// Whether payment is complete
  bool get isComplete => status == PaymentIntentStatus.succeeded;

  /// Whether payment needs customer action
  bool get needsAction => status == PaymentIntentStatus.requiresAction;
}
