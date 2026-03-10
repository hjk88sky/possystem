// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemImpl _$$MenuItemImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemImpl(
      id: parseStringId(json['id']),
      name: json['name'] as String,
      price: parseMoneyToInt(json['price']),
      categoryId: parseNullableStringId(json['categoryId']),
      imageUrl: json['imageUrl'] as String?,
      available: _readAvailable(json, 'available') as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'categoryId': instance.categoryId,
      'imageUrl': instance.imageUrl,
      'available': instance.available,
      'sortOrder': instance.sortOrder,
    };
