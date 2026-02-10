// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentRequestImpl _$$PaymentRequestImplFromJson(Map<String, dynamic> json) =>
    _$PaymentRequestImpl(
      method: json['method'] as String,
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$$PaymentRequestImplToJson(
        _$PaymentRequestImpl instance) =>
    <String, dynamic>{
      'method': instance.method,
      'amount': instance.amount,
    };
