// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: (json['id'] as num).toInt(),
      orderId: (json['order_id'] as num).toInt(),
      method: json['method'] as String,
      amount: (json['amount'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'method': instance.method,
      'amount': instance.amount,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
