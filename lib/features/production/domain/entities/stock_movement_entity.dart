import '../../data/models/stock_movement_model.dart' show StockMovementType;

class MovementBranchRefEntity {
  final String id;
  final String name;
  final String code;
  final String type;

  const MovementBranchRefEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });
}

class StockMovementEntity {
  final String id;
  final String productId;
  final StockMovementType type;
  final num quantity;
  final String? orderId;
  final String? sourceFirm;
  final String? branchId;
  final String? branchName;
  final MovementBranchRefEntity? to;
  final List<String> docUrls;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StockMovementEntity({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.orderId,
    required this.sourceFirm,
    required this.branchId,
    required this.branchName,
    required this.to,
    required this.docUrls,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}

class StockMovementsPageEntity {
  final List<StockMovementEntity> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const StockMovementsPageEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
