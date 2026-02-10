import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    @JsonKey(name: 'order_number') required String orderNumber,
    required String status,
    required String channel,
    @JsonKey(name: 'total_amount') required int totalAmount,
    @JsonKey(name: 'tax_amount') @Default(0) int taxAmount,
    @Default([]) List<OrderItem> items,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
