import '../../../auth/models/branch.dart';

abstract class IProductionAdminRepository {
  Future<List<Branch>> getBranches({String? type});
  Future<void> assignUserRoleAndBranch({
    required String userId,
    required String roleId,
    required String? branchId,
  });
}
