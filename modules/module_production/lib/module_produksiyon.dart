// Data — Models
export 'data/models/category_model.dart';
export 'data/models/order_model.dart';
export 'data/models/product_model.dart' hide ProductStockLevel;
export 'data/models/report_model.dart';
export 'data/models/stock_movement_model.dart';

// Data — Repositories (implementations)
export 'data/repositories/order_repository_impl.dart';
export 'data/repositories/production_admin_repository_impl.dart';
export 'data/repositories/product_repository_impl.dart';
export 'data/repositories/report_repository_impl.dart';

// Domain — Entities
export 'domain/entities/category_entity.dart';
export 'domain/entities/product_entity.dart';
export 'domain/entities/stock_movement_entity.dart';

// Domain — Repositories (interfaces)
export 'domain/repositories/i_order_repository.dart';
export 'domain/repositories/i_production_admin_repository.dart';
export 'domain/repositories/i_product_repository.dart';
export 'domain/repositories/i_report_repository.dart';

// Domain — UseCases
export 'domain/usecases/product_usecases.dart';
export 'domain/usecases/stock_movement_usecases.dart';

// Logic — Cubits & States
export 'logic/orders/orders_cubit.dart';
export 'logic/orders/orders_state.dart';
export 'logic/product/product_cubit.dart';
export 'logic/product/product_state.dart';
export 'logic/report/report_cubit.dart';
export 'logic/report/report_state.dart';
export 'logic/stock_movement/stock_movement_cubit.dart';
export 'logic/stock_movement/stock_movement_state.dart';

// Presentation — Pages
export 'presentation/pages/production_home_page.dart';
export 'presentation/pages/raporlama_page.dart';
export 'presentation/pages/siparis_listesi_page.dart';
export 'presentation/pages/tum_hareketler_page.dart';
export 'presentation/pages/urun_detayi_page.dart';
export 'presentation/pages/urun_yonetimi_page.dart';

// Routing
export 'routing/module_router.dart';
