import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../../auth/models/user.dart';
import '../data/admin_repository.dart';
import 'paginated_users_state.dart';

typedef UserPredicate = bool Function(User user);

class PaginatedUsersCubit extends Cubit<PaginatedUsersState> {
  PaginatedUsersCubit({
    required AdminRepository repository,
    this.pageSize = 10,
    bool? isPersonel,
    String? roleId,
    String? branchId,
    String? search,
    UserPredicate? userFilter,
  }) : _repository = repository,
       _isPersonel = isPersonel,
       _roleId = roleId,
       _branchId = branchId,
       _search = search?.trim(),
       _userFilter = userFilter,
       super(const PaginatedUsersState());

  final AdminRepository _repository;
  final int pageSize;
  final UserPredicate? _userFilter;
  bool? _isPersonel;
  String? _roleId;
  String? _branchId;
  String? _search;

  Future<void> loadInitial() async {
    if (state.isLoadingInitial) return;
    emit(
      state.copyWith(
        isLoadingInitial: true,
        isLoadingMore: false,
        items: const [],
        page: 0,
        hasMore: true,
        clearError: true,
      ),
    );
    try {
      final res = await _repository.getUsers(
        page: 1,
        limit: pageSize,
        search: _search,
        roleId: _roleId,
        branchId: _branchId,
        isPersonel: _isPersonel,
      );
      emit(
        state.copyWith(
          isLoadingInitial: false,
          items: _filterItems(res.items),
          page: 1,
          hasMore: res.page < res.totalPages,
          clearError: true,
        ),
      );
    } on ApiError catch (e) {
      emit(state.copyWith(isLoadingInitial: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingInitial: false,
          error: 'Kullanicilar yuklenemedi',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingInitial || state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    final nextPage = state.page + 1;
    try {
      final res = await _repository.getUsers(
        page: nextPage,
        limit: pageSize,
        search: _search,
        roleId: _roleId,
        branchId: _branchId,
        isPersonel: _isPersonel,
      );
      final mergedItems = <User>[...state.items, ..._filterItems(res.items)];
      emit(
        state.copyWith(
          isLoadingMore: false,
          items: mergedItems,
          page: nextPage,
          hasMore: res.page < res.totalPages,
          clearError: true,
        ),
      );
    } on ApiError catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          error: 'Daha fazla kullanici yuklenemedi',
        ),
      );
    }
  }

  Future<void> updateFilters({
    bool? isPersonel,
    String? roleId,
    String? branchId,
    String? search,
    bool reload = true,
  }) async {
    _isPersonel = isPersonel;
    _roleId = _normalize(roleId);
    _branchId = _normalize(branchId);
    _search = _normalize(search);
    if (reload) {
      await loadInitial();
    }
  }

  List<User> _filterItems(List<User> users) {
    final predicate = _userFilter;
    if (predicate == null) return users;
    return users.where(predicate).toList();
  }

  String? _normalize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
