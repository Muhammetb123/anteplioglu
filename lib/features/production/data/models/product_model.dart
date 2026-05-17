import '../../../../core/models/localized_name.dart';
import 'stock_movement_model.dart';

class ProductModel {
  final String id;
  final LocalizedName name;
  final String unit;
  final num criticalStock;
  final String categoryId;
  final LocalizedName categoryName;
  final String branchId;
  final num quantity;
  final bool isActive;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<StockMovementModel> recentMovements;

  const ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.criticalStock,
    required this.categoryId,
    required this.categoryName,
    required this.branchId,
    required this.quantity,
    required this.isActive,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.recentMovements = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawMovements = json['recentMovements'];
    final movements = rawMovements is List
        ? rawMovements
              .whereType<Map>()
              .map((e) =>
                  StockMovementModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <StockMovementModel>[];
    return ProductModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: LocalizedName.fromJson(json['name']),
      unit: (json['unit'] ?? '').toString(),
      criticalStock: (json['criticalStock'] as num?) ?? 0,
      categoryId: (json['categoryId'] ?? '').toString(),
      categoryName: LocalizedName.fromJson(json['categoryName']),
      branchId: (json['branchId'] ?? '').toString(),
      quantity: (json['quantity'] as num?) ?? 0,
      isActive: (json['isActive'] ?? true) == true,
      imageUrl: json['imageUrl']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
      recentMovements: movements,
    );
  }

  ProductStockLevel get stockLevel {
    if (quantity > criticalStock * 1.5) return ProductStockLevel.safe;
    if (quantity <= criticalStock) return ProductStockLevel.critical;
    return ProductStockLevel.warning;
  }
}

enum ProductStockLevel { safe, warning, critical }

class ProductsPageModel {
  final List<ProductModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProductsPageModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  static const empty = ProductsPageModel(
    items: [],
    total: 0,
    page: 1,
    limit: 10,
    totalPages: 1,
  );

  factory ProductsPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <ProductModel>[];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};
    return ProductsPageModel(
      items: items,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 10,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
