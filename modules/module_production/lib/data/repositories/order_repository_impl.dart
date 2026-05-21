import 'package:dio/dio.dart';

import 'package:core/network/api_service.dart';
import 'package:core/network/api_error.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final ApiService api;

  OrderRepositoryImpl({required this.api});

  @override
  Future<OrdersPageModel> getIncomingOrders({
    int page = 1,
    int limit = 10,
    OrderStatus? status,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.apiValue.isNotEmpty) {
        query['status'] = status.apiValue;
      }
      final res = await api.get('orders/incoming', queryParameters: query);
      return OrdersPageModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<OrdersPageModel> getPlacedOrders({
    int page = 1,
    int limit = 10,
    OrderStatus? status,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.apiValue.isNotEmpty) {
        query['status'] = status.apiValue;
      }
      final res = await api.get('orders/placed', queryParameters: query);
      return OrdersPageModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<OrdersByProductModel> getOrdersByProduct({String? categoryId}) async {
    try {
      final query = <String, dynamic>{};
      if (categoryId != null && categoryId.isNotEmpty) {
        query['categoryId'] = categoryId;
      }
      final res = await api.get('orders/by-products',
          queryParameters: query.isEmpty ? null : query);
      return OrdersByProductModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<Map<String, String>> getBranchNames() async {
    try {
      final res = await api.get('admin/branches');
      final data = res.data;
      if (data is! List) return {};
      return {
        for (final e in data.whereType<Map>())
          (e['_id'] ?? e['id'] ?? '').toString():
              (e['name'] ?? '').toString(),
      };
    } on DioException catch (_) {
      return {};
    }
  }

  @override
  Future<Map<String, String>> getCategoryNames() async {
    try {
      final res = await api.get('categories');
      final data = res.data;
      if (data is! List) return {};
      return {
        for (final e in data.whereType<Map>()) ..._parseCategory(e),
      };
    } on DioException catch (_) {
      return {};
    }
  }

  static Map<String, String> _parseCategory(Map<dynamic, dynamic> e) {
    final id = (e['_id'] ?? e['id'] ?? '').toString();
    if (id.isEmpty) return {};
    final nameRaw = e['name'];
    final String name;
    if (nameRaw is Map) {
      name = (nameRaw['tr'] ?? nameRaw['en'] ?? id).toString();
    } else {
      name = (nameRaw ?? id).toString();
    }
    return {id: name};
  }

  @override
  Future<OrderByProductDetailModel> getOrdersByProductDetail(
      String productId) async {
    try {
      final res = await api.get('orders/by-products/$productId');
      return OrderByProductDetailModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final res = await api.get('orders/$id');
      return OrderModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<OrderModel> acceptOrder(
    String id, {
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final res = await api.post('orders/$id/accept', data: {'items': items});
      return OrderModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<OrderModel> completeOrder(String id) async {
    try {
      final res = await api.post('orders/$id/complete');
      return OrderModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<OrderModel> cancelOrder(String id) async {
    try {
      final res = await api.post('orders/$id/cancel');
      return OrderModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
