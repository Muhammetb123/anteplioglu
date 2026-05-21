import 'package:auto_route/auto_route.dart';

import 'package:module_auth/module_auth.dart';
import 'package:module_admin/module_admin.dart';
import 'package:module_depo/module_depo.dart';
import 'package:module_produksiyon/module_produksiyon.dart';



part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: BootstrapRoute.page, initial: true),
    AutoRoute(page: SignInRoute.page),
    AutoRoute(page: ForgotPasswordRoute.page),
    AutoRoute(page: SignUpRoute.page),
    AutoRoute(page: VerifyEmailRoute.page),
    AutoRoute(page: AdminHomeRoute.page),
    AutoRoute(page: MainHomeRoute.page),
    AutoRoute(page: CategoriesRoute.page),
    AutoRoute(page: ProductionHomeRoute.page),
    AutoRoute(page: SiparisListesiRoute.page),
    AutoRoute(page: UrunYonetimiRoute.page),
    AutoRoute(page: UrunDetayiRoute.page),
    AutoRoute(page: TumHareketlerRoute.page),
    AutoRoute(page: RaporlamaRoute.page),
  ];
}
