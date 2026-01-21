import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../../../core/config/env_config.dart';
import '../../../data/models/models.dart';

part 'menu_provider.g.dart';

/// Fetch all menu items for the tenant
@riverpod
Future<List<MenuItem>> menuItems(Ref ref) async {
  final response = await supabase
      .from('menu_items')
      .select()
      .eq('tenant_id', EnvConfig.tenantId)
      .eq('is_active', true)
      .order('category')
      .order('name');

  return (response as List)
      .map((item) => MenuItemMapper.fromMap(item))
      .toList();
}

/// Fetch menu items by category
@riverpod
Future<List<MenuItem>> menuItemsByCategory(Ref ref, String category) async {
  final response = await supabase
      .from('menu_items')
      .select()
      .eq('tenant_id', EnvConfig.tenantId)
      .eq('is_active', true)
      .eq('category', category)
      .order('name');

  return (response as List)
      .map((item) => MenuItemMapper.fromMap(item))
      .toList();
}

/// Get unique categories from menu items
@riverpod
Future<List<String>> menuCategories(Ref ref) async {
  final items = await ref.watch(menuItemsProvider.future);
  final categories = items
      .map((item) => item.category)
      .where((category) => category != null)
      .cast<String>()
      .toSet()
      .toList();
  categories.sort();
  return categories;
}

/// Search menu items
@riverpod
Future<List<MenuItem>> searchMenuItems(Ref ref, String query) async {
  if (query.isEmpty) return [];

  final items = await ref.watch(menuItemsProvider.future);
  final lowerQuery = query.toLowerCase();

  return items.where((item) {
    return item.name.toLowerCase().contains(lowerQuery) ||
        (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
        (item.category?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();
}

/// Get a single menu item by ID
@riverpod
Future<MenuItem?> menuItem(Ref ref, String id) async {
  final response = await supabase
      .from('menu_items')
      .select()
      .eq('id', id)
      .maybeSingle();

  if (response == null) return null;
  return MenuItemMapper.fromMap(response);
}
