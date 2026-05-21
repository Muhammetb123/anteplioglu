import 'package:core/core.dart';
import 'product.dart';

class Category {
  final String id;
  final LocalizedName name;
  final String branchId;
  final String code;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Product> products;

  const Category({
    required this.id,
    required this.name,
    required this.branchId,
    required this.code,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
  });

  Category copyWith({
    bool? isActive,
    List<Product>? products,
    LocalizedName? name,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      branchId: branchId,
      code: code,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      products: products ?? this.products,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final products = rawProducts is List
        ? rawProducts
              .whereType<Map>()
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <Product>[];
    return Category(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: LocalizedName.fromJson(json['name']),
      branchId: (json['branchId'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      isActive: (json['isActive'] ?? true) == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
      products: products,
    );
  }
}
