import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item.freezed.dart';
part 'menu_item.g.dart';

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    required int id,
    required String name,
    required int price,
    @JsonKey(name: 'category_id') required int categoryId,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default(true) bool available,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}
