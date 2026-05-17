import 'package:dio/dio.dart';

import '../../../../core/api_service.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/stock_movement_model.dart';

class ProductRepositoryImpl implements IProductRepository {
  final ApiService api;

  ProductRepositoryImpl({required this.api});

  @override
  Future<ProductsPageModel> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? categoryId,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (isActive != null) query['isActive'] = isActive;
      if (categoryId != null && categoryId.isNotEmpty) {
        query['category'] = categoryId;
      }
      final res = await api.get('products', queryParameters: query);
      return ProductsPageModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final res = await api.get('products/$id');
      return ProductModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<ProductModel> createProduct({
    required Map<String, String> name,
    required String unit,
    required num criticalStock,
    required String categoryId,
    required num quantity,
    bool isActive = true,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name.toString(),
        'unit': unit,
        'criticalStock': criticalStock,
        'categoryId': categoryId,
        'quantity': quantity,
        'isActive': isActive,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });
      final res = await api.post(
        'products',
        data: formData,
        headers: {'Content-Type': 'multipart/form-data'},
      );
      return ProductModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<ProductModel> updateProduct(
    String id, {
    Map<String, String>? name,
    String? unit,
    num? criticalStock,
    String? categoryId,
    bool? isActive,
    String? imagePath,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (name != null) fields['name'] = name.toString();
      if (unit != null) fields['unit'] = unit;
      if (criticalStock != null) fields['criticalStock'] = criticalStock;
      if (categoryId != null) fields['categoryId'] = categoryId;
      if (isActive != null) fields['isActive'] = isActive;
      if (imagePath != null) {
        fields['image'] = await MultipartFile.fromFile(imagePath);
      }
      final formData = FormData.fromMap(fields);
      final res = await api.patch(
        'products/$id',
        formData,
        headers: {'Content-Type': 'multipart/form-data'},
      );
      return ProductModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await api.delete('products/$id');
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await api.get('categories');
      final raw = res.data;
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<StockMovementsPageModel> getStockMovements(
    String productId, {
    int page = 1,
    int limit = 20,
    StockMovementType? type,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (type != null) query['type'] = type.apiValue;
      final res =
          await api.get('stock/$productId', queryParameters: query);
      return StockMovementsPageModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<StockMovementModel> addStockMovement(
    String productId, {
    required StockMovementType type,
    required num quantity,
    String? orderId,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  }) async {
    try {
      final fields = <String, dynamic>{
        'type': type.apiValue,
        'quantity': quantity,
        'orderId': ?orderId,
        'sourceFirm': ?sourceFirm,
        'branchId': ?branchId,
        'note': ?note,
      };
      if (docPaths != null && docPaths.isNotEmpty) {
        fields['docs'] = await Future.wait(
          docPaths.map((p) => MultipartFile.fromFile(p)),
        );
      }
      final formData = FormData.fromMap(fields);
      final res = await api.post(
        'stock/$productId',
        data: formData,
        headers: {'Content-Type': 'multipart/form-data'},
      );
      return StockMovementModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<StockMovementModel> updateStockMovement(
    String productId,
    String movementId, {
    num? quantity,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  }) async {
    try {
      final fields = <String, dynamic>{
        'quantity': ?quantity,
        'sourceFirm': ?sourceFirm,
        'branchId': ?branchId,
        'note': ?note,
      };
      if (docPaths != null && docPaths.isNotEmpty) {
        fields['docs'] = await Future.wait(
          docPaths.map((p) => MultipartFile.fromFile(p)),
        );
      }
      final formData = FormData.fromMap(fields);
      final res = await api.patch(
        'stock/$productId/$movementId',
        formData,
        headers: {'Content-Type': 'multipart/form-data'},
      );
      return StockMovementModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<void> deleteStockMovement(
      String productId, String movementId) async {
    try {
      await api.delete('stock/$productId/$movementId');
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
