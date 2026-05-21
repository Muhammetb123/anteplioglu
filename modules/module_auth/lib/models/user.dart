import 'branch.dart';
import 'role.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isVerified;
  final Branch? branch;
  final Role? role;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
    required this.branch,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final branchJson = json['branch'];
    final roleJson = json['role'];
    return User(
      id: (json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      isVerified: (json['isVerified'] ?? false) == true,
      branch: branchJson is Map<String, dynamic> ? Branch.fromJson(branchJson) : null,
      role: roleJson is Map<String, dynamic> ? Role.fromJson(roleJson) : null,
    );
  }
}

