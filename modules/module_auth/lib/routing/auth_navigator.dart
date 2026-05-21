import 'package:flutter/material.dart';
import '../models/user.dart';

/// Cross-module navigation abstraction.
///
/// Implemented in the root app to bridge feature modules without
/// creating circular dependencies between them.
abstract class AuthNavigator {
  void navigateOnAuthenticated(BuildContext context, User user);
  void navigateOnUnauthenticated(BuildContext context);

  /// Admin → warehouse categories.
  void navigateToCategories(BuildContext context);

  /// Admin / warehouse → production home.
  void navigateToProductionHome(BuildContext context);

  /// Admin / production → order list (siparis listesi).
  void navigateToOrderList(BuildContext context);

  /// Warehouse → admin home (after switching role/branch).
  void navigateToAdminHome(BuildContext context);
}
