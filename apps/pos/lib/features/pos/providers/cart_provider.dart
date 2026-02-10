import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

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
  }

  void removeItem(int menuItemId) {
    state = state.where((e) => e.menuItem.id != menuItemId).toList();
  }

  void updateQuantity(int menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }
    final updated = [...state];
    final index = updated.indexWhere((e) => e.menuItem.id == menuItemId);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(quantity: quantity);
      state = updated;
    }
  }

  void clear() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
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
