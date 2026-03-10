import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/json_parsers.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

Object? _readOrderItemId(Map json, String _) {
  return json['itemId'] ?? json['item_id'];
}

Object? _readOrderItemName(Map json, String _) {
  return json['item_name'] ?? json['nameSnapshot'];
}

Object? _readOrderItemQuantity(Map json, String _) {
  return json['quantity'] ?? json['qty'];
}

Object? _readOrderItemUnitPrice(Map json, String _) {
  return json['unit_price'] ?? json['unitPrice'];
}

Object? _readOrderItemTotalPrice(Map json, String _) {
  return json['total_price'] ?? json['totalPrice'];
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    @JsonKey(fromJson: parseStringId) required String id,
    @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
    String? itemId,
    @JsonKey(readValue: _readOrderItemName) required String itemName,
    @JsonKey(readValue: _readOrderItemQuantity) required int quantity,
    @JsonKey(
      readValue: _readOrderItemUnitPrice,
      fromJson: parseMoneyToInt,
    )
    required int unitPrice,
    @JsonKey(
      readValue: _readOrderItemTotalPrice,
      fromJson: parseMoneyToInt,
    )
    required int totalPrice,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
