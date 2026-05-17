class ReportByProductBranchModel {
  final String branchId;
  final String branchName;
  final String branchCode;
  final num quantity;
  final num lineTotal;

  const ReportByProductBranchModel({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.quantity,
    required this.lineTotal,
  });

  factory ReportByProductBranchModel.fromJson(Map<String, dynamic> json) {
    return ReportByProductBranchModel(
      branchId: (json['branchId'] ?? '').toString(),
      branchName: (json['branchName'] ?? '').toString(),
      branchCode: (json['branchCode'] ?? '').toString(),
      quantity: (json['quantity'] as num?) ?? 0,
      lineTotal: (json['lineTotal'] as num?) ?? 0,
    );
  }
}

class ReportByProductItemModel {
  final String productId;
  final String productName;
  final num totalQuantity;
  final num totalLineTotal;
  final List<ReportByProductBranchModel> byBranch;
  final String? imageUrl;

  const ReportByProductItemModel({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.totalLineTotal,
    required this.byBranch,
    this.imageUrl,
  });

  factory ReportByProductItemModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['byBranch'];
    final byBranch = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => ReportByProductBranchModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
        : <ReportByProductBranchModel>[];
    return ReportByProductItemModel(
      productId: (json['productId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      totalQuantity: (json['totalQuantity'] as num?) ?? 0,
      totalLineTotal: (json['totalLineTotal'] as num?) ?? 0,
      byBranch: byBranch,
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class ReportByProductModel {
  final List<ReportByProductItemModel> items;

  const ReportByProductModel({required this.items});

  num get grandTotal =>
      items.fold(0, (sum, item) => sum + item.totalLineTotal);

  factory ReportByProductModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => ReportByProductItemModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
        : <ReportByProductItemModel>[];
    return ReportByProductModel(items: items);
  }
}

class ReportByBranchProductModel {
  final String productId;
  final String productName;
  final num quantity;
  final num lineTotal;
  final String? imageUrl;

  const ReportByBranchProductModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.lineTotal,
    this.imageUrl,
  });

  factory ReportByBranchProductModel.fromJson(Map<String, dynamic> json) {
    return ReportByBranchProductModel(
      productId: (json['productId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      quantity: (json['quantity'] as num?) ?? 0,
      lineTotal: (json['lineTotal'] as num?) ?? 0,
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class ReportByBranchItemModel {
  final String branchId;
  final String branchName;
  final String branchCode;
  final num totalLineTotal;
  final num totalQuantity;
  final List<ReportByBranchProductModel> byProduct;

  const ReportByBranchItemModel({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.totalLineTotal,
    required this.totalQuantity,
    required this.byProduct,
  });

  factory ReportByBranchItemModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['byProduct'];
    final byProduct = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => ReportByBranchProductModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
        : <ReportByBranchProductModel>[];
    return ReportByBranchItemModel(
      branchId: (json['branchId'] ?? '').toString(),
      branchName: (json['branchName'] ?? '').toString(),
      branchCode: (json['branchCode'] ?? '').toString(),
      totalLineTotal: (json['totalLineTotal'] as num?) ?? 0,
      totalQuantity: (json['totalQuantity'] as num?) ?? 0,
      byProduct: byProduct,
    );
  }
}

class ReportByBranchModel {
  final List<ReportByBranchItemModel> items;

  const ReportByBranchModel({required this.items});

  num get grandTotal =>
      items.fold(0, (sum, item) => sum + item.totalLineTotal);

  factory ReportByBranchModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => ReportByBranchItemModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
        : <ReportByBranchItemModel>[];
    return ReportByBranchModel(items: items);
  }
}
