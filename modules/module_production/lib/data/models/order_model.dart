import 'package:core/models/localized_name.dart';

enum OrderStatus {
  draft,
  accepted,
  completed,
  cancelled,
  unknown;

  static OrderStatus fromString(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'draft':
        return OrderStatus.draft;
      case 'accepted':
        return OrderStatus.accepted;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
    }
    return OrderStatus.unknown;
  }

  String get apiValue {
    switch (this) {
      case OrderStatus.draft:
        return 'draft';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.unknown:
        return '';
    }
  }
}

class OrderItemModel {
  final String productId;
  final num quantity;
  final num? acceptQty;
  final LocalizedName productName;
  final String? productImageUrl;
  final String? note;
  final String? imageUrl;
  final String? acceptNote;

  const OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.acceptQty,
    required this.productName,
    required this.productImageUrl,
    required this.note,
    required this.imageUrl,
    required this.acceptNote,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final productMap = productJson is Map<String, dynamic> ? productJson : null;
    return OrderItemModel(
      productId: (json['productId'] ?? '').toString(),
      quantity: (json['quantity'] as num?) ?? 0,
      acceptQty: json['acceptQty'] as num?,
      productName: productMap != null
          ? LocalizedName.fromJson(productMap['name'])
          : LocalizedName.empty,
      productImageUrl: productMap?['imageUrl']?.toString(),
      note: json['note']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      acceptNote: json['acceptNote']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String fromBranchId;
  final String fromBranchName;
  final String toBranchId;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.fromBranchId,
    required this.fromBranchName,
    required this.toBranchId,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <OrderItemModel>[];
    final fromRaw = json['from'];
    final String fromBranchId;
    final String fromBranchName;
    if (fromRaw is Map) {
      fromBranchId = (fromRaw['_id'] ?? fromRaw['id'] ?? '').toString();
      fromBranchName = (fromRaw['name'] ?? fromBranchId).toString();
    } else {
      fromBranchId = (fromRaw ?? '').toString();
      fromBranchName = fromBranchId;
    }
    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      fromBranchId: fromBranchId,
      fromBranchName: fromBranchName,
      toBranchId: (json['to'] ?? '').toString(),
      status: OrderStatus.fromString(json['status']?.toString()),
      items: items,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}

class OrdersPageModel {
  final List<OrderModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const OrdersPageModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  static const empty = OrdersPageModel(
    items: [],
    total: 0,
    page: 1,
    limit: 10,
    totalPages: 1,
  );

  factory OrdersPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <OrderModel>[];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};
    return OrdersPageModel(
      items: items,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 10,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class OrderByProductItemModel {
  final String productId;
  final LocalizedName name;
  final num total;
  final num quantity;
  final String? imageUrl;
  final String unit;
  final String? categoryId;
  final String categoryName;

  const OrderByProductItemModel({
    required this.productId,
    required this.name,
    required this.total,
    required this.quantity,
    required this.imageUrl,
    required this.unit,
    required this.categoryId,
    required this.categoryName,
  });

  factory OrderByProductItemModel.fromJson(Map<String, dynamic> json) {
    return OrderByProductItemModel(
      productId: (json['productId'] ?? '').toString(),
      name: LocalizedName.fromJson(json['name']),
      total: (json['total'] as num?) ?? 0,
      quantity: (json['quantity'] as num?) ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      unit: (json['unit'] ?? '').toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: (json['categoryName'] ?? '').toString(),
    );
  }
}

class OrdersByProductModel {
  final int totalOrders;
  final List<OrderByProductItemModel> byProduct;

  const OrdersByProductModel({
    required this.totalOrders,
    required this.byProduct,
  });

  factory OrdersByProductModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['byProduct'];
    final byProduct = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => OrderByProductItemModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
        : <OrderByProductItemModel>[];
    return OrdersByProductModel(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      byProduct: byProduct,
    );
  }
}

class OrderRequestModel {
  final String orderId;
  final String orderNumber;
  final String branchId;
  final String branchName;
  final String branchCode;
  final num quantity;
  final num? acceptQty;
  final String? note;
  final String? imageUrl;
  final String? acceptNote;

  const OrderRequestModel({
    required this.orderId,
    required this.orderNumber,
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.quantity,
    required this.acceptQty,
    required this.note,
    required this.imageUrl,
    required this.acceptNote,
  });

  factory OrderRequestModel.fromJson(Map<String, dynamic> json) {
    return OrderRequestModel(
      orderId: (json['orderId'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      branchId: (json['branchId'] ?? '').toString(),
      branchName: (json['branchName'] ?? '').toString(),
      branchCode: (json['branchCode'] ?? '').toString(),
      quantity: (json['quantity'] as num?) ?? 0,
      acceptQty: json['acceptQty'] as num?,
      note: json['note']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      acceptNote: json['acceptNote']?.toString(),
    );
  }
}

class OrderByProductDetailModel {
  final String productId;
  final LocalizedName name;
  final String unit;
  final num quantity;
  final String? imageUrl;
  final int totalOrders;
  final List<OrderRequestModel> requests;

  const OrderByProductDetailModel({
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.imageUrl,
    required this.totalOrders,
    required this.requests,
  });

  factory OrderByProductDetailModel.fromJson(Map<String, dynamic> json) {
    final rawRequests = json['requests'];
    final requests = rawRequests is List
        ? rawRequests
              .whereType<Map>()
              .map((e) =>
                  OrderRequestModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <OrderRequestModel>[];
    return OrderByProductDetailModel(
      productId: (json['productId'] ?? '').toString(),
      name: LocalizedName.fromJson(json['name']),
      unit: (json['unit'] ?? '').toString(),
      quantity: (json['quantity'] as num?) ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      requests: requests,
    );
  }
}
