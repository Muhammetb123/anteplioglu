import 'package:auto_route/auto_route.dart';

import 'package:module_auth/module_auth.dart';
import 'package:module_admin/module_admin.dart';
import 'package:module_depo/module_depo.dart';
import 'package:module_produksiyon/module_produksiyon.dart';

/// Admin ilk giriş / oturum yenileme sonrası hedef rota.
///
/// - Birim yok → Admin ana sayfa (kullanıcılar).
/// - Depo birimi → Kategoriler (Depo çekmecesi ilk alt sekme).
/// - Produksiyon birimi → Produksiyon anasayfa.
PageRouteInfo<void> adminInitialRouteForUser(User user) {
  final code = user.branch?.code;
  if (code == 'warehouse') return const CategoriesRoute();
  if (code == 'production') return const ProductionHomeRoute();
  return const AdminHomeRoute();
}
