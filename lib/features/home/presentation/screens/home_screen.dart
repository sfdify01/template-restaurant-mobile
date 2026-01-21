import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/toast_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../data/models/models.dart';
import '../../providers/menu_provider.dart';
import '../../../cart/providers/cart_provider.dart';
import '../widgets/category_emoji_chip.dart';
import '../widgets/modern_product_card.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItemsAsync = ref.watch(menuItemsProvider);
    final categoriesAsync = ref.watch(menuCategoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(menuItemsProvider);
            ref.invalidate(menuCategoriesProvider);
          },
          color: context.colors.primary,
          child: CustomScrollView(
            slivers: [
              // App Bar with Logo and Search
              SliverToBoxAdapter(child: _buildHeader()),

              // Search Bar
              SliverToBoxAdapter(child: _buildSearchBar()),

              // Categories - Emoji Horizontal Scroll (like web tabs)
              SliverToBoxAdapter(
                child: categoriesAsync.when(
                  data: (categories) => _buildCategoryBar(categories),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                ),
              ),

              // Products Grid
              menuItemsAsync.when(
                data: (items) {
                  final filteredItems = _getFilteredItems(items);
                  return _buildProductsGrid(filteredItems);
                },
                loading: () => SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: _buildErrorState(
                    UserErrorMessage.from(
                      e,
                      fallback: 'Unable to load menu. Please try again.',
                    ),
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Logo and Title
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.store, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shahirizada',
                  style: context.textTheme.titleLarge?.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Fresh Market',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Cart icon with badge
          _buildCartButton(),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.shoppingBag),
          iconSize: 24,
          onPressed: () {
            context.router.navigate(const CartTab());
          },
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textTertiary,
            ),
            prefixIcon: Icon(
              LucideIcons.search,
              color: context.colors.textTertiary,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    color: context.colors.textTertiary,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text('Categories', style: context.textTheme.headlineSmall),
        ),

        // Horizontal scrollable category chips with emojis
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1, // +1 for "All" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All Products" option
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryEmojiChip(
                    categoryName: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                );
              }

              final category = categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryEmojiChip(
                  categoryName: category,
                  isSelected: _selectedCategory == category,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProductsGrid(List<MenuItem> items) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.searchX,
                size: 64,
                color: context.colors.textTertiary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return ModernProductCard(
            item: item,
            onTap: () {
              context.router.push(ProductDetailRoute(productId: item.id));
            },
            onAddToCart: (qty) {
              ref.read(cartProvider.notifier).addFromMenuItem(item, qty: qty);
              _showAddToCartToast(item.name, qty);
            },
          );
        }, childCount: items.length),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 64,
              color: context.colors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text('Something went wrong', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(menuItemsProvider);
              },
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<MenuItem> _getFilteredItems(List<MenuItem> items) {
    var filtered = items;

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false) ||
            (item.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _showAddToCartToast(String itemName, double qty) {
    AppToast.showCartAdded(
      context: context,
      itemName: itemName,
      quantity: qty,
      onViewCart: () {
        context.router.navigate(const CartTab());
      },
    );
  }
}
