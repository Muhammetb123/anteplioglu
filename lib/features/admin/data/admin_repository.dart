import 'package:dio/dio.dart';

import '../../../core/api_service.dart';
import '../../../core/network/api_error.dart';
import '../../auth/models/branch.dart';
import '../../auth/models/role.dart';
import '../../auth/models/user.dart';

class AdminUsersResponse {
  final List<User> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdminUsersResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class AdminRepository {
  final ApiService api;

  AdminRepository({required this.api});

  Future<List<Role>> getRoles() async {
    try {
      final res = await api.get('admin/roles');
      final data = res.data;
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((e) => Role.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<List<Branch>> getBranches({String? type}) async {
    try {
      final query = <String, dynamic>{};
      if (type != null && type.trim().isNotEmpty) {
        query['type'] = type.trim();
      }
      final res = await api.get(
        'admin/branches',
        queryParameters: query.isEmpty ? null : query,
      );
      final data = res.data;
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((e) => Branch.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<Branch> createBranch({required String name}) async {
    try {
      final res = await api.post('admin/branches', data: {'name': name.trim()});
      final data = res.data;
      if (data is Map) {
        return Branch.fromJson(Map<String, dynamic>.from(data));
      }
      throw ApiError(message: 'Şube olusturma yaniti gecersiz');
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<Branch> updateBranch({
    required String id,
    required String name,
    required String code,
    required String level,
    required bool isActive,
  }) async {
    try {
      final res = await api.patch(
        'admin/branches/${id.trim()}',
        {
          'name': name.trim(),
          'code': code.trim(),
          'level': level,
          'isActive': isActive,
        },
      );
      final data = res.data;
      if (data is Map) {
        return Branch.fromJson(Map<String, dynamic>.from(data));
      }
      throw ApiError(message: 'Birim guncelleme yaniti gecersiz');
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<AdminUsersResponse> getUsers({
    required int page,
    required int limit,
    String? search,
    String? roleId,
    String? branchId,
    bool? isPersonel,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (roleId != null && roleId.trim().isNotEmpty) {
        query['roleId'] = roleId.trim();
      }
      if (branchId != null && branchId.trim().isNotEmpty) {
        query['branchId'] = branchId.trim();
      }
      if (isPersonel != null) {
        query['isPersonel'] = isPersonel;
      }

      final res = await api.get('admin/users', queryParameters: query);
      final body = res.data;
      if (body is! Map) {
        return const AdminUsersResponse(
          items: [],
          total: 0,
          page: 1,
          limit: 10,
          totalPages: 1,
        );
      }

      final map = Map<String, dynamic>.from(body);
      final rawItems = map['items'];
      final rawMeta = map['meta'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : <User>[];
      final meta = rawMeta is Map<String, dynamic>
          ? rawMeta
          : rawMeta is Map
          ? Map<String, dynamic>.from(rawMeta)
          : <String, dynamic>{};

      return AdminUsersResponse(
        items: items,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
        page: (meta['page'] as num?)?.toInt() ?? page,
        limit: (meta['limit'] as num?)?.toInt() ?? limit,
        totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      );
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<void> assignUserRoleAndBranch({
    required String userId,
    required String roleId,
    String? branchId,
  }) async {
    try {
      await api.patch('admin/users/${userId.trim()}/role-branch', {
        'roleId': roleId.trim(),
        'branchId': branchId?.trim(),
      });
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
