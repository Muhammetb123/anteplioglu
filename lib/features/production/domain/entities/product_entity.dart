import '../../../../core/models/localized_name.dart';
import 'stock_movement_entity.dart';

enum ProductStockLevel { safe, warning, critical }

class ProductEntity {
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
  final List<StockMovementEntity> recentMovements;

  const ProductEntity({
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

  ProductStockLevel get stockLevel {
    if (quantity > criticalStock * 1.5) return ProductStockLevel.safe;
    if (quantity <= criticalStock) return ProductStockLevel.critical;
    return ProductStockLevel.warning;
  }
}

class ProductsPageEntity {
  final List<ProductEntity> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProductsPageEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
