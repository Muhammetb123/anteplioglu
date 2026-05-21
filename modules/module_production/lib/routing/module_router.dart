import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../presentation/pages/production_home_page.dart';
import '../presentation/pages/raporlama_page.dart';
import '../presentation/pages/siparis_listesi_page.dart';
import '../presentation/pages/tum_hareketler_page.dart';
import '../presentation/pages/urun_detayi_page.dart';
import '../presentation/pages/urun_yonetimi_page.dart';

part 'module_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class ModuleProductionRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [];
}
