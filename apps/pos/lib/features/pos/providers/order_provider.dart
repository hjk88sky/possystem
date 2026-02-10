import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_repository.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

enum OrderStatus { idle, loading, success, error }

class OrderState {
  final OrderStatus status;
  final Order? order;
  final String? error;

  const OrderState({
    this.status = OrderStatus.idle,
    this.order,
    this.error,
  });

  OrderState copyWith({OrderStatus? status, Order? order, String? error}) {
    return OrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      error: error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(const OrderState());

  Future<Order?> createOrder(List<CartItem> cartItems) async {
    state = state.copyWith(status: OrderStatus.loading, error: null);
    try {
      final order = await _repository.createOrder(cartItems);
      state = state.copyWith(status: OrderStatus.success, order: order);
      return order;
    } catch (e) {
      state = state.copyWith(
        status: OrderStatus.error,
        error: '주문 생성에 실패했습니다.',
      );
      return null;
    }
  }

  void reset() {
    state = const OrderState();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});
