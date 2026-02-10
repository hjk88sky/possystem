import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/payment_repository.dart';
import '../models/payment.dart';
import '../models/payment_request.dart';

enum PaymentStatus { idle, loading, success, error }

class PaymentState {
  final PaymentStatus status;
  final Payment? payment;
  final String? error;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.payment,
    this.error,
  });

  PaymentState copyWith(
      {PaymentStatus? status, Payment? payment, String? error}) {
    return PaymentState(
      status: status ?? this.status,
      payment: payment ?? this.payment,
      error: error,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  PaymentNotifier(this._repository) : super(const PaymentState());

  Future<Payment?> processPayment(
      int orderId, PaymentRequest request) async {
    state = state.copyWith(status: PaymentStatus.loading, error: null);
    try {
      final payment = await _repository.processPayment(orderId, request);
      state = state.copyWith(status: PaymentStatus.success, payment: payment);
      return payment;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: '결제 처리에 실패했습니다.',
      );
      return null;
    }
  }

  void reset() {
    state = const PaymentState();
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository);
});
