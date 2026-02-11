import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_repository.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

enum OrderStatus { idle, loading, success, error }

class OrderState {
  final OrderStatus status;
  final Order? order;
  final List<Order> orders;
  final String? error;

  const OrderState({
    this.status = OrderStatus.idle,
    this.order,
    this.orders = const [],
    this.error,
  });

  OrderState copyWith({
    OrderStatus? status,
    Order? order,
    List<Order>? orders,
    String? error,
  }) {
    return OrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      orders: orders ?? this.orders,
      error: error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(const OrderState());

  Future<Order?> createOrder(
    List<CartItem> cartItems, {
    OrderPriority priority = OrderPriority.normal,
  }) async {
    state = state.copyWith(status: OrderStatus.loading, error: null);
    try {
      final order = await _repository.createOrder(
        cartItems,
        priority: priority,
      );
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

  Future<void> fetchOrders({OrderPriority? priority, String? status}) async {
    state = state.copyWith(status: OrderStatus.loading, error: null);
    try {
      final orders = await _repository.getOrders(
        priority: priority,
        status: status,
      );
      state = state.copyWith(status: OrderStatus.success, orders: orders);
    } catch (e) {
      state = state.copyWith(
        status: OrderStatus.error,
        error: '주문 목록을 불러오지 못했습니다.',
      );
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
