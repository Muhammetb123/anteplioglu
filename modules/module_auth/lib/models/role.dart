class Role {
  final String id;
  final String code;
  final String name;

  Role({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: (json['_id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

