import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_admin/module_admin.dart';
import 'package:module_depo/module_depo.dart';
import 'package:module_produksiyon/module_produksiyon.dart';

import 'app_router.dart';
import 'admin_initial_route.dart';

class AuthNavigatorImpl implements AuthNavigator {
  @override
  void navigateOnAuthenticated(BuildContext context, User user) {
    final roleCode = user.role?.code;
    if (roleCode == 'admin') {
      context.router.replaceAll([adminInitialRouteForUser(user)]);
    } else {
      context.router.replaceAll([const MainHomeRoute()]);
    }
  }

  @override
  void navigateOnUnauthenticated(BuildContext context) {
    context.router.replaceAll([SignInRoute()]);
  }

  @override
  void navigateToCategories(BuildContext context) {
    context.router.replace(const CategoriesRoute());
  }

  @override
  void navigateToProductionHome(BuildContext context) {
    context.router.replace(const ProductionHomeRoute());
  }

  @override
  void navigateToOrderList(BuildContext context) {
    context.router.replace(const SiparisListesiRoute());
  }

  @override
  void navigateToAdminHome(BuildContext context) {
    context.router.replace(const AdminHomeRoute());
  }
}
