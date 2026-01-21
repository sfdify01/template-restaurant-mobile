import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show ThemeMode, Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Address;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../../../core/config/env_config.dart';
import '../../../core/config/env_provider.dart';
import '../../../core/services/market_api_service.dart';
import '../../../core/utils/user_error_messages.dart';
import '../../../data/models/models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/guest_profile_storage.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/services/guest_order_storage.dart';

part 'checkout_provider.g.dart';

/// Guest checkout info collected on-the-air
class GuestInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const GuestInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  String get fullName => '$firstName $lastName'.trim();
}

/// Delivery quote from Uber/DoorDash
class DeliveryQuote {
  final String provider;
  final String quoteId;
  final int feeCents;
  final String currency;
  final int? etaMinutes;
  final String expiresAt;
  final String pickupAddressPayload;
  final String dropoffAddressPayload;

  const DeliveryQuote({
    required this.provider,
    required this.quoteId,
    required this.feeCents,
    required this.currency,
    this.etaMinutes,
    required this.expiresAt,
    required this.pickupAddressPayload,
    required this.dropoffAddressPayload,
  });

  double get feeInDollars => feeCents / 100.0;
  String get formattedFee => '\$${feeInDollars.toStringAsFixed(2)}';
}

/// Checkout state
class CheckoutState {
  final Address? selectedAddress;
  final FulfillmentType? fulfillmentType; // null = not selected yet
  final String paymentMethod; // 'card', 'apple_pay', 'google_pay'
  final bool isProcessing;
  final String? error;
  final GuestInfo? guestInfo;
  final int tipCents;
  final String tipMode; // 'percent' or 'amount'
  final DeliveryQuote? deliveryQuote;
  final bool isQuotingDelivery;
  final String? paymentIntentId;
  final double taxRate;
  final double serviceFeeRate;
  final String? promoCode;
  final String? promoId;
  final int promoDiscountCents;
  final String? promoName;
  final String? promoDescription;
  final bool isValidatingPromo;

  const CheckoutState({
    this.selectedAddress,
    this.fulfillmentType, // null by default - user must choose
    this.paymentMethod = 'card',
    this.isProcessing = false,
    this.error,
    this.guestInfo,
    this.tipCents = 0,
    this.tipMode = 'percent',
    this.deliveryQuote,
    this.isQuotingDelivery = false,
    this.paymentIntentId,
    this.taxRate = 0.0875, // 8.75% default Illinois tax
    this.serviceFeeRate = 0.0,
    this.promoCode,
    this.promoId,
    this.promoDiscountCents = 0,
    this.promoName,
    this.promoDescription,
    this.isValidatingPromo = false,
  });

  bool get hasFulfillmentType => fulfillmentType != null;
  bool get isDelivery => fulfillmentType == FulfillmentType.delivery;
  bool get isPickup => fulfillmentType == FulfillmentType.pickup;
  bool get hasPromo => promoCode != null && promoDiscountCents > 0;

