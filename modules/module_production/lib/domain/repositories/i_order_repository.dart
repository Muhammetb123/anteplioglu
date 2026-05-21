import '../../data/models/order_model.dart';

abstract class IOrderRepository {
  Future<OrdersPageModel> getIncomingOrders({
    int page = 1,
    int limit = 10,
    OrderStatus? status,
  });

  Future<OrdersPageModel> getPlacedOrders({
    int page = 1,
    int limit = 10,
    OrderStatus? status,
  });

  Future<OrdersByProductModel> getOrdersByProduct({String? categoryId});

  Future<OrderByProductDetailModel> getOrdersByProductDetail(String productId);

  Future<Map<String, String>> getBranchNames();

  Future<Map<String, String>> getCategoryNames();

  Future<OrderModel> getOrderById(String id);

  Future<OrderModel> acceptOrder(
    String id, {
    required List<Map<String, dynamic>> items,
  });

  Future<OrderModel> completeOrder(String id);

  Future<OrderModel> cancelOrder(String id);
}
