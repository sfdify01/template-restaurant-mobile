import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/live_activity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/us_phone_input_formatter.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../data/models/models.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';
import '../widgets/modern_address_picker.dart';

import '../widgets/promo_code_input.dart';
@RoutePage()
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final _guestFormKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  // Guest checkout fields
  final _guestFirstNameController = TextEditingController();
  final _guestLastNameController = TextEditingController();
  final _guestEmailController = TextEditingController();
  final _guestPhoneController = TextEditingController();

  // Modern address picker state
  DeliveryAddress? _deliveryAddress;
  bool _hasPrefilledData = false;

  @override
  void initState() {
    super.initState();
    // Defer prefilling until after the first frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();
    });
  }

  /// Prefill form fields with authenticated user data
  void _prefillUserData() {
    if (_hasPrefilledData) return;

    final auth = ref.read(authProvider);
    final addressesAsync = ref.read(userAddressesProvider);
    final customer = auth.customer;
    final user = auth.user;

    // If authenticated, prefill contact info from customer first, then user fallback
    if (auth.isAuthenticated) {
      // First Name - try customer, then user metadata
      if (_guestFirstNameController.text.isEmpty) {
        if (customer?.firstName != null) {
          _guestFirstNameController.text = customer!.firstName!;
        } else if (user?.userMetadata?['name'] != null) {
          final name = user!.userMetadata!['name'] as String;
          final nameParts = name.split(' ');
          if (nameParts.isNotEmpty) {
            _guestFirstNameController.text = nameParts.first;
          }
        }
      }

      // Last Name - try customer, then user metadata
      if (_guestLastNameController.text.isEmpty) {
        if (customer?.lastName != null) {
          _guestLastNameController.text = customer!.lastName!;
        } else if (user?.userMetadata?['name'] != null) {
          final name = user!.userMetadata!['name'] as String;
          final nameParts = name.split(' ');
          if (nameParts.length > 1) {
            _guestLastNameController.text = nameParts.sublist(1).join(' ');
          }
        }
      }

      // Email - try customer, then auth user email
      if (_guestEmailController.text.isEmpty) {
        _guestEmailController.text = customer?.email ?? user?.email ?? '';
      }

      // Phone - try customer, then user metadata/auth phone
      if (_guestPhoneController.text.isEmpty) {
        final phone =
            customer?.phone ??
            user?.userMetadata?['phone'] as String? ??
            user?.phone;
        if (phone != null) {
          _guestPhoneController.text = UsPhoneInputFormatter.format(phone);
        }
      }
    }

    // Auto-select default address if available and convert to DeliveryAddress
    addressesAsync.whenData((addresses) {
      if (addresses.isNotEmpty && _deliveryAddress == null) {
        final defaultAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        setState(() {
          _deliveryAddress = DeliveryAddress(
            streetLine1: defaultAddress.streetLine1,
            streetLine2: defaultAddress.streetLine2,
            city: defaultAddress.city,
            state: defaultAddress.state,
            postalCode: defaultAddress.postalCode,
            country: defaultAddress.country,
            latitude: defaultAddress.latitude,
            longitude: defaultAddress.longitude,
          );
        });
      }
    });

    _hasPrefilledData = true;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _guestFirstNameController.dispose();
    _guestLastNameController.dispose();
    _guestEmailController.dispose();
    _guestPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    final auth = ref.watch(authProvider);

    // Calculate totals using provider (real Uber Direct quote)
    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    final totals = checkoutNotifier.calculateTotals();

    // Determine if guest checkout (not authenticated or no customer)
    final isGuest = !auth.isAuthenticated || auth.customer == null;

    // Ensure _currentStep is within valid bounds for the current step count
    // Guest has 4 steps (0-3), authenticated has 3 steps (0-2)
    final maxStep = isGuest ? 3 : 2;
    final safeCurrentStep = _currentStep.clamp(0, maxStep);
    if (_currentStep != safeCurrentStep) {
      // Schedule state update after build to sync the actual state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentStep != safeCurrentStep) {
          setState(() => _currentStep = safeCurrentStep);
        }
      });
    }

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Your cart is empty')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          Stepper(
            key: ValueKey('stepper_${isGuest ? 'guest' : 'auth'}'),
            currentStep: safeCurrentStep,
            onStepContinue: () => _handleStepContinue(checkout, isGuest),
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            onStepTapped: (step) {
              setState(() => _currentStep = step);
            },
            controlsBuilder: (context, details) {
              final lastStep = isGuest ? 3 : 2;
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: checkout.isProcessing
                          ? null
                          : details.onStepContinue,
                      child: checkout.isProcessing && safeCurrentStep == lastStep
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              safeCurrentStep == lastStep
                                  ? 'Place Order'
                                  : 'Continue',
                            ),
                    ),
                    if (safeCurrentStep > 0) ...[
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: checkout.isProcessing
                            ? null
                            : details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              // Step 0 (Guest only): Contact Info
              if (isGuest)
                Step(
                  title: const Text('Contact'),
                  content: _buildGuestInfoStep(),
                  isActive: safeCurrentStep >= 0,
                  state: safeCurrentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),

              // Step 1: Delivery
              Step(
                title: const Text('Delivery'),
                content: _buildDeliveryStep(checkout),
                isActive: safeCurrentStep >= (isGuest ? 1 : 0),
                state: safeCurrentStep > (isGuest ? 1 : 0)
                    ? StepState.complete
                    : StepState.indexed,
              ),

              // Step 2: Payment
              Step(
                title: const Text('Payment'),
                content: _buildPaymentStep(checkout),
                isActive: safeCurrentStep >= (isGuest ? 2 : 1),
                state: safeCurrentStep > (isGuest ? 2 : 1)
                    ? StepState.complete
                    : StepState.indexed,
              ),

              // Step 3: Review
              Step(
                title: const Text('Review'),
                content: _buildReviewStep(cart, totals, checkout, isGuest),
                isActive: safeCurrentStep >= (isGuest ? 3 : 2),
                state: StepState.indexed,
              ),
            ],
          ),

          // Error banner
          if (checkout.error != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: context.colors.error,
                  child: Row(
                    children: [
                      const Icon(LucideIcons.circleAlert, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          checkout.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white),
                        onPressed: () {
                          ref.read(checkoutProvider.notifier).clearError();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestInfoStep() {
    return Form(
      key: _guestFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, color: context.colors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enter your contact info to receive order updates. No account required!',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _guestFirstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(LucideIcons.user),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.name(label: 'first name'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _guestLastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.name(label: 'last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _guestEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(LucideIcons.mail),
              hintText: 'For order confirmation',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: AppValidators.email(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _guestPhoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(LucideIcons.phone),
              hintText: '(555) 123-4567',
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: const [UsPhoneInputFormatter()],
            validator: AppValidators.usPhone(),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              context.router.push(const LoginRoute());
            },
            icon: Icon(LucideIcons.logIn, size: 18),
            label: const Text('Already have an account? Sign in'),
          ),
        ],
      ),
    );
  }

  /// Build quick-select chip for default address
  Widget _buildDefaultAddressChip() {
    final addressesAsync = ref.watch(userAddressesProvider);

    return addressesAsync.when(
      data: (addresses) {
        if (addresses.isEmpty) return const SizedBox.shrink();

        // Find default address or use first one
        final defaultAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );

        // Check if current delivery address matches the default
        final isCurrentlySelected =
            _deliveryAddress != null &&
            _deliveryAddress!.streetLine1 == defaultAddress.streetLine1 &&
            _deliveryAddress!.city == defaultAddress.city &&
            _deliveryAddress!.postalCode == defaultAddress.postalCode;

        if (isCurrentlySelected) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _deliveryAddress = DeliveryAddress(
                  streetLine1: defaultAddress.streetLine1,
                  streetLine2: defaultAddress.streetLine2,
                  city: defaultAddress.city,
                  state: defaultAddress.state,
                  postalCode: defaultAddress.postalCode,
                  country: defaultAddress.country,
                  latitude: defaultAddress.latitude,
                  longitude: defaultAddress.longitude,
                  deliveryInstructions: defaultAddress.deliveryInstructions,
                );
              });
              // Auto-trigger delivery quote
              _handleGetDeliveryQuote();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.05),
                border: Border.all(
                  color: context.colors.primary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Use saved address',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (defaultAddress.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Default',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.surface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${defaultAddress.streetLine1}, ${defaultAddress.city}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: context.colors.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDeliveryStep(CheckoutState checkout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fulfillment tabs matching website design
        Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _FulfillmentTab(
                  icon: LucideIcons.store,
                  label: 'Pickup',
                  isSelected: checkout.isPickup,
                  onTap: () => ref
                      .read(checkoutProvider.notifier)
                      .setFulfillmentType(FulfillmentType.pickup),
                ),
              ),
              Expanded(
                child: _FulfillmentTab(
                  icon: LucideIcons.truck,
                  label: 'Delivery',
                  isSelected: checkout.isDelivery,
                  onTap: () => ref
                      .read(checkoutProvider.notifier)
                      .setFulfillmentType(FulfillmentType.delivery),
                ),
              ),
            ],
          ),
        ),

        // Show prompt when no selection made
        if (!checkout.hasFulfillmentType) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.05),
              border: Border.all(color: context.colors.primary.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.info,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please select how you would like to receive your order',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (checkout.isDelivery) ...[
          const SizedBox(height: 20),

          // Quick-select default address chip
          _buildDefaultAddressChip(),

          // Modern Address Picker - Clean, simple, beautiful
          ModernAddressPicker(
            initialAddress: _deliveryAddress,
            onAddressChanged: (address) {
              setState(() {
                _deliveryAddress = address;
              });
              // Auto-trigger delivery quote when address is confirmed
              _handleGetDeliveryQuote();
            },
          ),

          // Delivery Quote Section - shown after address is selected
          if (_deliveryAddress != null) ...[
            const SizedBox(height: 20),
            _buildDeliveryQuoteSection(checkout),
          ],
        ] else if (checkout.isPickup) ...[
          // Pickup location
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.store,
                        color: context.colors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Shahirizada Fresh Market',
                        style: context.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '3124 Illinois Rte 59 Suite 154, Naperville, IL 60564',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mon-Sat: 9am - 8pm • Sun: 10am - 6pm',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Order notes
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Order Notes (optional)',
            hintText: 'Special instructions for your order',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPaymentStep(CheckoutState checkout) {
    final cart = ref.watch(cartProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment method cards matching website design
        _PaymentMethodCard(
          icon: LucideIcons.creditCard,
          title: 'Pay with Card',
          subtitle: 'Secure Stripe Payment',
          isSelected: checkout.paymentMethod == 'card',
          onTap: () =>
              ref.read(checkoutProvider.notifier).setPaymentMethod('card'),
        ),
        // TODO: Enable Apple Pay & Google Pay in next release
        // const SizedBox(height: 12),
        // _PaymentMethodCard(
        //   icon: LucideIcons.wallet,
        //   title: 'Apple Pay',
        //   subtitle: 'Quick and secure',
        //   isSelected: checkout.paymentMethod == 'apple_pay',
        //   onTap: () => ref.read(checkoutProvider.notifier).setPaymentMethod('apple_pay'),
        // ),
        // const SizedBox(height: 12),
        // _PaymentMethodCard(
        //   icon: LucideIcons.smartphone,
        //   title: 'Google Pay',
        //   subtitle: 'Fast checkout',
        //   isSelected: checkout.paymentMethod == 'google_pay',
        //   onTap: () => ref.read(checkoutProvider.notifier).setPaymentMethod('google_pay'),
        // ),
        const SizedBox(height: 24),

        // Tip Selector matching website design
        _TipSelector(
          subtotal: cart.subtotalInDollars,
          selectedTipCents: cart.tipCents,
          isDelivery: checkout.isDelivery,
          onTipChanged: (tipCents) {
            ref.read(cartProvider.notifier).setTip(tipCents);
          },
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.shieldCheck,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your payment is secure. We use Stripe for all transactions.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the delivery quote section with Get Quote button and quote display
  Widget _buildDeliveryQuoteSection(CheckoutState checkout) {
    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    final hasAddress = _deliveryAddress != null && _deliveryAddress!.isValid;
    final quote = checkout.deliveryQuote;
    final isQuoting = checkout.isQuotingDelivery;
    final isExpired = checkoutNotifier.isQuoteExpired;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: quote != null && !isExpired
              ? context.colors.success.withOpacity(0.3)
              : context.colors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.truck, size: 20, color: context.colors.primary),
              const SizedBox(width: 8),
              Text(
                'Delivery Quote',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (quote != null && !isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.circleCheckBig,
                        size: 14,
                        color: context.colors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Valid',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // No quote yet - show get quote button
          if (quote == null && !isQuoting) ...[
            Text(
              hasAddress
                  ? 'Get a delivery quote for your address'
                  : 'Enter your address above to get a delivery quote',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasAddress ? _handleGetDeliveryQuote : null,
                icon: const Icon(LucideIcons.calculator, size: 18),
                label: const Text('Get Delivery Quote'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],

          // Loading state
          if (isQuoting) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Getting delivery quote...',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          // Quote received - show details
          if (quote != null && !isQuoting) ...[
            // Fee and ETA row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Fee',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        quote.formattedFee,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (quote.etaMinutes != null) ...[
                  Container(
                    width: 1,
                    height: 40,
                    color: context.colors.borderLight,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Time',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 16,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '~${quote.etaMinutes} min',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // Expiration warning or refresh button
            const SizedBox(height: 12),
            if (isExpired) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.circleAlert,
                      size: 16,
                      color: context.colors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Quote expired. Please get a new quote.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleGetDeliveryQuote,
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Refresh Quote'),
                ),
              ),
            ] else ...[
              // Show expiration countdown
              Row(
                children: [
                  Icon(
                    LucideIcons.timer,
                    size: 14,
                    color: context.colors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Quote valid for ~15 minutes',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _handleGetDeliveryQuote,
                    icon: const Icon(LucideIcons.refreshCw, size: 14),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Handle getting delivery quote
  Future<void> _handleGetDeliveryQuote() async {
    if (_deliveryAddress == null || !_deliveryAddress!.isValid) return;

    final checkoutNotifier = ref.read(checkoutProvider.notifier);

    // Create address from DeliveryAddress
    final now = DateTime.now();
    final address = Address(
      id: 'temp-${now.millisecondsSinceEpoch}',
      tenantId: EnvConfig.tenantId,
      customerId: null,
      streetLine1: _deliveryAddress!.streetLine1,
      streetLine2: _deliveryAddress!.streetLine2,
      city: _deliveryAddress!.city,
      state: _deliveryAddress!.state,
      postalCode: _deliveryAddress!.postalCode,
      country: _deliveryAddress!.country,
      latitude: _deliveryAddress!.latitude,
      longitude: _deliveryAddress!.longitude,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    checkoutNotifier.setAddress(address);
    await checkoutNotifier.getDeliveryQuote();
  }

  Widget _buildReviewStep(
    CartState cart,
    CheckoutTotals totals,
    CheckoutState checkout,
    bool isGuest,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Cart items
        ...cart.items.map(
          (item) => _OrderSummaryItem(
            name: item.name,
            quantity: item.formattedQuantity,
            price: item.totalInDollars,
          ),
        ),

        // Fee breakdown matching website design
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Subtotal', value: totals.formattedSubtotal),
              // Promo Code Input - right after subtotal (traditional placement)
              const SizedBox(height: 12),
              const PromoCodeInput(),
              if (totals.discountCents > 0) ...[
                const SizedBox(height: 8),
                _SummaryRow(
                  label: checkout.promoCode ?? "Discount",
                  value: "-\$${(totals.discountCents / 100).toStringAsFixed(2)}",
                  valueColor: context.colors.success,
                ),
              ],
              if (totals.taxCents > 0) ...[
                const SizedBox(height: 8),
                _SummaryRow(label: 'Tax', value: totals.formattedTax),
              ],
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Delivery',
                value: checkout.isPickup
                    ? 'Pickup'
                    : (totals.deliveryFeeCents == 0
                          ? 'Quote required'
                          : totals.formattedDeliveryFee),
                valueColor: checkout.isPickup
                    ? context.colors.success
                    : (totals.deliveryFeeCents == 0
                          ? context.colors.warning
                          : null),
              ),
              // Show ETA if we have a quote
              if (checkout.isDelivery &&
                  checkout.deliveryQuote?.etaMinutes != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 12,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '~${checkout.deliveryQuote!.etaMinutes} min',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (totals.tipCents > 0) ...[
                const SizedBox(height: 8),
                _SummaryRow(label: 'Tip', value: totals.formattedTip),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _SummaryRow(
                label: 'Total',
                value: totals.formattedTotal,
                isBold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Delivery/Pickup info - tappable to go back to delivery step
        InkWell(
          onTap: () {
            // Navigate back to delivery step
            final deliveryStep = isGuest ? 1 : 0;
            setState(() => _currentStep = deliveryStep);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkout.isDelivery
                            ? 'Delivery Address'
                            : 'Pickup Location',
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        checkout.isDelivery
                            ? _getDeliveryAddress()
                            : 'Shahirizada Fresh Market\n3124 Illinois Rte 59 Suite 154\nNaperville, IL 60564',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.pencil,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
          ),
        ),

        if (_notesController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              // Navigate back to delivery step
              final deliveryStep = isGuest ? 1 : 0;
              setState(() => _currentStep = deliveryStep);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Notes',
                          style: context.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _notesController.text,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: context.colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Guest contact info
        if (isGuest && checkout.guestInfo != null) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              // Navigate back to guest info step (step 0)
              setState(() => _currentStep = 0);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: context.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkout.guestInfo!.fullName,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        Text(
                          checkout.guestInfo!.email,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        Text(
                          checkout.guestInfo!.phone,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: context.colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getDeliveryAddress() {
    if (_deliveryAddress != null && _deliveryAddress!.isValid) {
      final apt = _deliveryAddress!.streetLine2?.isNotEmpty == true
          ? ', ${_deliveryAddress!.streetLine2}'
          : '';
      return '${_deliveryAddress!.streetLine1}$apt\n${_deliveryAddress!.city}, ${_deliveryAddress!.state} ${_deliveryAddress!.postalCode}';
    }
    return 'No address selected';
  }

  bool _validateGuestInfo() {
    debugPrint('🔘 Validating guest info form...');
    if (!_guestFormKey.currentState!.validate()) {
      debugPrint('❌ Guest info form validation failed');
      return false;
    }
    // Save guest info to checkout state
    debugPrint('✅ Guest info form valid, saving...');
    ref
        .read(checkoutProvider.notifier)
        .setGuestInfo(
          GuestInfo(
            firstName: _guestFirstNameController.text.trim(),
            lastName: _guestLastNameController.text.trim(),
            email: _guestEmailController.text.trim(),
            phone: _guestPhoneController.text.trim(),
          ),
        );
    return true;
  }

  bool _validateDelivery(CheckoutState checkout) {
    debugPrint('🔘 At delivery step, fulfillmentType=${checkout.fulfillmentType}, isDelivery=${checkout.isDelivery}');

    // Validate that a fulfillment type has been selected
    if (!checkout.hasFulfillmentType) {
      debugPrint('❌ No fulfillment type selected');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select Pickup or Delivery'),
          backgroundColor: context.colors.error,
        ),
      );
      return false;
    }

    if (checkout.isDelivery) {
      // Check if we have a valid delivery address
      debugPrint(
        '🔘 Checking delivery address: $_deliveryAddress, isValid=${_deliveryAddress?.isValid}',
      );
      if (_deliveryAddress == null || !_deliveryAddress!.isValid) {
        debugPrint('❌ Delivery address invalid');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a delivery address'),
            backgroundColor: context.colors.error,
          ),
        );
        return false;
      }

      // Require valid delivery quote for delivery orders
      final checkoutNotifier = ref.read(checkoutProvider.notifier);
      debugPrint(
        '🔘 Checking delivery quote: hasValid=${checkoutNotifier.hasValidDeliveryQuote}, quote=${checkout.deliveryQuote?.quoteId}',
      );
      if (!checkoutNotifier.hasValidDeliveryQuote) {
        debugPrint('❌ No valid delivery quote');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              checkoutNotifier.isQuoteExpired
                  ? 'Your delivery quote has expired. Please get a new quote.'
                  : 'Please get a delivery quote before continuing.',
            ),
            backgroundColor: context.colors.error,
            action: SnackBarAction(
              label: 'Get Quote',
              textColor: Colors.white,
              onPressed: _handleGetDeliveryQuote,
            ),
          ),
        );
        return false;
      }

      // Validate phone number is available for delivery (required by Uber Direct)
      final auth = ref.read(authProvider);
      final guestInfo = checkout.guestInfo;
      final phone =
          guestInfo?.phone ??
          auth.customer?.phone ??
          _guestPhoneController.text.trim();
      debugPrint('🔘 Checking phone for delivery: $phone');
      if (phone.isEmpty) {
        debugPrint('❌ Phone number missing for delivery');
        final isAuthenticated = auth.customer != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Phone number is required for delivery orders'),
            backgroundColor: context.colors.error,
            action: isAuthenticated
                ? SnackBarAction(
                    label: 'Edit Profile',
                    textColor: Colors.white,
                    onPressed: () {
                      context.router.push(const EditProfileRoute());
                    },
                  )
                : null,
          ),
        );
        return false;
      }
      if (!AppValidators.isValidUsPhone(phone)) {
        debugPrint('❌ Phone number invalid for delivery');
        final isAuthenticated = auth.customer != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Enter a valid US phone number'),
            backgroundColor: context.colors.error,
            action: isAuthenticated
                ? SnackBarAction(
                    label: 'Edit Profile',
                    textColor: Colors.white,
                    onPressed: () {
                      context.router.push(const EditProfileRoute());
                    },
                  )
                : null,
          ),
        );
        return false;
      }

      debugPrint('✅ Delivery address, quote, and phone valid');
    }
    return true;
  }

  bool _validateAllSteps(CheckoutState checkout, bool isGuest) {
    if (isGuest) {
      if (!_validateGuestInfo()) {
        setState(() => _currentStep = 0);
        return false;
      }
    } else {
      // For authenticated users, still ensure contact info is captured
      // This is needed because phone is required for delivery orders
      _ensureContactInfoCaptured();
    }

    // Delivery step is 0 or 1
    final deliveryStep = isGuest ? 1 : 0;
    if (!_validateDelivery(checkout)) {
      setState(() => _currentStep = deliveryStep);
      return false;
    }

    return true;
  }

  /// Ensure contact info from prefilled controllers is captured for authenticated users
  /// This matches web behavior where phone is required for delivery orders
  void _ensureContactInfoCaptured() {
    final auth = ref.read(authProvider);
    final currentGuestInfo = ref.read(checkoutProvider).guestInfo;

    // Get phone from controller or customer record
    final phone = _guestPhoneController.text.trim().isNotEmpty
        ? _guestPhoneController.text.trim()
        : auth.customer?.phone ?? '';

    // Get other info from controllers or customer record
    final firstName = _guestFirstNameController.text.trim().isNotEmpty
        ? _guestFirstNameController.text.trim()
        : auth.customer?.firstName ?? '';
    final lastName = _guestLastNameController.text.trim().isNotEmpty
        ? _guestLastNameController.text.trim()
        : auth.customer?.lastName ?? '';
    final email = _guestEmailController.text.trim().isNotEmpty
        ? _guestEmailController.text.trim()
        : auth.customer?.email ?? auth.user?.email ?? '';

    // Only update if we have meaningful data and guestInfo not already set
    if (currentGuestInfo == null &&
        (firstName.isNotEmpty || email.isNotEmpty || phone.isNotEmpty)) {
      ref
          .read(checkoutProvider.notifier)
          .setGuestInfo(
            GuestInfo(
              firstName: firstName,
              lastName: lastName,
              email: email,
              phone: phone,
            ),
          );
    }
  }

  void _handleStepContinue(CheckoutState checkout, bool isGuest) {
    final lastStep = isGuest ? 3 : 2;
    final deliveryStep = isGuest ? 1 : 0;
    debugPrint(
      '🔘 _handleStepContinue: currentStep=$_currentStep, lastStep=$lastStep, deliveryStep=$deliveryStep, isGuest=$isGuest',
    );

    // If we are at the last step (Place Order), validate EVERYTHING
    if (_currentStep == lastStep) {
      debugPrint('🔘 At last step, validating all steps...');
      if (_validateAllSteps(checkout, isGuest)) {
        debugPrint('✅ All steps valid, processing order...');
        _processOrder(checkout);
      }
      return;
    }

    // Otherwise, validate current step before proceeding
    if (isGuest && _currentStep == 0) {
      if (!_validateGuestInfo()) return;
    } else if (_currentStep == deliveryStep) {
      if (!_validateDelivery(checkout)) return;
    }

    if (_currentStep < lastStep) {
      debugPrint(
        '🔘 Moving to next step: $_currentStep -> ${_currentStep + 1}',
      );
      setState(() => _currentStep++);
    }
  }

  Future<void> _processOrder(CheckoutState checkout) async {
    if (checkout.isDelivery && _deliveryAddress != null) {
      // Create address from DeliveryAddress for checkout
      final now = DateTime.now();
      final address = Address(
        id: 'temp-${now.millisecondsSinceEpoch}',
        tenantId: EnvConfig.tenantId,
        customerId: null,
        streetLine1: _deliveryAddress!.streetLine1,
        streetLine2: _deliveryAddress!.streetLine2,
        city: _deliveryAddress!.city,
        state: _deliveryAddress!.state,
        postalCode: _deliveryAddress!.postalCode,
        country: _deliveryAddress!.country,
        latitude: _deliveryAddress!.latitude,
        longitude: _deliveryAddress!.longitude,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );
      // Use clearQuote: false to preserve the delivery quote that was already fetched
      ref
          .read(checkoutProvider.notifier)
          .setAddress(address, clearQuote: false);
    }

    // Combine order notes with delivery instructions
    final notes = [
      if (_notesController.text.isNotEmpty) _notesController.text,
      if (_deliveryAddress?.deliveryInstructions?.isNotEmpty == true)
        'Delivery instructions: ${_deliveryAddress!.deliveryInstructions}',
    ].join('\n');

    final orderResponse = await ref
        .read(checkoutProvider.notifier)
        .processOrder(notes: notes.isNotEmpty ? notes : null);

    if (orderResponse != null && mounted) {
      // Clear cart after successful order
      ref.read(cartProvider.notifier).clear();

      await LiveActivityService.instance.updateOrderActivity(
        orderId: orderResponse.order.id,
        orderNumber: orderResponse.order.orderNumber?.toString(),
        status: orderResponse.order.status,
        fulfillmentType: orderResponse.order.fulfillmentType,
        eta: DateTime.tryParse(
          orderResponse.order.deliveryEta ?? orderResponse.order.pickupEta ?? '',
        ),
      );

      // Navigate to order confirmation screen
      // Extract contact info from order response for cancellation verification
      final contact = orderResponse.order.contact;
      context.router.replaceAll([
        OrderConfirmationRoute(
          orderId: orderResponse.order.id,
          orderNumber: orderResponse.order.orderNumber?.toString(),
          pickupCode: orderResponse.order.shortCode,
          fulfillmentType: orderResponse.order.fulfillmentType,
          totalCents:
              (orderResponse.order.totals['totalCents'] as num?)?.toInt() ?? 0,
          starsEarned: orderResponse.loyalty?.starsEarned,
          newStarBalance: orderResponse.loyalty?.newBalance,
          orderCreatedAt: DateTime.parse(orderResponse.order.createdAt),
          customerPhone: contact?['phone'] as String?,
          customerEmail: contact?['email'] as String?,
        ),
      ]);
    }
  }
}

class _OrderSummaryItem extends StatelessWidget {
  final String name;
  final String quantity;
  final double price;

  const _OrderSummaryItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Text(quantity),
          const SizedBox(width: 16),
          Text('\$${price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? context.textTheme.titleMedium
              : context.textTheme.bodyMedium,
        ),
        Text(
          value,
          style:
              (isBold
                      ? context.textTheme.titleMedium
                      : context.textTheme.bodyMedium)
                  ?.copyWith(
                    color:
                        valueColor ?? (isBold ? context.colors.primary : null),
                  ),
        ),
      ],
    );
  }
}

/// Fulfillment tab widget matching website design
class _FulfillmentTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FulfillmentTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = context.colors.primary;
    final unselectedColor = context.colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment method card widget matching website design
class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryColor : context.colors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? primaryColor.withOpacity(0.05)
              : context.colors.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.1)
                    : context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? primaryColor : context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? primaryColor
                          : context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.circleCheckBig, color: primaryColor, size: 22)
            else
              Icon(
                LucideIcons.circle,
                color: context.colors.textTertiary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// Tip selector widget matching website design
class _TipSelector extends StatefulWidget {
  final double subtotal;
  final int selectedTipCents;
  final bool isDelivery;
  final ValueChanged<int> onTipChanged;

  const _TipSelector({
    required this.subtotal,
    required this.selectedTipCents,
    required this.isDelivery,
    required this.onTipChanged,
  });

  @override
  State<_TipSelector> createState() => _TipSelectorState();
}

class _TipSelectorState extends State<_TipSelector> {
  final _customController = TextEditingController();
  bool _isCustom = false;

  // Tip presets matching website (15%, 18%, 20%, 25%)
  List<_TipPreset> get _presets => [
    _TipPreset(label: '15%', cents: (widget.subtotal * 0.15 * 100).round()),
    _TipPreset(label: '18%', cents: (widget.subtotal * 0.18 * 100).round()),
    _TipPreset(label: '20%', cents: (widget.subtotal * 0.20 * 100).round()),
    _TipPreset(label: '25%', cents: (widget.subtotal * 0.25 * 100).round()),
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.heart, size: 18, color: primaryColor),
            const SizedBox(width: 8),
            Text('Add a Tip (Optional)', style: context.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),

        // Tip allocation message matching web repo
        Text(
          widget.isDelivery
              ? '100% of your tip goes directly to your Uber Direct courier.'
              : 'Tips are optional for pickup orders.',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Tip preset buttons
        Row(
          children: _presets.map((preset) {
            final isSelected =
                !_isCustom && widget.selectedTipCents == preset.cents;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: preset != _presets.last ? 8 : 0,
                ),
                child: _TipButton(
                  label: preset.label,
                  amount: preset.cents / 100,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _isCustom = false);
                    _customController.clear();
                    widget.onTipChanged(preset.cents);
                  },
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Custom tip input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Custom amount',
                  prefixText: '\$ ',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isCustom
                          ? primaryColor
                          : context.colors.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _isCustom = true);
                  final amount = double.tryParse(value) ?? 0;
                  widget.onTipChanged((amount * 100).round());
                },
              ),
            ),
            if (_customController.text.isNotEmpty ||
                widget.selectedTipCents > 0) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() => _isCustom = false);
                  _customController.clear();
                  widget.onTipChanged(0);
                },
                child: const Text('Clear'),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.heart, size: 14, color: Colors.pink[400]),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '100% of your tip goes directly to the courier',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TipPreset {
  final String label;
  final int cents;

  const _TipPreset({required this.label, required this.cents});
}

/// Individual tip button widget
class _TipButton extends StatelessWidget {
  final String label;
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipButton({
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : context.colors.surface,
          border: Border.all(
            color: isSelected ? primaryColor : context.colors.borderLight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: context.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.7)
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
