import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required int id,
    @JsonKey(name: 'order_id') required int orderId,
    required String method,
    required int amount,
    required String status,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
