import 'package:module_admin/module_admin.dart';
import 'package:module_auth/module_auth.dart';

import '../../domain/repositories/i_production_admin_repository.dart';

class ProductionAdminRepositoryImpl implements IProductionAdminRepository {
  final AdminRepository _adminRepository;

  ProductionAdminRepositoryImpl(this._adminRepository);

  @override
  Future<List<Branch>> getBranches({String? type}) {
    return _adminRepository.getBranches(type: type);
  }

  @override
  Future<void> assignUserRoleAndBranch({
    required String userId,
    required String roleId,
    required String? branchId,
  }) {
    return _adminRepository.assignUserRoleAndBranch(
      userId: userId,
      roleId: roleId,
      branchId: branchId,
    );
  }
}
