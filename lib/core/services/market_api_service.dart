import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../main.dart';
import '../../data/models/models.dart';
import '../config/env_config.dart';
import '../config/env_provider.dart';

/// API service for market-server Edge Function
/// Matches the web monorepo's API patterns exactly
class MarketApiService {
  MarketApiService._();

  static final MarketApiService instance = MarketApiService._();

  late Dio _dio;
  bool _initialized = false;

  /// Initialize with the runtime environment
  /// Uses global `currentEnvironment` set at app startup
  void initialize({required String anonKey}) {
    if (_initialized) return;

    // Use runtime environment for URL and header
    final baseUrl = RuntimeEnvConfig.marketServerUrl(currentEnvironment);
    final envHeader = RuntimeEnvConfig.tabsyEnvHeader(currentEnvironment);

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
          'apikey': anonKey,
          'x-tabsy-env': envHeader,
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (EnvConfig.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    _initialized = true;

    if (kDebugMode) {
      debugPrint('MarketApiService initialized:');
      debugPrint('  baseUrl: $baseUrl');
      debugPrint('  x-tabsy-env: $envHeader');
    }
  }

  // ===========================================================================
  // PAYMENTS
  // ===========================================================================

  /// Create a Stripe PaymentIntent for checkout
  /// Matches: POST /market-server/payments/intent
  Future<PaymentIntentResponse> createPaymentIntent({
    required int amountCents,
    required int subtotalCents,
    required int taxCents,
    required int serviceFeeCents,
    required int tipCents,
    int? deliveryFeeCents,
    int? discountCents,
    String currency = 'USD',
    String? fulfillmentType,
    required CustomerInfo customer,
    List<PaymentIntentItem>? orderItems,
    String? existingPaymentIntentId,
    PaymentBreakdown? breakdown,
  }) async {
    final response = await _dio.post(
      '/payments/intent',
      data: {
        'amount': amountCents,
        'subtotal': subtotalCents,
        'tax': taxCents,
        'serviceFee': serviceFeeCents,
        'tip': tipCents,
        if (deliveryFeeCents != null) 'deliveryFee': deliveryFeeCents,
        if (discountCents != null) 'discount': discountCents,
        'currency': currency,
        if (fulfillmentType != null) 'fulfillmentType': fulfillmentType,
        'customer': customer.toJson(),
        if (orderItems != null)
          'orderItems': orderItems.map((i) => i.toJson()).toList(),
        if (existingPaymentIntentId != null)
          'paymentIntentId': existingPaymentIntentId,
        if (breakdown != null) 'breakdown': breakdown.toJson(),
      },
    );

    return PaymentIntentResponse.fromJson(response.data);
  }

  // ===========================================================================
  // ORDERS
  // ===========================================================================

  /// Create a new order
  /// Matches: POST /market-server/orders
  Future<CreateOrderResponse> createOrder({
    required String fulfillmentType,
    required List<OrderItemPayload> items,
    required CustomerInfo customer,
    DeliveryAddressPayload? delivery,
    required OrderTotalsPayload totals,
    String? tipMode,
    String? couponCode,
    Map<String, dynamic>? metadata,
    PaymentBreakdown? breakdown,
    DeliveryQuotePayload? deliveryQuote,
    String? paymentIntentId,
  }) async {
    final response = await _dio.post(
      '/orders',
      data: {
        'fulfillmentType': fulfillmentType,
        'items': items.map((i) => i.toJson()).toList(),
        'customer': customer.toJson(),
        if (delivery != null) 'delivery': delivery.toJson(),
        'totals': totals.toJson(),
        if (tipMode != null) 'tipMode': tipMode,
        if (couponCode != null) 'couponCode': couponCode,
        if (metadata != null) 'metadata': metadata,
        if (breakdown != null) 'breakdown': breakdown.toJson(),
        if (deliveryQuote != null) 'deliveryQuote': deliveryQuote.toJson(),
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
      },
    );

    return CreateOrderResponse.fromJson(response.data);
  }

  /// Get order by ID
  /// Matches: GET /market-server/orders/:id
  Future<OrderDetailsResponse> getOrder(String orderId) async {
    final response = await _dio.get('/orders/$orderId');
    return OrderDetailsResponse.fromJson(response.data);
  }

  /// Track order by reference (email, phone, or order number)
  /// Matches: GET /market-server/orders/track/:reference
  Future<OrderDetailsResponse> trackOrder(String reference) async {
    final response = await _dio.get('/orders/track/$reference');
    return OrderDetailsResponse.fromJson(response.data);
  }

  /// Lookup orders for a guest user by contact info
  /// Matches: POST /market-server/orders/customer-lookup
  Future<List<Order>> lookupCustomerOrders({
    String? email,
    String? phone,
    String? customerId,
  }) async {
    final response = await _dio.post(
      '/orders/customer-lookup',
      data: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (customerId != null) 'customerId': customerId,
      },
    );

    final rawOrders = response.data['orders'] as List<dynamic>? ?? [];
    return rawOrders
        .map((order) => OrderMapper.fromMap(order as Map<String, dynamic>))
        .toList();
  }

