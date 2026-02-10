import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/payment.dart';
import '../models/payment_request.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(dioProvider));
});

class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio);

  Future<Payment> processPayment(
      int orderId, PaymentRequest request) async {
    final response = await _dio.post(
      '/orders/$orderId/payments',
      data: request.toJson(),
    );
    final data = response.data['data'] ?? response.data;
    return Payment.fromJson(data);
  }
}
