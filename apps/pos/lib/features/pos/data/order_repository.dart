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

  Future<Order> createOrder(
    List<CartItem> cartItems, {
    OrderPriority priority = OrderPriority.normal,
  }) async {
    final response = await _dio.post('/orders', data: {
      'channel': 'POS',
      'priority': priority.apiValue,
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

  Future<List<Order>> getOrders({
    OrderPriority? priority,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (priority != null) queryParams['priority'] = priority.apiValue;
    if (status != null) queryParams['status'] = status;

    final response = await _dio.get('/orders', queryParameters: queryParams);
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
