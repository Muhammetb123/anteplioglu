import 'package:module_auth/module_auth.dart';

abstract class IProductionAdminRepository {
  Future<List<Branch>> getBranches({String? type});
  Future<void> assignUserRoleAndBranch({
    required String userId,
    required String roleId,
    required String? branchId,
  });
}
