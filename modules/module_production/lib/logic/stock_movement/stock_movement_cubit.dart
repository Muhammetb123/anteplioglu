import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/network/api_error.dart';
import '../../data/models/stock_movement_model.dart';
import '../../domain/usecases/stock_movement_usecases.dart';
import 'stock_movement_state.dart';

/// Cubit отвечает исключительно за движения склада (SRP).
/// CRUD продуктов — в [ProductCubit].
class StockMovementCubit extends Cubit<StockMovementState> {
  final GetStockMovementsUseCase _getStockMovements;
  final AddStockMovementUseCase _addStockMovement;
  final UpdateStockMovementUseCase _updateStockMovement;
  final DeleteStockMovementUseCase _deleteStockMovement;

  StockMovementCubit({
    required GetStockMovementsUseCase getStockMovements,
    required AddStockMovementUseCase addStockMovement,
    required UpdateStockMovementUseCase updateStockMovement,
    required DeleteStockMovementUseCase deleteStockMovement,
  })  : _getStockMovements = getStockMovements,
        _addStockMovement = addStockMovement,
        _updateStockMovement = updateStockMovement,
        _deleteStockMovement = deleteStockMovement,
        super(const StockMovementInitial());

  @override
  void emit(StockMovementState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> loadStockMovements(
    String productId, {
    int page = 1,
    int limit = 20,
    StockMovementType? type,
  }) async {
    emit(const StockMovementLoading());
    try {
      final result = await _getStockMovements(
        productId,
        page: page,
        limit: limit,
        type: type,
      );
      emit(StockMovementsLoaded(
        productId: productId,
        items: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        activeFilter: type,
      ));
    } on ApiError catch (e) {
      emit(StockMovementError(e.message));
    } catch (_) {
      emit(const StockMovementError('Hareketler yüklenemedi'));
    }
  }

  Future<void> addStockMovement(
    String productId, {
    required StockMovementType type,
    required num quantity,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  }) async {
    emit(const StockMovementLoading());
    try {
      await _addStockMovement(
        productId,
        type: type,
        quantity: quantity,
        sourceFirm: sourceFirm,
        branchId: branchId,
        note: note,
        docPaths: docPaths,
      );
      emit(const StockMovementActionSuccess('Hareket kaydedildi'));
    } on ApiError catch (e) {
      emit(StockMovementError(e.message));
    } catch (_) {
      emit(const StockMovementError('Hareket kaydedilemedi'));
    }
  }

  Future<void> updateStockMovement(
    String productId,
    String movementId, {
    num? quantity,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  }) async {
    emit(const StockMovementLoading());
    try {
      await _updateStockMovement(
        productId,
        movementId,
        quantity: quantity,
        sourceFirm: sourceFirm,
        branchId: branchId,
        note: note,
        docPaths: docPaths,
      );
      emit(const StockMovementActionSuccess('Hareket güncellendi'));
    } on ApiError catch (e) {
      emit(StockMovementError(e.message));
    } catch (_) {
      emit(const StockMovementError('Hareket güncellenemedi'));
    }
  }

  Future<void> deleteStockMovement(
      String productId, String movementId) async {
    emit(const StockMovementLoading());
    try {
      await _deleteStockMovement(productId, movementId);
      emit(const StockMovementActionSuccess('Hareket silindi'));
    } on ApiError catch (e) {
      emit(StockMovementError(e.message));
    } catch (_) {
      emit(const StockMovementError('Hareket silinemedi'));
    }
  }
}