  /// Cancel an order (within edit window)
  /// Matches: POST /market-server/orders/:id/customer-cancel
  /// Note: This is the customer endpoint that verifies phone/email and respects 3-min window
  /// The admin endpoint /orders/:id/cancel requires Supabase admin auth
  Future<CancelOrderResponse> cancelOrder({
    required String orderId,
    String? customerPhone,
    String? customerEmail,
    String? reason,
  }) async {
    final response = await _dio.post(
      '/orders/$orderId/customer-cancel',
      data: {
        if (customerPhone != null) 'customerPhone': customerPhone,
        if (customerEmail != null) 'customerEmail': customerEmail,
        if (reason != null) 'reason': reason,
      },
    );

    return CancelOrderResponse.fromJson(response.data);
  }

  // ===========================================================================
  // DELIVERY
  // ===========================================================================

  /// Get delivery quote
  /// Matches: POST /market-server/delivery/quote
  Future<DeliveryQuoteResponse> getDeliveryQuote({
    required DeliveryAddressPayload address,
    required List<DeliveryItem> items,
  }) async {
    final response = await _dio.post(
      '/delivery/quote',
      data: {
        'address': address.toJson(),
        'items': items.map((i) => i.toJson()).toList(),
      },
    );

    return DeliveryQuoteResponse.fromJson(response.data);
  }

  // ===========================================================================
  // MENU
  // ===========================================================================

  /// Get menu items
  /// Matches: GET /market-server/menu
  Future<List<dynamic>> getMenu() async {
    final response = await _dio.get('/menu');
    return response.data as List<dynamic>;
  }


  // ===========================================================================
  // PROMOS
  // ===========================================================================

  /// Validate a promo code
  /// Matches: POST /market-server/promos/validate
  Future<PromoValidationResponse> validatePromo({
    required String code,
    required int subtotalCents,
    String? customerEmail,
    String? customerPhone,
  }) async {
    final response = await _dio.post(
      '/promos/validate',
      data: {
        'code': code,
        'subtotalCents': subtotalCents,
        if (customerEmail != null) 'customerEmail': customerEmail,
        if (customerPhone != null) 'customerPhone': customerPhone,
      },
    );

    return PromoValidationResponse.fromJson(response.data);
  }

  // ===========================================================================
  // LOYALTY
  // ===========================================================================

  /// Get or create loyalty profile
  /// Matches: POST /market-server/loyalty/profile
  Future<LoyaltyProfileResponse> getLoyaltyProfile({
    String? email,
    String? phone,
  }) async {
    final response = await _dio.post(
      '/loyalty/profile',
      data: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );

    return LoyaltyProfileResponse.fromJson(response.data);
  }

  // ===========================================================================
  // CONFIG
  // ===========================================================================

  /// Get tenant config
  /// Matches: GET /market-server/config
  Future<TenantConfig> getTenantConfig() async {
    final response = await _dio.get('/config');
    return TenantConfig.fromJson(response.data);
  }

  /// Get payments config (Stripe public key, Connect account)
  /// Matches: GET /market-server/payments/config
  Future<PaymentsConfig> getPaymentsConfig() async {
    final response = await _dio.get('/payments/config');
    return PaymentsConfig.fromJson(response.data);
  }
}

// ===========================================================================
// REQUEST/RESPONSE MODELS
// ===========================================================================

class CustomerInfo {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  const CustomerInfo({this.firstName, this.lastName, this.email, this.phone});

  Map<String, dynamic> toJson() => {
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
  };
}

class PaymentIntentItem {
  final String? sku;
  final String name;
  final int priceCents;
  final double qty;
  final String? unit;

  const PaymentIntentItem({
    this.sku,
    required this.name,
    required this.priceCents,
    required this.qty,
    this.unit,
  });

  Map<String, dynamic> toJson() => {
    if (sku != null) 'sku': sku,
    'name': name,
    'price': priceCents,
    'qty': qty,
    if (unit != null) 'unit': unit,
  };
}

