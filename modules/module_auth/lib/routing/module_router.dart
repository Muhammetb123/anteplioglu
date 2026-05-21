import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../presentation/bootstrap_page.dart';
import '../presentation/forgot_password_page.dart';
import '../presentation/signin_page.dart';
import '../presentation/signup_page.dart';
import '../presentation/verify_email_page.dart';

part 'module_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class ModuleAuthRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [];
}
