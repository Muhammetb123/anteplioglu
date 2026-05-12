import 'package:dio/dio.dart';

import '../../../core/api_service.dart';
import '../../../core/network/api_error.dart';
import '../models/production_order.dart';

class ProductionRepository {
  final ApiService api;

  ProductionRepository({required this.api});

  Future<ProductionOrdersPage> getIncomingOrders({
    int page = 1,
    int limit = 10,
    ProductionOrderStatus? status,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null &&
          status != ProductionOrderStatus.unknown &&
          status.apiValue.isNotEmpty) {
        query['status'] = status.apiValue;
      }

      final res = await api.get(
        'orders/incoming',
        queryParameters: query,
      );
      final body = res.data;
      if (body is! Map) {
        return ProductionOrdersPage.empty;
      }

      final map = Map<String, dynamic>.from(body);
      final rawItems = map['items'];
      final rawMeta = map['meta'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (e) =>
                      ProductionOrder.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <ProductionOrder>[];
      final meta = rawMeta is Map
          ? Map<String, dynamic>.from(rawMeta)
          : <String, dynamic>{};

      return ProductionOrdersPage(
        items: items,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
        page: (meta['page'] as num?)?.toInt() ?? page,
        limit: (meta['limit'] as num?)?.toInt() ?? limit,
        totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      );
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
