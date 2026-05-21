import 'package:core/models/localized_name.dart';

class CategoryEntity {
  final String id;
  final LocalizedName name;
  final String? branchId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.branchId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
