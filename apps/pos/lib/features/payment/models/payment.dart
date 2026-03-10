import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/json_parsers.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    @JsonKey(fromJson: parseStringId) required String id,
    @JsonKey(name: 'orderId', fromJson: parseStringId) required String orderId,
    required String method,
    @JsonKey(fromJson: parseMoneyToInt) required int amount,
    required String status,
    @JsonKey(name: 'createdAt', fromJson: parseNullableString) String? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
