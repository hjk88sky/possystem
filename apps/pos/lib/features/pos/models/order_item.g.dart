// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: parseStringId(json['id']),
      itemId: parseNullableStringId(_readOrderItemId(json, 'itemId')),
      itemName: _readOrderItemName(json, 'itemName') as String,
      quantity: (_readOrderItemQuantity(json, 'quantity') as num).toInt(),
      unitPrice: parseMoneyToInt(_readOrderItemUnitPrice(json, 'unitPrice')),
      totalPrice: parseMoneyToInt(_readOrderItemTotalPrice(json, 'totalPrice')),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
    };