class PaymentBreakdown {
  final int subtotal;
  final int deliveryFee;
  final int tabsyFee;
  final int stripeProcessingFee;
  final int tax;
  final int tip;
  final int discount;
  final int total;

  const PaymentBreakdown({
    required this.subtotal,
    required this.deliveryFee,
    required this.tabsyFee,
    required this.stripeProcessingFee,
    required this.tax,
    required this.tip,
    required this.discount,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'tabsyFee': tabsyFee,
    'stripeProcessingFee': stripeProcessingFee,
    'tax': tax,
    'tip': tip,
    'discount': discount,
    'total': total,
  };
}

class PaymentIntentResponse {
  final String paymentIntentId;
  final String clientSecret;
  final int amount;
  final bool? reused;

  const PaymentIntentResponse({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.amount,
    this.reused,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      paymentIntentId: json['paymentIntentId'] as String,
      clientSecret: json['clientSecret'] as String,
      amount: json['amount'] as int,
      reused: json['reused'] as bool?,
    );
  }
}

class OrderItemPayload {
  final String? sku;
  final String name;
  final int priceCents;
  final double qty;
  final String? image;
  final List<Map<String, dynamic>>? mods;
  final String? note;
  final String? unit;
  final String? unitLabel;

  const OrderItemPayload({
    this.sku,
    required this.name,
    required this.priceCents,
    required this.qty,
    this.image,
    this.mods,
    this.note,
    this.unit,
    this.unitLabel,
  });

  Map<String, dynamic> toJson() => {
    if (sku != null) 'id': sku,
    'name': name,
    'price': priceCents,
    'qty': qty,
    if (image != null) 'image': image,
    if (mods != null) 'mods': mods,
    if (note != null) 'note': note,
    if (unit != null) 'unit': unit,
    if (unitLabel != null) 'unitLabel': unitLabel,
  };
}

class DeliveryAddressPayload {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String? instructions;
  final double? latitude;
  final double? longitude;

