import 'package:auto_route/auto_route.dart';

import '../../features/auth/models/user.dart';
import 'app_router.dart';

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
