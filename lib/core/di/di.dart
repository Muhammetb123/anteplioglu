import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../routing/app_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/logic/auth_cubit.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/production/data/production_repository.dart';
import '../../features/warehouse/data/warehouse_repository.dart';
import '../storage/token_storage.dart';

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
    ..registerLazySingleton<ProductionRepository>(
      () => ProductionRepository(api: getIt<ApiService>()),
    )
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        repo: getIt<AuthRepository>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    );
}
