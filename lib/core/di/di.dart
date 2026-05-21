import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_admin/module_admin.dart';
import 'package:module_depo/module_depo.dart';
import 'package:module_produksiyon/module_produksiyon.dart';

import 'package:core/core.dart';
export 'package:core/core.dart' show getIt;
import '../routing/app_router.dart';
import '../routing/auth_navigator_impl.dart';

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
    ..registerLazySingleton<AuthNavigator>(() => AuthNavigatorImpl())
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
