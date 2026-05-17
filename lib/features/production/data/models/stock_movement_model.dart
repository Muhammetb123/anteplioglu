enum StockMovementType {
  in_,
  out,
  loss;

  static StockMovementType fromString(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'in':
        return StockMovementType.in_;
      case 'out':
        return StockMovementType.out;
      case 'loss':
        return StockMovementType.loss;
    }
    return StockMovementType.in_;
  }

  String get apiValue {
    switch (this) {
      case StockMovementType.in_:
        return 'in';
      case StockMovementType.out:
        return 'out';
      case StockMovementType.loss:
        return 'loss';
    }
  }
}

class MovementBranchRef {
  final String id;
  final String name;
  final String code;
  final String type;

  const MovementBranchRef({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });

  factory MovementBranchRef.fromJson(Map<String, dynamic> json) {
    return MovementBranchRef(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
    );
  }
}

class StockMovementModel {
  final String id;
  final String productId;
  final StockMovementType type;
  final num quantity;
  final String? orderId;
  final String? sourceFirm;
  final String? branchId;
  final String? branchName;
  final MovementBranchRef? to;
  final List<String> docUrls;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StockMovementModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.orderId,
    required this.sourceFirm,
    required this.branchId,
    required this.branchName,
    required this.to,
    required this.docUrls,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['docUrls'];
    final docUrls = rawDocs is List
        ? rawDocs.map((e) => e.toString()).toList()
        : <String>[];
    final toJson = json['to'];
    return StockMovementModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: (json['productId'] ?? '').toString(),
      type: StockMovementType.fromString(json['type']?.toString()),
      quantity: (json['quantity'] as num?) ?? 0,
      orderId: json['orderId']?.toString(),
      sourceFirm: json['sourceFirm']?.toString(),
      branchId: json['branchId']?.toString(),
      branchName: json['branchName']?.toString(),
      to: toJson is Map
          ? MovementBranchRef.fromJson(Map<String, dynamic>.from(toJson))
          : null,
      docUrls: docUrls,
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}

class StockMovementsPageModel {
  final List<StockMovementModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const StockMovementsPageModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  static const empty = StockMovementsPageModel(
    items: [],
    total: 0,
    page: 1,
    limit: 10,
    totalPages: 1,
  );

  factory StockMovementsPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) =>
                  StockMovementModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <StockMovementModel>[];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};
    return StockMovementsPageModel(
      items: items,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 10,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
