import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos/core/storage/pos_local_cache.dart';
import 'package:pos/features/pos/models/cart_item.dart';
import 'package:pos/features/pos/models/category.dart';
import 'package:pos/features/pos/models/menu_item.dart';
import 'package:pos/features/pos/models/order.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cache = PosLocalCache();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('stores and restores cached menu catalog', () async {
    const categories = <Category>[
      Category(id: 'cat-1', name: 'Coffee', sortOrder: 1),
    ];
    const items = <MenuItem>[
      MenuItem(
        id: 'item-1',
        name: 'Americano',
        price: 3000,
        categoryId: 'cat-1',
        available: true,
        sortOrder: 1,
      ),
    ];

    await cache.saveCategories(categories);
    await cache.saveMenuItems(items);

    expect(await cache.loadCategories(), categories);
    expect(await cache.loadMenuItems(), items);
  });

  test('stores and restores cart draft', () async {
    const menuItem = MenuItem(
      id: 'item-1',
      name: 'Latte',
      price: 4500,
      categoryId: 'cat-1',
      available: true,
      sortOrder: 2,
    );
    const cartItems = <CartItem>[
      CartItem(menuItem: menuItem, quantity: 2),
    ];

    await cache.saveCartItems(cartItems);
    await cache.saveCartPriority(OrderPriority.urgent);

    expect(await cache.loadCartItems(), cartItems);
    expect(await cache.loadCartPriority(), OrderPriority.urgent);

    await cache.clearCartDraft();

    expect(await cache.loadCartItems(), isEmpty);
    expect(await cache.loadCartPriority(), OrderPriority.normal);
  });
}
