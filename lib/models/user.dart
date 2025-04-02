import 'package:upstash_redis/upstash_redis.dart';

enum UserRole {
  systemAdmin,
  municipalityAdmin,
  veterinary,
  normal
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? municipalityId; // For municipality admin
  final DateTime lastLogin;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.municipalityId,
    required this.lastLogin,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.normal,
      ),
      municipalityId: json['municipalityId'],
      lastLogin: DateTime.parse(json['lastLogin']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'municipalityId': municipalityId,
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
    };
  }

  bool get requiresOfflineCache => role == UserRole.veterinary || role == UserRole.normal;
} 