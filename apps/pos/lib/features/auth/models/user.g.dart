// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: parseStringId(json['id']),
      name: json['name'] as String,
      role: json['role'] as String? ?? 'STAFF',
      storeId: parseStringId(_readStoreId(json, 'storeId')),
      storeName: _readStoreName(json, 'storeName') as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'phone': instance.phone,
    };
