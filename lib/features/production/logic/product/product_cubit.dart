import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_error.dart';
import '../../domain/usecases/product_usecases.dart';
import 'product_state.dart';

/// Cubit отвечает исключительно за CRUD продуктов (SRP).
/// Движения склада — в [StockMovementCubit].
class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase _getProducts;
  final GetProductByIdUseCase _getProductById;
  final CreateProductUseCase _createProduct;
  final UpdateProductUseCase _updateProduct;
  final GetCategoriesUseCase _getCategories;

  ProductCubit({
    required GetProductsUseCase getProducts,
    required GetProductByIdUseCase getProductById,
    required CreateProductUseCase createProduct,
    required UpdateProductUseCase updateProduct,
    required GetCategoriesUseCase getCategories,
  })  : _getProducts = getProducts,
        _getProductById = getProductById,
        _createProduct = createProduct,
        _updateProduct = updateProduct,
        _getCategories = getCategories,
        super(const ProductInitial());

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
        _getProducts(
          page: page,
          limit: limit,
          search: search,
          isActive: isActive,
          categoryId: categoryId,
        ),
        _getCategories(),
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
      final product = await _getProductById(id);
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
      await _createProduct(
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
      await _updateProduct(
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
}
