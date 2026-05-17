import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../entities/stock_movement_entity.dart';
import '../../data/models/stock_movement_model.dart' show StockMovementType;

abstract class IProductRepository {
  Future<ProductsPageEntity> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? categoryId,
  });

  Future<ProductEntity> getProductById(String id);

  Future<ProductEntity> createProduct({
    required Map<String, String> name,
    required String unit,
    required num criticalStock,
    required String categoryId,
    required num quantity,
    bool isActive = true,
    String? imagePath,
  });

  Future<ProductEntity> updateProduct(
    String id, {
    Map<String, String>? name,
    String? unit,
    num? criticalStock,
    String? categoryId,
    bool? isActive,
    String? imagePath,
  });

  Future<void> deleteProduct(String id);

  Future<List<CategoryEntity>> getCategories();

  Future<StockMovementsPageEntity> getStockMovements(
    String productId, {
    int page = 1,
    int limit = 20,
    StockMovementType? type,
  });

  Future<StockMovementEntity> addStockMovement(
    String productId, {
    required StockMovementType type,
    required num quantity,
    String? orderId,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  });

  Future<StockMovementEntity> updateStockMovement(
    String productId,
    String movementId, {
    num? quantity,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  });

  Future<void> deleteStockMovement(String productId, String movementId);
}
