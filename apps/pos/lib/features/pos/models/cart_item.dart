import 'package:freezed_annotation/freezed_annotation.dart';
import 'menu_item.dart';

part 'cart_item.freezed.dart';

@freezed
class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required MenuItem menuItem,
    @Default(1) int quantity,
  }) = _CartItem;

  int get subtotal => menuItem.price * quantity;
}
