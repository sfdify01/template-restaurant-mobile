// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$menuItemsHash() => r'c087f1968be1bceefab0f2be0e67c18ad542e911';

/// Fetch all menu items for the tenant
///
/// Copied from [menuItems].
@ProviderFor(menuItems)
final menuItemsProvider = AutoDisposeFutureProvider<List<MenuItem>>.internal(
  menuItems,
  name: r'menuItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$menuItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MenuItemsRef = AutoDisposeFutureProviderRef<List<MenuItem>>;
String _$menuItemsByCategoryHash() =>
    r'678076e4bfd270779b98c29f2948275529a45cae';

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

/// Fetch menu items by category
///
/// Copied from [menuItemsByCategory].
@ProviderFor(menuItemsByCategory)
const menuItemsByCategoryProvider = MenuItemsByCategoryFamily();

/// Fetch menu items by category
///
/// Copied from [menuItemsByCategory].
class MenuItemsByCategoryFamily extends Family<AsyncValue<List<MenuItem>>> {
  /// Fetch menu items by category
  ///
  /// Copied from [menuItemsByCategory].
  const MenuItemsByCategoryFamily();

  /// Fetch menu items by category
  ///
  /// Copied from [menuItemsByCategory].
  MenuItemsByCategoryProvider call(String category) {
    return MenuItemsByCategoryProvider(category);
  }

  @override
  MenuItemsByCategoryProvider getProviderOverride(
    covariant MenuItemsByCategoryProvider provider,
  ) {
    return call(provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'menuItemsByCategoryProvider';
}

/// Fetch menu items by category
///
/// Copied from [menuItemsByCategory].
class MenuItemsByCategoryProvider
    extends AutoDisposeFutureProvider<List<MenuItem>> {
  /// Fetch menu items by category
  ///
  /// Copied from [menuItemsByCategory].
  MenuItemsByCategoryProvider(String category)
    : this._internal(
        (ref) => menuItemsByCategory(ref as MenuItemsByCategoryRef, category),
        from: menuItemsByCategoryProvider,
        name: r'menuItemsByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$menuItemsByCategoryHash,
        dependencies: MenuItemsByCategoryFamily._dependencies,
        allTransitiveDependencies:
            MenuItemsByCategoryFamily._allTransitiveDependencies,
        category: category,
      );

  MenuItemsByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    FutureOr<List<MenuItem>> Function(MenuItemsByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MenuItemsByCategoryProvider._internal(
        (ref) => create(ref as MenuItemsByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MenuItem>> createElement() {
    return _MenuItemsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MenuItemsByCategoryProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MenuItemsByCategoryRef on AutoDisposeFutureProviderRef<List<MenuItem>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _MenuItemsByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<MenuItem>>
    with MenuItemsByCategoryRef {
  _MenuItemsByCategoryProviderElement(super.provider);

  @override
  String get category => (origin as MenuItemsByCategoryProvider).category;
}

String _$menuCategoriesHash() => r'2906bf346dc970cd58a9d93f190e4b06b559c47c';

/// Get unique categories from menu items
///
/// Copied from [menuCategories].
@ProviderFor(menuCategories)
final menuCategoriesProvider = AutoDisposeFutureProvider<List<String>>.internal(
  menuCategories,
  name: r'menuCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$menuCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MenuCategoriesRef = AutoDisposeFutureProviderRef<List<String>>;
String _$searchMenuItemsHash() => r'6840a454de17cd8f2a0195334ac653727572f0be';

/// Search menu items
///
/// Copied from [searchMenuItems].
@ProviderFor(searchMenuItems)
const searchMenuItemsProvider = SearchMenuItemsFamily();

/// Search menu items
///
/// Copied from [searchMenuItems].
class SearchMenuItemsFamily extends Family<AsyncValue<List<MenuItem>>> {
  /// Search menu items
  ///
  /// Copied from [searchMenuItems].
  const SearchMenuItemsFamily();

  /// Search menu items
  ///
  /// Copied from [searchMenuItems].
  SearchMenuItemsProvider call(String query) {
    return SearchMenuItemsProvider(query);
  }

  @override
  SearchMenuItemsProvider getProviderOverride(
    covariant SearchMenuItemsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchMenuItemsProvider';
}

/// Search menu items
///
/// Copied from [searchMenuItems].
class SearchMenuItemsProvider
    extends AutoDisposeFutureProvider<List<MenuItem>> {
  /// Search menu items
  ///
  /// Copied from [searchMenuItems].
  SearchMenuItemsProvider(String query)
    : this._internal(
        (ref) => searchMenuItems(ref as SearchMenuItemsRef, query),
        from: searchMenuItemsProvider,
        name: r'searchMenuItemsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchMenuItemsHash,
        dependencies: SearchMenuItemsFamily._dependencies,
        allTransitiveDependencies:
            SearchMenuItemsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchMenuItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<MenuItem>> Function(SearchMenuItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchMenuItemsProvider._internal(
        (ref) => create(ref as SearchMenuItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MenuItem>> createElement() {
    return _SearchMenuItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchMenuItemsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchMenuItemsRef on AutoDisposeFutureProviderRef<List<MenuItem>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchMenuItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<MenuItem>>
    with SearchMenuItemsRef {
  _SearchMenuItemsProviderElement(super.provider);

  @override
  String get query => (origin as SearchMenuItemsProvider).query;
}

String _$menuItemHash() => r'55e4b724323e65b291e345c21c2f3379ed6ef9c8';

/// Get a single menu item by ID
///
/// Copied from [menuItem].
@ProviderFor(menuItem)
const menuItemProvider = MenuItemFamily();

/// Get a single menu item by ID
///
/// Copied from [menuItem].
class MenuItemFamily extends Family<AsyncValue<MenuItem?>> {
  /// Get a single menu item by ID
  ///
  /// Copied from [menuItem].
  const MenuItemFamily();

  /// Get a single menu item by ID
  ///
  /// Copied from [menuItem].
  MenuItemProvider call(String id) {
    return MenuItemProvider(id);
  }

  @override
  MenuItemProvider getProviderOverride(covariant MenuItemProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'menuItemProvider';
}

/// Get a single menu item by ID
///
/// Copied from [menuItem].
class MenuItemProvider extends AutoDisposeFutureProvider<MenuItem?> {
  /// Get a single menu item by ID
  ///
  /// Copied from [menuItem].
  MenuItemProvider(String id)
    : this._internal(
        (ref) => menuItem(ref as MenuItemRef, id),
        from: menuItemProvider,
        name: r'menuItemProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$menuItemHash,
        dependencies: MenuItemFamily._dependencies,
        allTransitiveDependencies: MenuItemFamily._allTransitiveDependencies,
        id: id,
      );

  MenuItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<MenuItem?> Function(MenuItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MenuItemProvider._internal(
        (ref) => create(ref as MenuItemRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MenuItem?> createElement() {
    return _MenuItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MenuItemProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MenuItemRef on AutoDisposeFutureProviderRef<MenuItem?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _MenuItemProviderElement
    extends AutoDisposeFutureProviderElement<MenuItem?>
    with MenuItemRef {
  _MenuItemProviderElement(super.provider);

  @override
  String get id => (origin as MenuItemProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
