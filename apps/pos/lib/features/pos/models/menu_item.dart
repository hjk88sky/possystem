import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/json_parsers.dart';

part 'menu_item.freezed.dart';
part 'menu_item.g.dart';

Object? _readAvailable(Map json, String _) {
  return (json['isActive'] as bool? ?? true) &&
      !(json['isSoldOut'] as bool? ?? false);
}

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    @JsonKey(fromJson: parseStringId) required String id,
    required String name,
    @JsonKey(fromJson: parseMoneyToInt) required int price,
    @JsonKey(
      name: 'categoryId',
      fromJson: parseNullableStringId,
    )
    String? categoryId,
    @JsonKey(name: 'imageUrl') String? imageUrl,
    @JsonKey(readValue: _readAvailable) @Default(true) bool available,
    @JsonKey(name: 'sortOrder') @Default(0) int sortOrder,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}
