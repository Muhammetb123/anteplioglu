import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/stock_movement_model.dart';

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
  final List<ProductModel> items;
  final List<CategoryModel> categories;
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
  final ProductModel product;

  const ProductDetailLoaded(this.product);
}

class StockMovementsLoaded extends ProductState {
  final String productId;
  final List<StockMovementModel> items;
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

class ProductActionSuccess extends ProductState {
  final String message;

  const ProductActionSuccess(this.message);
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);
}
