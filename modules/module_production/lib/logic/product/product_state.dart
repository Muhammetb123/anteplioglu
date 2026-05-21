import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

/// Состояния исключительно для CRUD продуктов (SRP).
/// Движения склада — в [StockMovementState].
abstract class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> items;
  final List<CategoryEntity> categories;
  final int currentPage;
  final int totalPages;
  final String? activeSearch;
  final String? activeCategoryId;

  const ProductsLoaded({
    required this.items,
    required this.categories,
    required this.currentPage,
    required this.totalPages,
    this.activeSearch,
    this.activeCategoryId,
  });
}

class ProductDetailLoaded extends ProductState {
  final ProductEntity product;

  const ProductDetailLoaded(this.product);
}

class ProductActionSuccess extends ProductState {
  final String message;

  const ProductActionSuccess(this.message);
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);
}
