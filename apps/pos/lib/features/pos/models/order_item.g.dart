// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: (json['id'] as num).toInt(),
      itemId: (json['item_id'] as num).toInt(),
      itemName: json['item_name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toInt(),
      totalPrice: (json['total_price'] as num).toInt(),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'item_name': instance.itemName,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_price': instance.totalPrice,
    };
