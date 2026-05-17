import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../routing/app_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/logic/auth_cubit.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/warehouse/data/warehouse_repository.dart';
import '../../features/production/data/repositories/order_repository_impl.dart';
import '../../features/production/data/repositories/product_repository_impl.dart';
import '../../features/production/data/repositories/report_repository_impl.dart';
import '../../features/production/domain/repositories/i_order_repository.dart';
import '../../features/production/domain/repositories/i_product_repository.dart';
import '../../features/production/domain/repositories/i_report_repository.dart';
import '../storage/token_storage.dart';

import '../../features/production/domain/usecases/product_usecases.dart';
import '../../features/production/domain/usecases/stock_movement_usecases.dart';
import '../../features/production/logic/product/product_cubit.dart';
import '../../features/production/logic/stock_movement/stock_movement_cubit.dart';

import '../../features/production/data/repositories/production_admin_repository_impl.dart';
import '../../features/production/domain/repositories/i_production_admin_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<TokenStorage>(TokenStorage(prefs))
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerLazySingleton<Dio>(() => Dio())
    ..registerLazySingleton<ApiService>(
      () => ApiService(dio: getIt<Dio>(), tokenStorage: getIt<TokenStorage>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        api: getIt<ApiService>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    )
    ..registerLazySingleton<AdminRepository>(
      () => AdminRepository(api: getIt<ApiService>()),
    )
    ..registerLazySingleton<WarehouseRepository>(
      () => WarehouseRepository(api: getIt<ApiService>()),
    )
    ..registerLazySingleton<IOrderRepository>(
      () => OrderRepositoryImpl(api: getIt<ApiService>()),
    )
    ..registerLazySingleton<IProductRepository>(
      () => ProductRepositoryImpl(api: getIt<ApiService>()),
    )
    ..registerLazySingleton<IReportRepository>(
      () => ReportRepositoryImpl(api: getIt<ApiService>()),
    )
    ..registerLazySingleton<IProductionAdminRepository>(
      () => ProductionAdminRepositoryImpl(getIt<AdminRepository>()),
    )
    // Production UseCases
    ..registerLazySingleton(() => GetProductsUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => GetProductByIdUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => CreateProductUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => UpdateProductUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => GetCategoriesUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => GetStockMovementsUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => AddStockMovementUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => UpdateStockMovementUseCase(getIt<IProductRepository>()))
    ..registerLazySingleton(() => DeleteStockMovementUseCase(getIt<IProductRepository>()))
    // Cubits
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        repo: getIt<AuthRepository>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    )
    ..registerFactory<ProductCubit>(
      () => ProductCubit(
        getProducts: getIt<GetProductsUseCase>(),
        getProductById: getIt<GetProductByIdUseCase>(),
        createProduct: getIt<CreateProductUseCase>(),
        updateProduct: getIt<UpdateProductUseCase>(),
        getCategories: getIt<GetCategoriesUseCase>(),
      ),
    )
    ..registerFactory<StockMovementCubit>(
      () => StockMovementCubit(
        getStockMovements: getIt<GetStockMovementsUseCase>(),
        addStockMovement: getIt<AddStockMovementUseCase>(),
        updateStockMovement: getIt<UpdateStockMovementUseCase>(),
        deleteStockMovement: getIt<DeleteStockMovementUseCase>(),
      ),
    );
}
