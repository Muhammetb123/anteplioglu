import 'package:dio/dio.dart';

import 'package:core/core.dart';
import '../models/category.dart';

class WarehouseRepository {
  final ApiService api;

  WarehouseRepository({required this.api});

  Future<List<Category>> getCategoriesWithProducts() async {
    try {
      final res = await api.get('categories/with-products');
      final data = res.data;
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
