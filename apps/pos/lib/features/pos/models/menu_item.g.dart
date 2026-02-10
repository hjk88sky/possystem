// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemImpl _$$MenuItemImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      available: json['available'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'category_id': instance.categoryId,
      'image_url': instance.imageUrl,
      'available': instance.available,
      'sort_order': instance.sortOrder,
    };
