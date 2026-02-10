import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/menu_repository.dart';
import '../models/category.dart';
import '../models/menu_item.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getCategories();
});

final menuItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getItems();
});

final selectedCategoryProvider = StateProvider<int?>((ref) => null);

final filteredMenuItemsProvider = Provider<AsyncValue<List<MenuItem>>>((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  final itemsAsync = ref.watch(menuItemsProvider);

  return itemsAsync.whenData((items) {
    if (categoryId == null) return items;
    return items.where((item) => item.categoryId == categoryId).toList();
  });
});
