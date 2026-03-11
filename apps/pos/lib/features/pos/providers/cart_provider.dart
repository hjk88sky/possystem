import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/pos_local_cache.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier(this._cache) : super(const []);

  final PosLocalCache _cache;

  Future<void> restoreDraft() async {
    state = await _cache.loadCartItems();
  }

  void addItem(MenuItem menuItem) {
    final index = state.indexWhere((e) => e.menuItem.id == menuItem.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = updated;
    } else {
      state = [...state, CartItem(menuItem: menuItem)];
    }
    unawaited(_cache.saveCartItems(state));
  }

  void removeItem(String menuItemId) {
    state = state.where((e) => e.menuItem.id != menuItemId).toList();
    unawaited(_cache.saveCartItems(state));
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }

    final updated = [...state];
    final index = updated.indexWhere((e) => e.menuItem.id == menuItemId);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(quantity: quantity);
      state = updated;
      unawaited(_cache.saveCartItems(state));
    }
  }

  void clear() {
    state = const [];
    unawaited(_cache.saveCartItems(state));
  }
}

class PriorityNotifier extends StateNotifier<OrderPriority> {
  PriorityNotifier(this._cache) : super(OrderPriority.normal);

  final PosLocalCache _cache;

  Future<void> restoreDraft() async {
    state = await _cache.loadCartPriority();
  }

  void setPriority(OrderPriority priority) {
    state = priority;
    unawaited(_cache.saveCartPriority(priority));
  }

  void reset() {
    state = OrderPriority.normal;
    unawaited(_cache.saveCartPriority(state));
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref.watch(posLocalCacheProvider));
});

final cartPriorityProvider =
    StateNotifierProvider<PriorityNotifier, OrderPriority>((ref) {
  return PriorityNotifier(ref.watch(posLocalCacheProvider));
});

final cartSubtotalProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.subtotal);
});

final cartTaxProvider = Provider<int>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return (subtotal * 0.1).round();
});

final cartTotalProvider = Provider<int>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final tax = ref.watch(cartTaxProvider);
  return subtotal + tax;
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});
