import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(dioProvider));
});

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  Future<Order> createOrder(List<CartItem> cartItems) async {
    final response = await _dio.post('/orders', data: {
      'channel': 'POS',
      'items': cartItems
          .map((e) => {
                'itemId': e.menuItem.id,
                'qty': e.quantity,
              })
          .toList(),
    });
    final data = response.data['data'] ?? response.data;
    return Order.fromJson(data);
  }

  Future<Order> getOrder(int orderId) async {
    final response = await _dio.get('/orders/$orderId');
    final data = response.data['data'] ?? response.data;
    return Order.fromJson(data);
  }
}
