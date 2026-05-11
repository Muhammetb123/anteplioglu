import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../features/auth/presentation/bootstrap_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/signin_page.dart';
import '../../features/auth/presentation/signup_page.dart';
import '../../features/auth/presentation/verify_email_page.dart';
import '../../features/home/presentation/admin_home_page.dart';
import '../../features/home/presentation/main_home_page.dart';
import '../../features/production/presentation/incoming_orders_page.dart';
import '../../features/production/presentation/production_home_page.dart';
import '../../features/warehouse/presentation/categories_page.dart';

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
    AutoRoute(page: IncomingOrdersRoute.page),
  ];
}
