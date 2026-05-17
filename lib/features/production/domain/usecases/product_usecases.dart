import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/i_product_repository.dart';

class GetProductsUseCase {
  final IProductRepository repository;
  GetProductsUseCase(this.repository);

  Future<ProductsPageEntity> call({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? categoryId,
  }) {
    return repository.getProducts(
      page: page,
      limit: limit,
      search: search,
      isActive: isActive,
      categoryId: categoryId,
    );
  }
}

class GetProductByIdUseCase {
  final IProductRepository repository;
  GetProductByIdUseCase(this.repository);

  Future<ProductEntity> call(String id) {
    return repository.getProductById(id);
  }
}

class CreateProductUseCase {
  final IProductRepository repository;
  CreateProductUseCase(this.repository);

  Future<ProductEntity> call({
    required Map<String, String> name,
    required String unit,
    required num criticalStock,
    required String categoryId,
    required num quantity,
    bool isActive = true,
    String? imagePath,
  }) {
    return repository.createProduct(
      name: name,
      unit: unit,
      criticalStock: criticalStock,
      categoryId: categoryId,
      quantity: quantity,
      isActive: isActive,
      imagePath: imagePath,
    );
  }
}

class UpdateProductUseCase {
  final IProductRepository repository;
  UpdateProductUseCase(this.repository);

  Future<ProductEntity> call(
    String id, {
    Map<String, String>? name,
    String? unit,
    num? criticalStock,
    String? categoryId,
    bool? isActive,
    String? imagePath,
  }) {
    return repository.updateProduct(
      id,
      name: name,
      unit: unit,
      criticalStock: criticalStock,
      categoryId: categoryId,
      isActive: isActive,
      imagePath: imagePath,
    );
  }
}

class GetCategoriesUseCase {
  final IProductRepository repository;
  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() {
    return repository.getCategories();
  }
}
