import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/stock_movement_model.dart';

abstract class IProductRepository {
  Future<ProductsPageModel> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? categoryId,
  });

  Future<ProductModel> getProductById(String id);

  Future<ProductModel> createProduct({
    required Map<String, String> name,
    required String unit,
    required num criticalStock,
    required String categoryId,
    required num quantity,
    bool isActive = true,
    String? imagePath,
  });

  Future<ProductModel> updateProduct(
    String id, {
    Map<String, String>? name,
    String? unit,
    num? criticalStock,
    String? categoryId,
    bool? isActive,
    String? imagePath,
  });

  Future<void> deleteProduct(String id);

  Future<List<CategoryModel>> getCategories();

  Future<StockMovementsPageModel> getStockMovements(
    String productId, {
    int page = 1,
    int limit = 20,
    StockMovementType? type,
  });

  Future<StockMovementModel> addStockMovement(
    String productId, {
    required StockMovementType type,
    required num quantity,
    String? orderId,
    String? sourceFirm,
    String? branchId,
    String? note,
    List<String>? docPaths,
  });

  Future<StockMovementModel> updateStockMovement(
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
