import 'package:auto_route/auto_route.dart';

import '../presentation/pages/admin_home_page.dart';

part 'module_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class ModuleAdminRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [];
}