  CheckoutState copyWith({
    Address? selectedAddress,
    FulfillmentType? fulfillmentType,
    bool setFulfillmentType = false, // use this flag to explicitly set fulfillmentType
    String? paymentMethod,
    bool? isProcessing,
    String? error,
    GuestInfo? guestInfo,
    int? tipCents,
    String? tipMode,
    DeliveryQuote? deliveryQuote,
    bool? isQuotingDelivery,
    String? paymentIntentId,
    double? taxRate,
    double? serviceFeeRate,
    bool clearDeliveryQuote = false,
    bool clearGuestInfo = false,
    String? promoCode,
    String? promoId,
    int? promoDiscountCents,
    String? promoName,
    String? promoDescription,
    bool? isValidatingPromo,
    bool clearPromo = false,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      fulfillmentType: setFulfillmentType ? fulfillmentType : (fulfillmentType ?? this.fulfillmentType),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      guestInfo: clearGuestInfo ? null : (guestInfo ?? this.guestInfo),
      tipCents: tipCents ?? this.tipCents,
      tipMode: tipMode ?? this.tipMode,
      deliveryQuote: clearDeliveryQuote
          ? null
          : (deliveryQuote ?? this.deliveryQuote),
      isQuotingDelivery: isQuotingDelivery ?? this.isQuotingDelivery,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      taxRate: taxRate ?? this.taxRate,
      serviceFeeRate: serviceFeeRate ?? this.serviceFeeRate,
      promoCode: clearPromo ? null : (promoCode ?? this.promoCode),
      promoId: clearPromo ? null : (promoId ?? this.promoId),
      promoDiscountCents: clearPromo ? 0 : (promoDiscountCents ?? this.promoDiscountCents),
      promoName: clearPromo ? null : (promoName ?? this.promoName),
      promoDescription: clearPromo ? null : (promoDescription ?? this.promoDescription),
      isValidatingPromo: isValidatingPromo ?? this.isValidatingPromo,
    );
  }
}

/// Checkout notifier - manages checkout flow matching web business logic
@riverpod
class Checkout extends _$Checkout {
  MarketApiService get _api => MarketApiService.instance;

  @override
  CheckoutState build() {
    // Initialize API service with the current runtime environment
    // This uses the environment selected by the user (test vs production)
    _api.initialize(
      anonKey: RuntimeEnvConfig.supabaseAnonKey(currentEnvironment),
    );
    return const CheckoutState();
  }

