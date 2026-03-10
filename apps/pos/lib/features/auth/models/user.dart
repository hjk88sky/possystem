import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/json_parsers.dart';

part 'user.freezed.dart';
part 'user.g.dart';

Object? _readStoreId(Map json, String _) {
  return json['storeId'] ?? json['store_id'] ?? (json['store'] as Map?)?['id'];
}

Object? _readStoreName(Map json, String _) {
  return json['storeName'] ?? (json['store'] as Map?)?['name'];
}

@freezed
class User with _$User {
  const factory User({
    @JsonKey(fromJson: parseStringId) required String id,
    required String name,
    @Default('STAFF') String role,
    @JsonKey(readValue: _readStoreId, fromJson: parseStringId)
    required String storeId,
    @JsonKey(readValue: _readStoreName) String? storeName,
    String? phone,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
