import '../../../core/models/localized_name.dart';

enum ProductionOrderStatus {
  draft,
  accepted,
  completed,
  cancelled,
  unknown;

  static ProductionOrderStatus fromString(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'draft':
        return ProductionOrderStatus.draft;
      case 'accepted':
        return ProductionOrderStatus.accepted;
      case 'completed':
        return ProductionOrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return ProductionOrderStatus.cancelled;
    }
    return ProductionOrderStatus.unknown;
  }

  String get apiValue {
    switch (this) {
      case ProductionOrderStatus.draft:
        return 'draft';
      case ProductionOrderStatus.accepted:
        return 'accepted';
      case ProductionOrderStatus.completed:
        return 'completed';
      case ProductionOrderStatus.cancelled:
        return 'cancelled';
      case ProductionOrderStatus.unknown:
        return '';
    }
  }
}

class ProductionOrderItem {
  final String productId;
  final num quantity;
  final num? acceptQty;
  final LocalizedName productName;
  final String? note;
  final String? acceptNote;

  const ProductionOrderItem({
    required this.productId,
    required this.quantity,
    required this.acceptQty,
    required this.productName,
    required this.note,
    required this.acceptNote,
  });

  factory ProductionOrderItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final productName = productJson is Map<String, dynamic>
        ? LocalizedName.fromJson(productJson['name'])
        : LocalizedName.empty;
    return ProductionOrderItem(
      productId: (json['productId'] ?? '').toString(),
      quantity: (json['quantity'] as num?) ?? 0,
      acceptQty: json['acceptQty'] as num?,
      productName: productName,
      note: json['note']?.toString(),
      acceptNote: json['acceptNote']?.toString(),
    );
  }
}

class ProductionOrder {
  final String id;
  final String orderNumber;
  final String fromBranchId;
  final String toBranchId;
  final ProductionOrderStatus status;
  final List<ProductionOrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductionOrder({
    required this.id,
    required this.orderNumber,
    required this.fromBranchId,
    required this.toBranchId,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (e) => ProductionOrderItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <ProductionOrderItem>[];
    return ProductionOrder(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      fromBranchId: (json['from'] ?? '').toString(),
      toBranchId: (json['to'] ?? '').toString(),
      status: ProductionOrderStatus.fromString(json['status']?.toString()),
      items: items,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}

class ProductionOrdersPage {
  final List<ProductionOrder> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProductionOrdersPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  static const empty = ProductionOrdersPage(
    items: [],
    total: 0,
    page: 1,
    limit: 10,
    totalPages: 1,
  );
}
