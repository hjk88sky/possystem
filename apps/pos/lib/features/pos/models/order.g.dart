// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      id: (json['id'] as num).toInt(),
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      channel: json['channel'] as String,
      totalAmount: (json['total_amount'] as num).toInt(),
      taxAmount: (json['tax_amount'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      priority:
          $enumDecodeNullable(_$OrderPriorityEnumMap, json['priority']) ??
              OrderPriority.normal,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'channel': instance.channel,
      'total_amount': instance.totalAmount,
      'tax_amount': instance.taxAmount,
      'items': instance.items,
      'priority': _$OrderPriorityEnumMap[instance.priority]!,
      'created_at': instance.createdAt,
    };

const _$OrderPriorityEnumMap = {
  OrderPriority.urgent: 'URGENT',
  OrderPriority.high: 'HIGH',
  OrderPriority.normal: 'NORMAL',
  OrderPriority.low: 'LOW',
};
