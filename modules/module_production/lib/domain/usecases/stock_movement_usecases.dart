import '../../data/models/stock_movement_model.dart' show StockMovementType;
import '../entities/stock_movement_entity.dart';
import '../repositories/i_product_repository.dart';

class GetStockMovementsUseCase {
  final IProductRepository repository;
  GetStockMovementsUseCase(this.repository);

  Future<StockMovementsPageEntity> call(
    String productId, {
    int page = 1,
    int limit = 20,
    StockMovementType? type,
  }) {
    return repository.getStockMovements(
      productId,
      page: page,
      limit: limit,
      type: type,
    );
  }
}

class AddStockMovementUseCase {
  final IProductRepository repository;
  AddStockMovementUseCase(this.repository);

  Future<StockMovementEntity> call(
    String productId, {
    required StockMovementType type,
    required num quantity,
    String? orderId,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  }) {
    return repository.addStockMovement(
      productId,
      type: type,
      quantity: quantity,
      orderId: orderId,
      sourceFirm: sourceFirm,
      branchId: branchId,
      note: note,
      docPaths: docPaths,
    );
  }
}

class UpdateStockMovementUseCase {
  final IProductRepository repository;
  UpdateStockMovementUseCase(this.repository);

  Future<StockMovementEntity> call(
    String productId,
    String movementId, {
    num? quantity,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  }) {
    return repository.updateStockMovement(
      productId,
      movementId,
      quantity: quantity,
      sourceFirm: sourceFirm,
      branchId: branchId,
      note: note,
      docPaths: docPaths,
    );
  }
}

class DeleteStockMovementUseCase {
  final IProductRepository repository;
  DeleteStockMovementUseCase(this.repository);

  Future<void> call(String productId, String movementId) {
    return repository.deleteStockMovement(productId, movementId);
  }
}
