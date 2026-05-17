import '../../data/models/stock_movement_model.dart' show StockMovementType;
import '../../domain/entities/stock_movement_entity.dart';

/// Состояния для управления движениями склада.
/// Вынесены из [ProductState] согласно SRP.
abstract class StockMovementState {
  const StockMovementState();
}

class StockMovementInitial extends StockMovementState {
  const StockMovementInitial();
}

class StockMovementLoading extends StockMovementState {
  const StockMovementLoading();
}

class StockMovementsLoaded extends StockMovementState {
  final String productId;
  final List<StockMovementEntity> items;
  final int currentPage;
  final int totalPages;
  final StockMovementType? activeFilter;

  const StockMovementsLoaded({
    required this.productId,
    required this.items,
    required this.currentPage,
    required this.totalPages,
    this.activeFilter,
  });
}

class StockMovementActionSuccess extends StockMovementState {
  final String message;

  const StockMovementActionSuccess(this.message);
}

class StockMovementError extends StockMovementState {
  final String message;

  const StockMovementError(this.message);
}
