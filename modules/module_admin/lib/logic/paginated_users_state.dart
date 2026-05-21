import 'package:module_auth/module_auth.dart';

class PaginatedUsersState {
  const PaginatedUsersState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<User> items;
  final int page;
  final bool hasMore;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? error;

  PaginatedUsersState copyWith({
    List<User>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) {
    return PaginatedUsersState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
