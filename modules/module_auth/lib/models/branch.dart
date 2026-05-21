class Branch {
  final String id;
  final String code;
  final String name;
  final String type;
  /// API: `level_1` | `level_2` | `level_3`
  final String level;
  final bool isActive;

  Branch({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.level = '',
    this.isActive = true,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    final activeRaw = json['isActive'];
    return Branch(
      id: (json['_id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      isActive: activeRaw is bool ? activeRaw : true,
    );
  }
}