  void setFulfillmentType(FulfillmentType type) {
    state = state.copyWith(
      fulfillmentType: type,
      setFulfillmentType: true,
      clearDeliveryQuote: type == FulfillmentType.pickup,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setAddress(Address address, {bool clearQuote = true}) {
    state = state.copyWith(
      selectedAddress: address,
      clearDeliveryQuote: clearQuote,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setGuestInfo(GuestInfo info) {
    state = state.copyWith(guestInfo: info);
  }

  void clearGuestInfo() {
    state = state.copyWith(clearGuestInfo: true);
  }

  void setTip(int tipCents, {String mode = 'amount'}) {
    state = state.copyWith(tipCents: tipCents, tipMode: mode);
  }

  void setTipPercent(int percent) {
    final cart = ref.read(cartProvider);
    final tipCents = (cart.subtotalCents * percent / 100).round();
    state = state.copyWith(tipCents: tipCents, tipMode: 'percent');
  }

  /// Validate a promo code
  Future<void> validatePromo(String code) async {
    if (code.trim().isEmpty) {
      state = state.copyWith(error: "Please enter a promo code");
      return;
    }

    state = state.copyWith(isValidatingPromo: true, error: null);

    try {
      final cart = ref.read(cartProvider);
      final auth = ref.read(authProvider);
      final guestInfo = state.guestInfo;

      final response = await _api.validatePromo(
        code: code.toUpperCase().trim(),
        subtotalCents: cart.subtotalCents,
        customerEmail: guestInfo?.email ?? auth.customer?.email,
        customerPhone: guestInfo?.phone ?? auth.customer?.phone,
      );

      if (response.valid) {
        state = state.copyWith(
          promoCode: response.code,
          promoId: response.promoId,
          promoDiscountCents: response.discountCents ?? 0,
          promoName: response.name,
          promoDescription: response.discountDescription,
          isValidatingPromo: false,
        );
      } else {
        state = state.copyWith(
          isValidatingPromo: false,
          error: UserErrorMessage.from(
            response.error,
            fallback: "Invalid promo code",
          ),
          clearPromo: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isValidatingPromo: false,
        error: "Failed to validate promo code",
        clearPromo: true,
      );
    }
  }

  /// Clear the applied promo code
  void clearPromo() {
    state = state.copyWith(clearPromo: true);
  }


  /// Get delivery quote for the selected address
  Future<void> getDeliveryQuote() async {
    final address = state.selectedAddress;
    if (address == null) {
      state = state.copyWith(error: 'Please select a delivery address');
      return;
    }

    state = state.copyWith(isQuotingDelivery: true, error: null);

    try {
      final cart = ref.read(cartProvider);
      final items = cart.items
          .map(
            (item) => DeliveryItem(
              name: item.name,
              quantity: item.qty.ceil(),
              priceCents: item.totalCents,
            ),
          )
          .toList();

      final response = await _api.getDeliveryQuote(
        address: DeliveryAddressPayload(
          line1: address.streetLine1,
          line2: address.streetLine2,
          city: address.city,
          state: address.state,
          zip: address.postalCode,
          latitude: address.latitude,
          longitude: address.longitude,
        ),
        items: items,
      );

      state = state.copyWith(
        deliveryQuote: DeliveryQuote(
          provider: response.provider,
          quoteId: response.quoteId,
          feeCents: response.feeCents,
          currency: response.currency,
          etaMinutes: response.etaMinutes,
          expiresAt: response.expiresAt,
          pickupAddressPayload: response.pickupAddressPayload,
          dropoffAddressPayload: response.dropoffAddressPayload,
        ),
        isQuotingDelivery: false,
      );
    } catch (e) {
      state = state.copyWith(
        isQuotingDelivery: false,
        error: UserErrorMessage.from(
          e,
          fallback: 'Failed to get delivery quote. Please try again.',
        ),
      );
    }
  }

  /// Calculate order totals matching web logic
  /// For delivery orders, a valid quote is REQUIRED - no hardcoded fees
  CheckoutTotals calculateTotals() {
    final cart = ref.read(cartProvider);
    final subtotalCents = cart.subtotalCents;
    final taxCents = (subtotalCents * state.taxRate).round();
    final serviceFeeCents = (subtotalCents * state.serviceFeeRate).round();

    // Delivery fee comes from Uber Direct quote - no hardcoded values
    final deliveryFeeCents = state.isDelivery
        ? (state.deliveryQuote?.feeCents ?? 0) // 0 if no quote yet
        : 0;
    final tipCents = state.tipCents;
    final discountCents = state.promoDiscountCents;
    final totalCents =
        subtotalCents +
        taxCents +
        serviceFeeCents +
        deliveryFeeCents -
        discountCents +
        tipCents;

    return CheckoutTotals(
      subtotalCents: subtotalCents,
      taxCents: taxCents,
      serviceFeeCents: serviceFeeCents,
      deliveryFeeCents: deliveryFeeCents,
      tipCents: tipCents,
      discountCents: discountCents,
      totalCents: totalCents,
    );
  }

  /// Check if we have a valid delivery quote
  bool get hasValidDeliveryQuote {
    if (!state.isDelivery) return true; // Pickup doesn't need a quote
    if (state.deliveryQuote == null) return false;

    // Check if quote is expired
    try {
      final expiresAt = DateTime.parse(state.deliveryQuote!.expiresAt);
      return DateTime.now().isBefore(expiresAt);
    } catch (_) {
      return false;
    }
  }

  /// Check if delivery quote is expired
  bool get isQuoteExpired {
    if (state.deliveryQuote == null) return false;
    try {
      final expiresAt = DateTime.parse(state.deliveryQuote!.expiresAt);
      return DateTime.now().isAfter(expiresAt);
    } catch (_) {
      return false;
    }
  }

  /// Get remaining time until quote expires
  Duration? get quoteExpiresIn {
    if (state.deliveryQuote == null) return null;
    try {
      final expiresAt = DateTime.parse(state.deliveryQuote!.expiresAt);
      final remaining = expiresAt.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (_) {
      return null;
    }
  }

  /// Process the order with Stripe payment
  Future<CreateOrderResponse?> processOrder({String? notes}) async {
    debugPrint('🛒 processOrder: Starting checkout flow...');
    final authNotifier = ref.read(authProvider.notifier);
    var auth = ref.read(authProvider);
    final cart = ref.read(cartProvider);

    // Validate cart
    if (cart.isEmpty) {
      debugPrint('❌ processOrder: Cart is empty');
      state = state.copyWith(error: 'Your cart is empty');
      return null;
    }
    debugPrint('✅ processOrder: Cart has ${cart.items.length} items');

    // Validate fulfillment type is selected
    if (!state.hasFulfillmentType) {
      debugPrint('❌ processOrder: Fulfillment type not selected');
      state = state.copyWith(error: 'Please select Pickup or Delivery');
      return null;
    }
    debugPrint('✅ processOrder: Fulfillment type selected: ${state.fulfillmentType?.name}');

    // Validate guest info for guest checkout
    if (!auth.isAuthenticated && state.guestInfo == null) {
      debugPrint('❌ processOrder: Guest info missing');
      state = state.copyWith(error: 'Please enter your contact information');
      return null;
    }
    debugPrint(
      '✅ processOrder: Auth=${auth.isAuthenticated}, GuestInfo=${state.guestInfo != null}',
    );

    // Validate delivery address for delivery orders
    if (state.isDelivery && state.selectedAddress == null) {
      debugPrint('❌ processOrder: Delivery address missing');
      state = state.copyWith(error: 'Please select a delivery address');
      return null;
    }
    debugPrint(
      '✅ processOrder: Fulfillment=${state.fulfillmentType?.name}, Address=${state.selectedAddress?.streetLine1}',
    );

    state = state.copyWith(isProcessing: true, error: null);
    debugPrint('🔄 processOrder: Set isProcessing=true');

    try {
      // For authenticated users, ensure customer record exists
      // For guests, we skip this - the API handles guest orders with just customer info
      // This matches web behavior where guest checkout works without any Supabase auth
      if (auth.isAuthenticated && auth.customer == null) {
        debugPrint(
          '👤 processOrder: Creating customer record for authenticated user...',
        );
        final guestInfo = state.guestInfo;
        final customer = await authNotifier.ensureCustomer(
          name:
              guestInfo?.fullName ??
              auth.user?.userMetadata?['name'] ??
              'Guest',
          email: guestInfo?.email ?? auth.user?.email ?? '',
          phone: guestInfo?.phone ?? auth.user?.userMetadata?['phone'],
        );

        if (customer == null) {
          debugPrint('❌ processOrder: Customer creation failed');
          state = state.copyWith(
            isProcessing: false,
            error: 'Failed to create customer profile',
          );
          return null;
        }

        debugPrint('✅ processOrder: Customer created: ${customer.id}');
        auth = ref.read(authProvider);
      }

      final totals = calculateTotals();
      final guestInfo = state.guestInfo;
      debugPrint(
        '💰 processOrder: Totals - subtotal=${totals.subtotalCents}, total=${totals.totalCents}',
      );

      // Build customer info
      final customerInfo = CustomerInfo(
        firstName: guestInfo?.firstName ?? auth.customer?.firstName,
        lastName: guestInfo?.lastName ?? auth.customer?.lastName,
        email: guestInfo?.email ?? auth.customer?.email,
        phone: guestInfo?.phone ?? auth.customer?.phone,
      );
      debugPrint(
        '📧 processOrder: Customer - ${customerInfo.email}, ${customerInfo.phone}',
      );

      // 1. Create or update payment intent via market-server API
      debugPrint('💳 processOrder: Creating PaymentIntent...');
      final paymentResponse = await _api.createPaymentIntent(
        amountCents: totals.totalCents,
        subtotalCents: totals.subtotalCents,
        taxCents: totals.taxCents,
        serviceFeeCents: totals.serviceFeeCents,
        deliveryFeeCents: state.isDelivery ? totals.deliveryFeeCents : null,
        tipCents: totals.tipCents,
        currency: 'USD',
        fulfillmentType: state.fulfillmentType!.name,
        customer: customerInfo,
        orderItems: cart.items
            .map(
              (item) => PaymentIntentItem(
                sku: item.menuItemId,
                name: item.name,
                priceCents: item.unitPriceCents,
                qty: item.qty,
                unit: item.priceUnit.name,
              ),
            )
            .toList(),
        existingPaymentIntentId: state.paymentIntentId,
      );

      debugPrint(
        '✅ processOrder: PaymentIntent created: ${paymentResponse.paymentIntentId}',
      );
      state = state.copyWith(paymentIntentId: paymentResponse.paymentIntentId);

      // 2. Initialize Stripe Payment Sheet
      debugPrint('📱 processOrder: Initializing Stripe Payment Sheet...');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentResponse.clientSecret,
          merchantDisplayName: 'Shahirizada Fresh Market',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF6B0F1A),
            ),
          ),
          // TODO: Enable Apple Pay & Google Pay in next release
          // Requires: Apple Developer Portal setup + Stripe certificate
          // applePay: PaymentSheetApplePay(
          //   merchantCountryCode: 'US',
          // ),
          // googlePay: PaymentSheetGooglePay(
          //   merchantCountryCode: 'US',
          //   testEnv: !EnvConfig.isProduction,
          // ),
        ),
      );
      debugPrint('✅ processOrder: Payment Sheet initialized');

      // 3. Present Payment Sheet
      debugPrint('🎯 processOrder: Presenting Payment Sheet...');
      await Stripe.instance.presentPaymentSheet();
      debugPrint('✅ processOrder: Payment Sheet completed successfully');

      // 4. Payment successful - create order via market-server API
      debugPrint('📦 processOrder: Creating order...');
      final orderItems = cart.items
          .map(
            (item) => OrderItemPayload(
              sku: item.menuItemId,
              name: item.name,
              priceCents: item.unitPriceCents,
              qty: item.qty,
              image: item.imageUrl,
              mods: item.modifiers
                  .map(
                    (m) => {'id': m.id, 'name': m.name, 'price': m.priceCents},
                  )
                  .toList(),
              note: item.note,
              unit: item.priceUnit.name,
              unitLabel: item.priceUnit.label,
            ),
          )
          .toList();

      final address = state.selectedAddress;
      final deliveryPayload = state.isDelivery && address != null
          ? DeliveryAddressPayload(
              line1: address.streetLine1,
              line2: address.streetLine2,
              city: address.city,
              state: address.state,
              zip: address.postalCode,
              instructions: notes,
              latitude: address.latitude,
              longitude: address.longitude,
            )
          : null;

      final deliveryQuote = state.deliveryQuote;
      final deliveryQuotePayload = deliveryQuote != null
          ? DeliveryQuotePayload(
              provider: deliveryQuote.provider,
              quoteId: deliveryQuote.quoteId,
              feeCents: deliveryQuote.feeCents,
              currency: deliveryQuote.currency,
              etaMinutes: deliveryQuote.etaMinutes,
              expiresAt: deliveryQuote.expiresAt,
              pickupAddressPayload: deliveryQuote.pickupAddressPayload,
              dropoffAddressPayload: deliveryQuote.dropoffAddressPayload,
            )
          : null;

      final orderResponse = await _api.createOrder(
        fulfillmentType: state.fulfillmentType!.name,
        items: orderItems,
        customer: customerInfo,
        delivery: deliveryPayload,
        totals: OrderTotalsPayload(
          subtotal: totals.subtotalCents,
          tax: totals.taxCents,
          serviceFee: totals.serviceFeeCents,
          deliveryFee: state.isDelivery ? totals.deliveryFeeCents : null,
          tip: totals.tipCents,
          discount: totals.discountCents > 0 ? totals.discountCents : null,
          total: totals.totalCents,
        ),
        tipMode: state.tipMode,
        couponCode: state.promoCode,
        metadata: {'source': 'mobile'},
        deliveryQuote: deliveryQuotePayload,
        paymentIntentId: paymentResponse.paymentIntentId,
      );

      debugPrint('✅ processOrder: Order created: ${orderResponse.order.id}');

      // 5. Save order to local storage for guest users (like web's localStorage)
      // This allows guests to view their order on the confirmation/detail screens
      if (!auth.isAuthenticated) {
        await GuestOrderStorage.instance.saveOrderFromResponse(orderResponse.order);
        await GuestProfileStorage.instance.saveFromOrder(
          orderResponse.order,
          loyalty: orderResponse.loyalty,
        );
        debugPrint('✅ processOrder: Order saved to guest storage');
      }

      // 6. Clear cart on success
      ref.read(cartProvider.notifier).clear();

      // 7. Reset checkout state
      state = const CheckoutState();
      debugPrint('🎉 processOrder: Checkout complete!');

      return orderResponse;
    } on StripeException catch (e) {
      debugPrint(
        '❌ processOrder: Stripe error: ${e.error.code} - ${e.error.localizedMessage}',
      );
      state = state.copyWith(
        isProcessing: false,
        error: UserErrorMessage.from(
          e,
          fallback: 'Payment failed. Please try another card.',
        ),
      );
      return null;
    } catch (e, stack) {
      debugPrint('❌ processOrder: Error: $e');
      debugPrint('❌ processOrder: Stack: $stack');
      state = state.copyWith(
        isProcessing: false,
        error: UserErrorMessage.from(
          e,
          fallback: 'Failed to process order. Please try again.',
        ),
      );
      return null;
    }
  }

  /// Reset checkout state
  void reset() {
    state = const CheckoutState();
  }
}

/// Checkout totals
class CheckoutTotals {
  final int subtotalCents;
  final int taxCents;
  final int serviceFeeCents;
  final int deliveryFeeCents;
  final int tipCents;
  final int discountCents;
  final int totalCents;

