// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAddressesHash() => r'e879421c2ecdf0b28fb8a8b573e57deb17702564';

/// Fetch user addresses
///
/// Copied from [userAddresses].
@ProviderFor(userAddresses)
final userAddressesProvider = AutoDisposeFutureProvider<List<Address>>.internal(
  userAddresses,
  name: r'userAddressesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userAddressesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserAddressesRef = AutoDisposeFutureProviderRef<List<Address>>;
String _$checkoutHash() => r'482e53710b66c31863fd4c8aca790854949f2f1a';

/// Checkout notifier - manages checkout flow matching web business logic
///
/// Copied from [Checkout].
@ProviderFor(Checkout)
final checkoutProvider =
    AutoDisposeNotifierProvider<Checkout, CheckoutState>.internal(
      Checkout.new,
      name: r'checkoutProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkoutHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Checkout = AutoDisposeNotifier<CheckoutState>;
String _$addressManagerHash() => r'cbdb911c1ca61f29ff1163a5c79afe54da76a703';

/// Save a new address
///
/// Copied from [AddressManager].
@ProviderFor(AddressManager)
final addressManagerProvider =
    AutoDisposeAsyncNotifierProvider<AddressManager, void>.internal(
      AddressManager.new,
      name: r'addressManagerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddressManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
