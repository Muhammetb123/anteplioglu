import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_error.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../data/models/stock_movement_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final IProductRepository _repo;

  ProductCubit(this._repo) : super(const ProductInitial());

  @override
  void emit(ProductState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> loadProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? categoryId,
  }) async {
    emit(const ProductLoading());
    try {
      final results = await Future.wait([
        _repo.getProducts(
          page: page,
          limit: limit,
          search: search,
          isActive: isActive,
          categoryId: categoryId,
        ),
        _repo.getCategories(),
      ]);
      final productsPage = results[0] as dynamic;
      final categories = results[1] as dynamic;
      emit(ProductsLoaded(
        items: productsPage.items,
        categories: categories,
        currentPage: productsPage.page,
        totalPages: productsPage.totalPages,
        activeSearch: search,
        activeCategoryId: categoryId,
      ));
    } on ApiError catch (e) {
      emit(ProductError(e.message));
    } catch (_) {
      emit(const ProductError('Ürünler yüklenemedi'));
    }
  }

  Future<void> loadProductDetail(String id) async {
    emit(const ProductLoading());
    try {
      final product = await _repo.getProductById(id);
      emit(ProductDetailLoaded(product));
    } on ApiError catch (e) {
      emit(ProductError(e.message));
    } catch (_) {
      emit(const ProductError('Ürün yüklenemedi'));
    }
  }

  Future<void> createProduct({
    required Map<String, String> name,
    required String unit,
    required num criticalStock,
    required String categoryId,
    required num quantity,
    bool isActive = true,
    String? imagePath,
  }) async {
    emit(const ProductLoading());
    try {
      await _repo.createProduct(
        name: name,
        unit: unit,
        criticalStock: criticalStock,
        categoryId: categoryId,
        quantity: quantity,
        isActive: isActive,
        imagePath: imagePath,
      );
      emit(const ProductActionSuccess('Ürün oluşturuldu'));
    } on ApiError catch (e) {
      emit(ProductError(e.message));
    } catch (_) {
      emit(const ProductError('Ürün oluşturulamadı'));
    }
  }

  Future<void> updateProduct(
    String id, {
    Map<String, String>? name,
    String? unit,
    num? criticalStock,
    String? categoryId,
    bool? isActive,
    String? imagePath,
  }) async {
    emit(const ProductLoading());
    try {
      await _repo.updateProduct(
        id,
        name: name,
        unit: unit,
        criticalStock: criticalStock,
        categoryId: categoryId,
        isActive: isActive,
        imagePath: imagePath,
      );
      emit(const ProductActionSuccess('Ürün güncellendi'));
    } on ApiError catch (e) {
      emit(ProductError(e.message));
    } catch (_) {
      emit(const ProductError('Ürün güncellenemedi'));
    }
  }

  Future<void> loadStockMovements(
    String productId, {
    int page = 1,
    int limit = 20,
    StockMovementType? type,
  }) async {
    emit(const ProductLoading());
    try {
      final result = await _repo.getStockMovements(
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
      emit(ProductError(e.message));
    } catch (_) {
      emit(const ProductError('Hareketler yüklenemedi'));
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
    emit(const ProductLoading());
    try {
      await _repo.addStockMovement(
        productId,
        type: type,
        quantity: quantity,
        sourceFirm: sourceFirm,
        branchId: branchId,
        note: note,
        docPaths: docPaths,
      );
      emit(const ProductActionSuccess('Hareket kaydedildi'));
    } on ApiError catch (e) {
      emit(ProductError(e.message));
    } catch (_) {
      emit(const ProductError('Hareket kaydedilemedi'));
    }
  }

  Future<void> deleteStockMovement(
      String productId, String movementId) async {
    emit(const ProductLoading());
    try {
      await _repo.deleteStockMovement(productId, movementId);
      emit(const ProductActionSuccess('Hareket silindi'));
    } on ApiError catch (e) {
      emit(ProductError(e.message));
    } catch (_) {
      emit(const ProductError('Hareket silinemedi'));
    }
  }
}