  const CheckoutTotals({
    required this.subtotalCents,
    required this.taxCents,
    required this.serviceFeeCents,
    required this.deliveryFeeCents,
    required this.tipCents,
    required this.discountCents,
    required this.totalCents,
  });

  double get subtotalInDollars => subtotalCents / 100.0;
  double get taxInDollars => taxCents / 100.0;
  double get serviceFeeInDollars => serviceFeeCents / 100.0;
  double get deliveryFeeInDollars => deliveryFeeCents / 100.0;
  double get tipInDollars => tipCents / 100.0;
  double get discountInDollars => discountCents / 100.0;
  double get totalInDollars => totalCents / 100.0;

  String get formattedSubtotal => '\$${subtotalInDollars.toStringAsFixed(2)}';
  String get formattedTax => '\$${taxInDollars.toStringAsFixed(2)}';
  String get formattedServiceFee =>
      '\$${serviceFeeInDollars.toStringAsFixed(2)}';
  String get formattedDeliveryFee =>
      '\$${deliveryFeeInDollars.toStringAsFixed(2)}';
  String get formattedTip => '\$${tipInDollars.toStringAsFixed(2)}';
  String get formattedDiscount => '-\$${discountInDollars.toStringAsFixed(2)}';
  String get formattedTotal => '\$${totalInDollars.toStringAsFixed(2)}';
}

/// Fetch user addresses
@riverpod
Future<List<Address>> userAddresses(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated || auth.customer == null) {
    return [];
  }

