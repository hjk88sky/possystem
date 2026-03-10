// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  @JsonKey(fromJson: parseStringId)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
  String? get itemId => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readOrderItemName)
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readOrderItemQuantity)
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readOrderItemUnitPrice, fromJson: parseMoneyToInt)
  int get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readOrderItemTotalPrice, fromJson: parseMoneyToInt)
  int get totalPrice => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: parseStringId) String id,
      @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
      String? itemId,
      @JsonKey(readValue: _readOrderItemName) String itemName,
      @JsonKey(readValue: _readOrderItemQuantity) int quantity,
      @JsonKey(readValue: _readOrderItemUnitPrice, fromJson: parseMoneyToInt)
      int unitPrice,
      @JsonKey(readValue: _readOrderItemTotalPrice, fromJson: parseMoneyToInt)
      int totalPrice});
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = freezed,
    Object? itemName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: freezed == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
          _$OrderItemImpl value, $Res Function(_$OrderItemImpl) then) =
      __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: parseStringId) String id,
      @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
      String? itemId,
      @JsonKey(readValue: _readOrderItemName) String itemName,
      @JsonKey(readValue: _readOrderItemQuantity) int quantity,
      @JsonKey(readValue: _readOrderItemUnitPrice, fromJson: parseMoneyToInt)
      int unitPrice,
      @JsonKey(readValue: _readOrderItemTotalPrice, fromJson: parseMoneyToInt)
      int totalPrice});
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
      _$OrderItemImpl _value, $Res Function(_$OrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = freezed,
    Object? itemName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
  }) {
    return _then(_$OrderItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: freezed == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl implements _OrderItem {
  const _$OrderItemImpl(
      {@JsonKey(fromJson: parseStringId) required this.id,
      @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
      this.itemId,
      @JsonKey(readValue: _readOrderItemName) required this.itemName,
      @JsonKey(readValue: _readOrderItemQuantity) required this.quantity,
      @JsonKey(readValue: _readOrderItemUnitPrice, fromJson: parseMoneyToInt)
      required this.unitPrice,
      @JsonKey(readValue: _readOrderItemTotalPrice, fromJson: parseMoneyToInt)
      required this.totalPrice});

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  @JsonKey(fromJson: parseStringId)
  final String id;
  @override
  @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
  final String? itemId;
  @override
  @JsonKey(readValue: _readOrderItemName)
  final String itemName;
  @override
  @JsonKey(readValue: _readOrderItemQuantity)
  final int quantity;
  @override
  @JsonKey(readValue: _readOrderItemUnitPrice, fromJson: parseMoneyToInt)
  final int unitPrice;
  @override
  @JsonKey(readValue: _readOrderItemTotalPrice, fromJson: parseMoneyToInt)
  final int totalPrice;

  @override
  String toString() {
    return 'OrderItem(id: $id, itemId: $itemId, itemName: $itemName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, itemId, itemName, quantity, unitPrice, totalPrice);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(
      this,
    );
  }
}

abstract class _OrderItem implements OrderItem {
  const factory _OrderItem(
      {@JsonKey(fromJson: parseStringId) required final String id,
      @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
      final String? itemId,
      @JsonKey(readValue: _readOrderItemName) required final String itemName,
      @JsonKey(readValue: _readOrderItemQuantity) required final int quantity,
      @JsonKey(readValue: _readOrderItemUnitPrice, fromJson: parseMoneyToInt)
      required final int unitPrice,
      @JsonKey(readValue: _readOrderItemTotalPrice, fromJson: parseMoneyToInt)
      required final int totalPrice}) = _$OrderItemImpl;

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  @JsonKey(fromJson: parseStringId)
  String get id;
  @override
  @JsonKey(readValue: _readOrderItemId, fromJson: parseNullableStringId)
  String? get itemId;
  @override
  @JsonKey(readValue: _readOrderItemName)
  String get itemName;
  @override
  @JsonKey(readValue: _readOrderItemQuantity)
  int get quantity;
  @override
  @JsonKey(readValue: _readOrderItemUnitPrice, fromJson: parseMoneyToInt)
  int get unitPrice;
  @override
  @JsonKey(readValue: _readOrderItemTotalPrice, fromJson: parseMoneyToInt)
  int get totalPrice;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
