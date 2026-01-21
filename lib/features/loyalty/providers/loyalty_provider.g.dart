// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loyaltyProfileHash() => r'459927c43f11295fc547b55c2f5208735e3c55d0';

/// Fetch the current user's loyalty profile
/// Matches web implementation - looks up by email (primary) or phone
///
/// Copied from [loyaltyProfile].
@ProviderFor(loyaltyProfile)
final loyaltyProfileProvider =
    AutoDisposeFutureProvider<LoyaltyProfile?>.internal(
      loyaltyProfile,
      name: r'loyaltyProfileProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loyaltyProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoyaltyProfileRef = AutoDisposeFutureProviderRef<LoyaltyProfile?>;
String _$loyaltyEventsHash() => r'4ddad3c4e20fdcd93208fdd9539ffc2c08f94b49';

/// Fetch loyalty events/history for the current user
///
/// Copied from [loyaltyEvents].
@ProviderFor(loyaltyEvents)
final loyaltyEventsProvider =
    AutoDisposeFutureProvider<List<LoyaltyEvent>>.internal(
      loyaltyEvents,
      name: r'loyaltyEventsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loyaltyEventsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoyaltyEventsRef = AutoDisposeFutureProviderRef<List<LoyaltyEvent>>;
String _$starsToNextTierHash() => r'cbc5f9873559db8ae290aee8dc8b859876c4da62';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Calculate stars needed for next tier
///
/// Copied from [starsToNextTier].
@ProviderFor(starsToNextTier)
const starsToNextTierProvider = StarsToNextTierFamily();

/// Calculate stars needed for next tier
///
/// Copied from [starsToNextTier].
class StarsToNextTierFamily extends Family<int> {
  /// Calculate stars needed for next tier
  ///
  /// Copied from [starsToNextTier].
  const StarsToNextTierFamily();

  /// Calculate stars needed for next tier
  ///
  /// Copied from [starsToNextTier].
  StarsToNextTierProvider call(LoyaltyTier currentTier, int lifetimeStars) {
    return StarsToNextTierProvider(currentTier, lifetimeStars);
  }

  @override
  StarsToNextTierProvider getProviderOverride(
    covariant StarsToNextTierProvider provider,
  ) {
    return call(provider.currentTier, provider.lifetimeStars);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'starsToNextTierProvider';
}

/// Calculate stars needed for next tier
///
/// Copied from [starsToNextTier].
class StarsToNextTierProvider extends AutoDisposeProvider<int> {
  /// Calculate stars needed for next tier
  ///
  /// Copied from [starsToNextTier].
  StarsToNextTierProvider(LoyaltyTier currentTier, int lifetimeStars)
    : this._internal(
        (ref) => starsToNextTier(
          ref as StarsToNextTierRef,
          currentTier,
          lifetimeStars,
        ),
        from: starsToNextTierProvider,
        name: r'starsToNextTierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$starsToNextTierHash,
        dependencies: StarsToNextTierFamily._dependencies,
        allTransitiveDependencies:
            StarsToNextTierFamily._allTransitiveDependencies,
        currentTier: currentTier,
        lifetimeStars: lifetimeStars,
      );

  StarsToNextTierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.currentTier,
    required this.lifetimeStars,
  }) : super.internal();

  final LoyaltyTier currentTier;
  final int lifetimeStars;

  @override
  Override overrideWith(int Function(StarsToNextTierRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: StarsToNextTierProvider._internal(
        (ref) => create(ref as StarsToNextTierRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        currentTier: currentTier,
        lifetimeStars: lifetimeStars,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _StarsToNextTierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StarsToNextTierProvider &&
        other.currentTier == currentTier &&
        other.lifetimeStars == lifetimeStars;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, currentTier.hashCode);
    hash = _SystemHash.combine(hash, lifetimeStars.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StarsToNextTierRef on AutoDisposeProviderRef<int> {
  /// The parameter `currentTier` of this provider.
  LoyaltyTier get currentTier;

  /// The parameter `lifetimeStars` of this provider.
  int get lifetimeStars;
}

class _StarsToNextTierProviderElement extends AutoDisposeProviderElement<int>
    with StarsToNextTierRef {
  _StarsToNextTierProviderElement(super.provider);

  @override
  LoyaltyTier get currentTier =>
      (origin as StarsToNextTierProvider).currentTier;
  @override
  int get lifetimeStars => (origin as StarsToNextTierProvider).lifetimeStars;
}

String _$tierProgressHash() => r'52c6660640f659ba795bd4966f51a98a531fee10';

/// Calculate tier progress percentage
///
/// Copied from [tierProgress].
@ProviderFor(tierProgress)
const tierProgressProvider = TierProgressFamily();

/// Calculate tier progress percentage
///
/// Copied from [tierProgress].
class TierProgressFamily extends Family<double> {
  /// Calculate tier progress percentage
  ///
  /// Copied from [tierProgress].
  const TierProgressFamily();

  /// Calculate tier progress percentage
  ///
  /// Copied from [tierProgress].
  TierProgressProvider call(LoyaltyTier currentTier, int lifetimeStars) {
    return TierProgressProvider(currentTier, lifetimeStars);
  }

  @override
  TierProgressProvider getProviderOverride(
    covariant TierProgressProvider provider,
  ) {
    return call(provider.currentTier, provider.lifetimeStars);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tierProgressProvider';
}

/// Calculate tier progress percentage
///
/// Copied from [tierProgress].
class TierProgressProvider extends AutoDisposeProvider<double> {
  /// Calculate tier progress percentage
  ///
  /// Copied from [tierProgress].
  TierProgressProvider(LoyaltyTier currentTier, int lifetimeStars)
    : this._internal(
        (ref) =>
            tierProgress(ref as TierProgressRef, currentTier, lifetimeStars),
        from: tierProgressProvider,
        name: r'tierProgressProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tierProgressHash,
        dependencies: TierProgressFamily._dependencies,
        allTransitiveDependencies:
            TierProgressFamily._allTransitiveDependencies,
        currentTier: currentTier,
        lifetimeStars: lifetimeStars,
      );

  TierProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.currentTier,
    required this.lifetimeStars,
  }) : super.internal();

  final LoyaltyTier currentTier;
  final int lifetimeStars;

  @override
  Override overrideWith(double Function(TierProgressRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TierProgressProvider._internal(
        (ref) => create(ref as TierProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        currentTier: currentTier,
        lifetimeStars: lifetimeStars,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _TierProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TierProgressProvider &&
        other.currentTier == currentTier &&
        other.lifetimeStars == lifetimeStars;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, currentTier.hashCode);
    hash = _SystemHash.combine(hash, lifetimeStars.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TierProgressRef on AutoDisposeProviderRef<double> {
  /// The parameter `currentTier` of this provider.
  LoyaltyTier get currentTier;

  /// The parameter `lifetimeStars` of this provider.
  int get lifetimeStars;
}

class _TierProgressProviderElement extends AutoDisposeProviderElement<double>
    with TierProgressRef {
  _TierProgressProviderElement(super.provider);

  @override
  LoyaltyTier get currentTier => (origin as TierProgressProvider).currentTier;
  @override
  int get lifetimeStars => (origin as TierProgressProvider).lifetimeStars;
}

String _$redeemStarsHash() => r'719367b0ad259044c25371a05eab7f554b6dd735';

/// Redeem stars for rewards
///
/// Copied from [RedeemStars].
@ProviderFor(RedeemStars)
final redeemStarsProvider =
    AutoDisposeAsyncNotifierProvider<RedeemStars, void>.internal(
      RedeemStars.new,
      name: r'redeemStarsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$redeemStarsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RedeemStars = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
