import '../../../../core/models/localized_name.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final LocalizedName name;
  final String? branchId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.branchId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: LocalizedName.fromJson(json['name']),
      branchId: json['branchId']?.toString(),
      isActive: (json['isActive'] ?? true) == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      branchId: branchId,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
