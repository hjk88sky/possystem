// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: parseStringId(json['id']),
      orderId: parseStringId(json['orderId']),
      method: json['method'] as String,
      amount: parseMoneyToInt(json['amount']),
      status: json['status'] as String,
      createdAt: parseNullableString(json['createdAt']),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'method': instance.method,
      'amount': instance.amount,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };
