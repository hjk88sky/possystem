import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/pos/models/cart_item.dart';
import '../../features/pos/models/category.dart';
import '../../features/pos/models/menu_item.dart';
import '../../features/pos/models/order.dart';

final posLocalCacheProvider = Provider<PosLocalCache>((ref) {
  return const PosLocalCache();
});

class PosLocalCache {
  const PosLocalCache();

  static const _categoriesKey = 'pos.cached_categories';
  static const _menuItemsKey = 'pos.cached_menu_items';
  static const _cartItemsKey = 'pos.draft_cart_items';
  static const _cartPriorityKey = 'pos.draft_cart_priority';

  Future<void> saveCategories(List<Category> categories) async {
    await _writeJsonList(
      _categoriesKey,
      categories.map((category) => category.toJson()).toList(),
    );
  }

  Future<List<Category>> loadCategories() async {
    return _readJsonList(
      _categoriesKey,
      (json) => Category.fromJson(json),
    );
  }

  Future<void> saveMenuItems(List<MenuItem> items) async {
    await _writeJsonList(
      _menuItemsKey,
      items.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<MenuItem>> loadMenuItems() async {
    return _readJsonList(
      _menuItemsKey,
      (json) => MenuItem.fromJson(json),
    );
  }

  Future<void> saveCartItems(List<CartItem> items) async {
    await _writeJsonList(
      _cartItemsKey,
      items.map(_cartItemToJson).toList(),
    );
  }

  Future<List<CartItem>> loadCartItems() async {
    return _readJsonList(
      _cartItemsKey,
      _cartItemFromJson,
    );
  }

  Future<void> saveCartPriority(OrderPriority priority) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartPriorityKey, priority.apiValue);
  }

  Future<OrderPriority> loadCartPriority() async {
    final prefs = await SharedPreferences.getInstance();
    return orderPriorityFromApiValue(prefs.getString(_cartPriorityKey)) ??
        OrderPriority.normal;
  }

  Future<void> clearCartDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartItemsKey);
    await prefs.remove(_cartPriorityKey);
  }

  Future<void> _writeJsonList(
    String key,
    List<Map<String, dynamic>> values,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(values));
  }

  Future<List<T>> _readJsonList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((entry) => fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

OrderPriority? orderPriorityFromApiValue(String? value) {
  switch (value?.toUpperCase()) {
    case 'URGENT':
      return OrderPriority.urgent;
    case 'HIGH':
      return OrderPriority.high;
    case 'NORMAL':
      return OrderPriority.normal;
    case 'LOW':
      return OrderPriority.low;
    default:
      return null;
  }
}

Map<String, dynamic> _cartItemToJson(CartItem item) {
  return <String, dynamic>{
    'menuItem': item.menuItem.toJson(),
    'quantity': item.quantity,
  };
}

CartItem _cartItemFromJson(Map<String, dynamic> json) {
  final rawMenuItem = json['menuItem'];
  return CartItem(
    menuItem: MenuItem.fromJson(Map<String, dynamic>.from(rawMenuItem as Map)),
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  );
}
