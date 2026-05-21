import 'package:auto_route/auto_route.dart';

import '../presentation/pages/categories_page.dart';

part 'module_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class ModuleWarehouseRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [];
}
