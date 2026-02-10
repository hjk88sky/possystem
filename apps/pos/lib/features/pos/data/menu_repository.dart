import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/category.dart';
import '../models/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(ref.watch(dioProvider));
});

class MenuRepository {
  final Dio _dio;

  MenuRepository(this._dio);

  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/menu/categories');
    final list = response.data['data'] as List? ?? response.data as List;
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MenuItem>> getItems() async {
    final response = await _dio.get('/menu/items');
    final list = response.data['data'] as List? ?? response.data as List;
    return list.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