  const DeliveryAddressPayload({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.zip,
    this.country = 'US',
    this.instructions,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'line1': line1,
    if (line2 != null) 'line2': line2,
    'city': city,
    'state': state,
    'zip': zip,
    'country': country,
    if (instructions != null) 'instructions': instructions,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}

class OrderTotalsPayload {
  final int subtotal;
  final int tax;
  final int serviceFee;
  final int? deliveryFee;
  final int tip;
  final int? discount;
  final int total;

  const OrderTotalsPayload({
    required this.subtotal,
    required this.tax,
    required this.serviceFee,
    this.deliveryFee,
    required this.tip,
    this.discount,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'tax': tax,
    'serviceFee': serviceFee,
    if (deliveryFee != null) 'deliveryFee': deliveryFee,
    'tip': tip,
    if (discount != null) 'discount': discount,
    'total': total,
  };
}

class DeliveryQuotePayload {
  final String provider;
  final String quoteId;
  final int feeCents;
  final String currency;
  final int? etaMinutes;
  final String expiresAt;
  final String pickupAddressPayload;
  final String dropoffAddressPayload;

  const DeliveryQuotePayload({
    required this.provider,
    required this.quoteId,
    required this.feeCents,
    required this.currency,
    this.etaMinutes,
    required this.expiresAt,
    required this.pickupAddressPayload,
    required this.dropoffAddressPayload,
  });

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'quoteId': quoteId,
    'feeCents': feeCents,
    'currency': currency,
    if (etaMinutes != null) 'etaMinutes': etaMinutes,
    'expiresAt': expiresAt,
    'pickupAddressPayload': pickupAddressPayload,
    'dropoffAddressPayload': dropoffAddressPayload,
  };
}

class DeliveryItem {
  final String name;
  final int quantity;
  final int priceCents;
  final String? size;
  final double? weightOz;

  const DeliveryItem({
    required this.name,
    required this.quantity,
    required this.priceCents,
    this.size,
    this.weightOz,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': priceCents,
    if (size != null) 'size': size,
    if (weightOz != null) 'weight': weightOz,
  };
}

class CreateOrderResponse {
  final OrderDetailsResponse order;
  final LoyaltySummary? loyalty;

  const CreateOrderResponse({required this.order, this.loyalty});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      order: OrderDetailsResponse.fromJson(
        json['order'] as Map<String, dynamic>,
      ),
      loyalty: json['loyalty'] != null
          ? LoyaltySummary.fromJson(json['loyalty'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderDetailsResponse {
  final String id;
  final int? orderNumber;
  final String? shortCode;
  final String tenantId;
  final String? customerId;
  final String fulfillmentType;
  final String status;
  final String paymentStatus;
  final String? scheduledFor;
  final String? pickupEta;
  final String? deliveryEta;
  final Map<String, dynamic>? contact;
  final Map<String, dynamic>? deliveryAddress;
  final Map<String, dynamic> totals;
  final List<dynamic> items;
  final List<dynamic>? events;
  final Map<String, dynamic>? timestamps;
  final Map<String, dynamic>? metadata;
  final String createdAt;
  final String updatedAt;

  const OrderDetailsResponse({
    required this.id,
    this.orderNumber,
    this.shortCode,
    required this.tenantId,
    this.customerId,
    required this.fulfillmentType,
    required this.status,
    required this.paymentStatus,
    this.scheduledFor,
    this.pickupEta,
    this.deliveryEta,
    this.contact,
    this.deliveryAddress,
    required this.totals,
    required this.items,
    this.events,
    this.timestamps,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as int?,
      shortCode: json['shortCode'] as String?,
      tenantId: json['tenantId'] as String,
      customerId: json['customerId'] as String?,
      fulfillmentType: json['fulfillmentType'] as String,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      scheduledFor: json['scheduledFor'] as String?,
      pickupEta: json['pickupEta'] as String?,
      deliveryEta: json['deliveryEta'] as String?,
      contact: json['contact'] as Map<String, dynamic>?,
      deliveryAddress: json['deliveryAddress'] as Map<String, dynamic>?,
      totals: json['totals'] as Map<String, dynamic>,
      items: json['items'] as List<dynamic>,
      events: json['events'] as List<dynamic>?,
      timestamps: json['timestamps'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class LoyaltySummary {
  final String? profileId;
  final int starsEarned;
  final int newBalance;
  final bool? firstOrderBonus;

  const LoyaltySummary({
    this.profileId,
    required this.starsEarned,
    required this.newBalance,
    this.firstOrderBonus,
  });

  factory LoyaltySummary.fromJson(Map<String, dynamic> json) {
    return LoyaltySummary(
      profileId: json['profileId'] as String?,
      starsEarned: json['starsEarned'] as int? ?? 0,
      newBalance: json['newBalance'] as int? ?? 0,
      firstOrderBonus: json['firstOrderBonus'] as bool?,
    );
  }
}

class DeliveryQuoteResponse {
  final String provider;
  final int feeCents;
  final String currency;
  final String quoteId;
  final String expiresAt;
  final String pickupAddressPayload;
  final String dropoffAddressPayload;
  final int? etaMinutes;

  const DeliveryQuoteResponse({
    required this.provider,
    required this.feeCents,
    required this.currency,
    required this.quoteId,
    required this.expiresAt,
    required this.pickupAddressPayload,
    required this.dropoffAddressPayload,
    this.etaMinutes,
  });

  /// Parse the API response - handles both nested { quote: {...} } and flat response
  factory DeliveryQuoteResponse.fromJson(Map<String, dynamic> json) {
    // Web API returns { quote: {...} }, unwrap if needed
    final data = json.containsKey('quote')
        ? json['quote'] as Map<String, dynamic>
        : json;

    return DeliveryQuoteResponse(
      provider: data['provider'] as String? ?? 'uber',
      feeCents: data['feeCents'] as int,
      currency: data['currency'] as String? ?? 'USD',
      quoteId: data['quoteId'] as String,
      expiresAt: data['expiresAt'] as String,
      pickupAddressPayload: data['pickupAddressPayload'] as String,
      dropoffAddressPayload: data['dropoffAddressPayload'] as String,
      etaMinutes: data['etaMinutes'] as int?,
    );
  }
}

class LoyaltyProfileResponse {
  final LoyaltyProfileData? profile;
  final List<dynamic> events;

  const LoyaltyProfileResponse({this.profile, required this.events});

  factory LoyaltyProfileResponse.fromJson(Map<String, dynamic> json) {
    return LoyaltyProfileResponse(
      profile: json['profile'] != null
          ? LoyaltyProfileData.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      events: json['events'] as List<dynamic>? ?? [],
    );
  }
}

class LoyaltyProfileData {
  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final int stars;
  final String? referralCode;
  final bool firstOrderCompleted;

  const LoyaltyProfileData({
    required this.id,
    this.email,
    this.phone,
    this.name,
    required this.stars,
    this.referralCode,
    required this.firstOrderCompleted,
  });

  factory LoyaltyProfileData.fromJson(Map<String, dynamic> json) {
    return LoyaltyProfileData(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      stars: json['stars'] as int? ?? 0,
      referralCode: json['referralCode'] as String?,
      firstOrderCompleted: json['firstOrderCompleted'] as bool? ?? false,
    );
  }
}

class TenantConfig {
  final Map<String, dynamic>? theme;
  final Map<String, dynamic>? features;
  final Map<String, dynamic>? delivery;
  final Map<String, dynamic>? pickup;
  final Map<String, dynamic>? social;
  final double taxRate;
  final double serviceFeeRate;

  const TenantConfig({
    this.theme,
    this.features,
    this.delivery,
    this.pickup,
    this.social,
    this.taxRate = 0.0875, // 8.75% default
    this.serviceFeeRate = 0.0,
  });

  factory TenantConfig.fromJson(Map<String, dynamic> json) {
    return TenantConfig(
      theme: json['theme'] as Map<String, dynamic>?,
      features: json['features'] as Map<String, dynamic>?,
      delivery: json['delivery'] as Map<String, dynamic>?,
      pickup: json['pickup'] as Map<String, dynamic>?,
      social: json['social'] as Map<String, dynamic>?,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0875,
      serviceFeeRate: (json['serviceFeeRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get loyaltyEnabled => features?['loyalty'] == true;
  bool get deliveryEnabled => features?['delivery'] == true;
  bool get pickupEnabled => features?['pickup'] == true;
}

class PaymentsConfig {
  final String publishableKey;
  final String? connectAccountId;

  const PaymentsConfig({required this.publishableKey, this.connectAccountId});

  factory PaymentsConfig.fromJson(Map<String, dynamic> json) {
    return PaymentsConfig(
      publishableKey: json['publishableKey'] as String,
      connectAccountId: json['connectAccountId'] as String?,
    );
  }
}

// ===========================================================================
// ORDER CANCEL/EDIT RESPONSES
// ===========================================================================

class CancelOrderResponse {
  final bool success;
  final String? message;
  final int? refundAmountCents;
  final String? refundId;

  const CancelOrderResponse({
    required this.success,
    this.message,
    this.refundAmountCents,
    this.refundId,
  });

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) {
    return CancelOrderResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      refundAmountCents: json['refundAmountCents'] as int?,
      refundId: json['refundId'] as String?,
    );
  }
}

// ===========================================================================
// ORDER CANCEL WINDOW HELPER
// ===========================================================================

/// Calculate remaining cancel window time (3 minutes from order creation)
/// Matches web: calculateEditWindowRemaining (cancel window uses same logic)
Duration calculateCancelWindowRemaining(DateTime orderCreatedAt) {
  const cancelWindowDuration = Duration(minutes: 3);
  final deadline = orderCreatedAt.add(cancelWindowDuration);
  final now = DateTime.now();

  if (now.isAfter(deadline)) {
    return Duration.zero;
  }

  return deadline.difference(now);
}

/// Check if order can still be cancelled
bool canCancelOrder(DateTime orderCreatedAt) {
  return calculateCancelWindowRemaining(orderCreatedAt) > Duration.zero;
}

// ===========================================================================
// PROMO VALIDATION RESPONSE
// ===========================================================================

class PromoValidationResponse {
  final bool valid;
  final String? error;
  final String? promoId;
  final String? code;
  final String? name;
  final String? description;
  final String? discountType;
  final int? discountValue;
  final int? discountCents;
  final int? maxDiscountCents;

  const PromoValidationResponse({
    required this.valid,
    this.error,
    this.promoId,
    this.code,
    this.name,
    this.description,
    this.discountType,
    this.discountValue,
    this.discountCents,
    this.maxDiscountCents,
  });

  factory PromoValidationResponse.fromJson(Map<String, dynamic> json) {
    return PromoValidationResponse(
      valid: json["valid"] as bool? ?? false,
      error: json["error"] as String?,
      promoId: json["promoId"] as String?,
      code: json["code"] as String?,
      name: json["name"] as String?,
      description: json["description"] as String?,
      discountType: json["discountType"] as String?,
      discountValue: json["discountValue"] as int?,
      discountCents: json["discountCents"] as int?,
      maxDiscountCents: json["maxDiscountCents"] as int?,
    );
  }

  double get discountInDollars => (discountCents ?? 0) / 100.0;
  String get formattedDiscount => "\$${discountInDollars.toStringAsFixed(2)}";
  
  String get discountDescription {
    if (discountType == "percentage") {
      final maxNote = maxDiscountCents != null 
          ? " (max \$${(maxDiscountCents! / 100).toStringAsFixed(0)})"
          : "";
      return "$discountValue% off$maxNote";
    }
    return "\$${((discountValue ?? 0) / 100).toStringAsFixed(2)} off";
  }
}
