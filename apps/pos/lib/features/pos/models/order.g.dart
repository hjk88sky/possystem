// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      id: parseStringId(json['id']),
      orderNumber: json['orderNo'] as String,
      status: json['status'] as String,
      channel: json['channel'] as String,
      totalAmount: parseMoneyToInt(json['total']),
      taxAmount: json['tax'] == null ? 0 : parseMoneyToInt(json['tax']),
      items: json['orderItems'] == null
          ? const []
          : _orderItemsFromJson(json['orderItems'] as List?),
      priority: $enumDecodeNullable(_$OrderPriorityEnumMap, json['priority']) ??
          OrderPriority.normal,
      createdAt: parseNullableString(json['createdAt']),
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNo': instance.orderNumber,
      'status': instance.status,
      'channel': instance.channel,
      'total': instance.totalAmount,
      'tax': instance.taxAmount,
      'orderItems': _orderItemsToJson(instance.items),
      'priority': _$OrderPriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt,
    };

const _$OrderPriorityEnumMap = {
  OrderPriority.urgent: 'URGENT',
  OrderPriority.high: 'HIGH',
  OrderPriority.normal: 'NORMAL',
  OrderPriority.low: 'LOW',
};
