import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required int id,
    @JsonKey(name: 'item_id') required int itemId,
    @JsonKey(name: 'item_name') required String itemName,
    required int quantity,
    @JsonKey(name: 'unit_price') required int unitPrice,
    @JsonKey(name: 'total_price') required int totalPrice,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
