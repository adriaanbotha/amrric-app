import 'package:upstash_redis/upstash_redis.dart';
import 'package:flutter/foundation.dart';

enum UserRole {
  systemAdmin,
  municipalityAdmin,
  veterinaryUser,
  censusUser,
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? municipalityId; // For municipality admin
  final DateTime lastLogin;
  final bool isActive;
  final int loginAttempts;
  final List<Map<String, dynamic>> activityLog;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.municipalityId,
    required this.lastLogin,
    required this.isActive,
    this.loginAttempts = 0,
    List<Map<String, dynamic>>? activityLog,
  }) : activityLog = activityLog ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
      municipalityId: json['municipalityId'],
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      isActive: json['isActive'] as bool,
      loginAttempts: json['loginAttempts'] as int? ?? 0,
      activityLog: (json['activityLog'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
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
      'loginAttempts': loginAttempts,
      'activityLog': activityLog,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? lastLogin,
    bool? isActive,
    int? loginAttempts,
    List<Map<String, dynamic>>? activityLog,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      activityLog: activityLog ?? this.activityLog,
    );
  }

  bool get requiresOfflineCache => role == UserRole.veterinaryUser || role == UserRole.censusUser;
} 