import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/network/api_error.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../data/models/order_model.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final IOrderRepository _repo;

  OrdersCubit(this._repo) : super(const OrdersInitial());

  @override
  void emit(OrdersState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> loadIncomingOrders({
    int page = 1,
    int limit = 10,
    OrderStatus? status,
  }) async {
    emit(const OrdersLoading());
    try {
      final results = await Future.wait([
        _repo.getIncomingOrders(page: page, limit: limit, status: status),
        _repo.getBranchNames(),
      ]);
      final result = results[0] as OrdersPageModel;
      final branchNames = results[1] as Map<String, String>;
      emit(IncomingOrdersLoaded(
        items: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        activeFilter: status,
        branchNames: branchNames,
      ));
    } on ApiError catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError('Siparişler yüklenemedi'));
    }
  }

  Future<void> loadOrdersByProduct({String? categoryId}) async {
    emit(const OrdersLoading());
    try {
      final results = await Future.wait([
        _repo.getOrdersByProduct(categoryId: categoryId),
        _repo.getCategoryNames(),
      ]);
      final result = results[0] as OrdersByProductModel;
      final categoryNames = results[1] as Map<String, String>;
      emit(OrdersByProductLoaded(data: result, categoryNames: categoryNames));
    } on ApiError catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError('Siparişler yüklenemedi'));
    }
  }

  Future<void> loadOrderByProductDetail(String productId) async {
    final current = state;
    if (current is! OrdersByProductLoaded) return;
    try {
      final detail = await _repo.getOrdersByProductDetail(productId);
      emit(OrdersByProductLoaded(
        data: current.data,
        expandedDetails: {
          ...current.expandedDetails,
          productId: detail,
        },
      ));
    } on ApiError catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError('Ürün detayı yüklenemedi'));
    }
  }

  Future<void> loadOrderById(String id) async {
    emit(const OrdersLoading());
    try {
      final order = await _repo.getOrderById(id);
      emit(OrderDetailLoaded(order));
    } on ApiError catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError('Sipariş yüklenemedi'));
    }
  }

  Future<void> acceptOrder(
    String id, {
    required List<Map<String, dynamic>> items,
  }) async {
    emit(const OrdersLoading());
    try {
      final order = await _repo.acceptOrder(id, items: items);
      emit(OrderActionSuccess(order));
    } on ApiError catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError('Sipariş kabul edilemedi'));
    }
  }

  Future<void> completeOrder(String id) async {
    emit(const OrdersLoading());
    try {
      final order = await _repo.completeOrder(id);
      emit(OrderActionSuccess(order));
    } on ApiError catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError('Sipariş tamamlanamadı'));
    }
  }

  Future<void> cancelOrder(String id) async {
    emit(const OrdersLoading());
    try {
      final order = await _repo.cancelOrder(id);
      emit(OrderActionSuccess(order));
    } on ApiError catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError('Sipariş iptal edilemedi'));
    }
  }
}
