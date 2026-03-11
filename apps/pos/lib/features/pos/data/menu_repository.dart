import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/pos_local_cache.dart';
import '../models/category.dart';
import '../models/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(
    ref.watch(dioProvider),
    ref.watch(posLocalCacheProvider),
  );
});

class MenuRepository {
  final Dio _dio;
  final PosLocalCache _cache;

  MenuRepository(this._dio, this._cache);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/menu/categories');
      final list = response.data['data'] as List? ?? response.data as List;
      final categories = list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cache.saveCategories(categories);
      return categories;
    } catch (_) {
      final cached = await _cache.loadCategories();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<MenuItem>> getItems() async {
    try {
      final response = await _dio.get('/menu/items');
      final list = response.data['data'] as List? ?? response.data as List;
      final items = list
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cache.saveMenuItems(items);
      return items;
    } catch (_) {
      final cached = await _cache.loadMenuItems();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }
}
