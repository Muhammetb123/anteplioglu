import '../../../core/models/localized_name.dart';

class Product {
  final String id;
  final LocalizedName name;
  final num quantity;
  final num criticalStock;
  final String unit;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.criticalStock,
    required this.unit,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: LocalizedName.fromJson(json['name']),
      quantity: (json['quantity'] as num?) ?? 0,
      criticalStock: (json['criticalStock'] as num?) ?? 0,
      unit: (json['unit'] ?? '').toString(),
      isActive: (json['isActive'] ?? true) == true,
    );
  }

  /// Stock level relative to critical threshold.
  /// - safe: quantity >= 2 * criticalStock (yeşil)
  /// - warning: criticalStock <= quantity < 2 * criticalStock (sarı)
  /// - critical: quantity < criticalStock (kırmızı)
  ProductStockLevel get stockLevel {
    if (criticalStock <= 0) {
      return ProductStockLevel.safe;
    }
    if (quantity < criticalStock) {
      return ProductStockLevel.critical;
    }
    if (quantity < criticalStock * 2) {
      return ProductStockLevel.warning;
    }
    return ProductStockLevel.safe;
  }
}

enum ProductStockLevel { safe, warning, critical }
