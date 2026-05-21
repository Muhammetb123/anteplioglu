import '../../data/models/order_model.dart';

abstract class OrdersState {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class IncomingOrdersLoaded extends OrdersState {
  final List<OrderModel> items;
  final int currentPage;
  final int totalPages;
  final OrderStatus? activeFilter;
  final Map<String, String> branchNames;

  const IncomingOrdersLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.activeFilter,
    this.branchNames = const {},
  });
}

class OrdersByProductLoaded extends OrdersState {
  final OrdersByProductModel data;
  final Map<String, OrderByProductDetailModel> expandedDetails;
  final Map<String, String> categoryNames;

  const OrdersByProductLoaded({
    required this.data,
    this.expandedDetails = const {},
    this.categoryNames = const {},
  });
}

class OrderDetailLoaded extends OrdersState {
  final OrderModel order;

  const OrderDetailLoaded(this.order);
}

class OrderActionSuccess extends OrdersState {
  final OrderModel order;

  const OrderActionSuccess(this.order);
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);
}
