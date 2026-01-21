import 'package:dart_mappable/dart_mappable.dart';

part 'menu_category.mapper.dart';

/// Menu category model with emoji icon support
@MappableClass(caseStyle: CaseStyle.snakeCase)
class MenuCategory with MenuCategoryMappable {
  final String id;
  final String name;
  final String? description;
  final String icon; // Emoji icon like 🥩, 🍱, 🛒

  const MenuCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
  });

  /// Default categories with emoji icons matching web design
  static const Map<String, MenuCategory> defaultCategories = {
    'fresh-meats': MenuCategory(
      id: 'fresh-meats',
      name: 'Fresh Halal Meats',
      description: 'Premium quality, hand-cut daily',
      icon: '🥩',
    ),
    'beef': MenuCategory(
      id: 'beef',
      name: 'Beef',
      description: 'Premium halal beef cuts',
      icon: '🥩',
    ),
    'lamb': MenuCategory(
      id: 'lamb',
      name: 'Lamb',
      description: 'Fresh halal lamb',
      icon: '🐑',
    ),
    'chicken': MenuCategory(
      id: 'chicken',
      name: 'Chicken',
      description: 'Halal poultry',
      icon: '🍗',
    ),
    'goat': MenuCategory(
      id: 'goat',
      name: 'Goat',
      description: 'Fresh halal goat meat',
      icon: '🐐',
    ),
    'prepared-foods': MenuCategory(
      id: 'prepared-foods',
      name: 'Prepared Foods',
      description: 'Ready to heat and eat',
      icon: '🍱',
    ),
    'groceries': MenuCategory(
      id: 'groceries',
      name: 'Groceries & Staples',
      description: 'Halal-certified products',
      icon: '🛒',
    ),
    'specialty': MenuCategory(
      id: 'specialty',
      name: 'Specialty Items',
      description: 'Imported delicacies',
      icon: '⭐',
    ),
    'spices': MenuCategory(
      id: 'spices',
      name: 'Spices & Seasonings',
      description: 'Authentic Middle Eastern spices',
      icon: '🌶️',
    ),
    'dairy': MenuCategory(
      id: 'dairy',
      name: 'Dairy & Cheese',
      description: 'Fresh dairy products',
      icon: '🧀',
    ),
    'bread': MenuCategory(
      id: 'bread',
      name: 'Bread & Bakery',
      description: 'Fresh baked goods',
      icon: '🥖',
    ),
    'sweets': MenuCategory(
      id: 'sweets',
      name: 'Sweets & Desserts',
      description: 'Traditional sweets',
      icon: '🍬',
    ),
    'beverages': MenuCategory(
      id: 'beverages',
      name: 'Beverages',
      description: 'Drinks and refreshments',
      icon: '🍵',
    ),
  };

  /// Get category icon for a given category name
  static String getIconForCategory(String? categoryName) {
    if (categoryName == null) return '📦';

    // Handle "All" special case
    if (categoryName.toLowerCase() == 'all') return '🏪';

    final lower = categoryName.toLowerCase();

    // Check for exact matches first
    for (final entry in defaultCategories.entries) {
      if (lower == entry.key || lower == entry.value.name.toLowerCase()) {
        return entry.value.icon;
      }
    }

    // Check for partial matches
    if (lower.contains('beef') || lower.contains('meat')) return '🥩';
    if (lower.contains('lamb')) return '🐑';
    if (lower.contains('chicken') || lower.contains('poultry')) return '🍗';
    if (lower.contains('goat')) return '🐐';
    if (lower.contains('prepared') || lower.contains('ready')) return '🍱';
    if (lower.contains('grocer') || lower.contains('staple')) return '🛒';
    if (lower.contains('special') || lower.contains('premium')) return '⭐';
    if (lower.contains('spice') || lower.contains('season')) return '🌶️';
    if (lower.contains('dairy') || lower.contains('cheese')) return '🧀';
    if (lower.contains('bread') || lower.contains('bake')) return '🥖';
    if (lower.contains('sweet') || lower.contains('dessert')) return '🍬';
    if (lower.contains('drink') || lower.contains('beverage')) return '🍵';
    if (lower.contains('fresh')) return '🌿';
    if (lower.contains('halal')) return '☪️';

    return '📦'; // Default
  }

  /// Get dietary icon for dietary tag
  static String getDietaryIcon(String tag) {
    final lower = tag.toLowerCase();
    if (lower == 'halal') return '☪️';
    if (lower == 'vegetarian') return '🥬';
    if (lower == 'vegan') return '🌱';
    if (lower == 'gluten-free' || lower == 'gf') return '🌾';
    if (lower == 'organic') return '🍃';
    if (lower == 'kosher') return '✡️';
    return '✓';
  }
}