  final response = await supabase
      .from('addresses')
      .select()
      .eq('customer_id', auth.customer!.id)
      .order('is_default', ascending: false)
      .order('created_at', ascending: false);

  return (response as List).map((a) => AddressMapper.fromMap(a)).toList();
}

/// Save a new address
@riverpod
class AddressManager extends _$AddressManager {
  @override
  FutureOr<void> build() {}

  Future<Address?> createAddress({
    required String streetLine1,
    required String city,
    required String state,
    required String postalCode,
    String? streetLine2,
    String? label,
    String? deliveryInstructions,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.customer == null) {
      return null;
    }

    // Only persist addresses that have coordinates (sourced from Google Maps API)
    if (latitude == null || longitude == null) {
      debugPrint(
        '⚠️ createAddress: Skipping save - address has no coordinates (not from Google Maps API)',
      );
      return null;
    }

    // Check for duplicate addresses - same street, city, state, postal code
    final normalizedStreet = streetLine1.trim().toLowerCase();
    final normalizedCity = city.trim().toLowerCase();
    final normalizedState = state.trim().toLowerCase();
    final normalizedPostal = postalCode.trim();

    final existingAddresses = await supabase
        .from('addresses')
        .select()
        .eq('customer_id', auth.customer!.id);

    final duplicateExists = (existingAddresses as List).any((addr) {
      final existingStreet =
          (addr['street_line_1'] as String?)?.trim().toLowerCase() ?? '';
      final existingCity =
          (addr['city'] as String?)?.trim().toLowerCase() ?? '';
      final existingState =
          (addr['state'] as String?)?.trim().toLowerCase() ?? '';
      final existingPostal = (addr['postal_code'] as String?)?.trim() ?? '';

      return existingStreet == normalizedStreet &&
          existingCity == normalizedCity &&
          existingState == normalizedState &&
          existingPostal == normalizedPostal;
    });

    if (duplicateExists) {
      debugPrint(
        '⚠️ createAddress: Skipping save - duplicate address already exists',
      );
      // Return the existing address instead of creating a duplicate
      final existing = (existingAddresses as List).firstWhere((addr) {
        final existingStreet =
            (addr['street_line_1'] as String?)?.trim().toLowerCase() ?? '';
        final existingCity =
            (addr['city'] as String?)?.trim().toLowerCase() ?? '';
        final existingState =
            (addr['state'] as String?)?.trim().toLowerCase() ?? '';
        final existingPostal = (addr['postal_code'] as String?)?.trim() ?? '';

        return existingStreet == normalizedStreet &&
            existingCity == normalizedCity &&
            existingState == normalizedState &&
            existingPostal == normalizedPostal;
      });

      // If setting as default and the existing address is not default, update it
      if (isDefault && existing['is_default'] != true) {
        await supabase
            .from('addresses')
            .update({'is_default': false})
            .eq('customer_id', auth.customer!.id);
        await supabase
            .from('addresses')
            .update({'is_default': true})
            .eq('id', existing['id']);
        ref.invalidate(userAddressesProvider);
      }

      return AddressMapper.fromMap(existing);
    }

    // If setting as default, unset other defaults first
    if (isDefault) {
      await supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('customer_id', auth.customer!.id);
    }

    final response = await supabase
        .from('addresses')
        .insert({
          'tenant_id': EnvConfig.tenantId,
          'customer_id': auth.customer!.id,
          'label': label,
          'street_line_1': streetLine1,
          'street_line_2': streetLine2,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'delivery_instructions': deliveryInstructions,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault,
        })
        .select()
        .single();

    // Invalidate addresses cache
    ref.invalidate(userAddressesProvider);

    return AddressMapper.fromMap(response);
  }

  Future<void> deleteAddress(String addressId) async {
    await supabase.from('addresses').delete().eq('id', addressId);
    ref.invalidate(userAddressesProvider);
  }

  Future<void> setDefaultAddress(String addressId) async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.customer == null) return;

    // Unset all defaults
    await supabase
        .from('addresses')
        .update({'is_default': false})
        .eq('customer_id', auth.customer!.id);

    // Set new default
    await supabase
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId);

    ref.invalidate(userAddressesProvider);
  }
}
