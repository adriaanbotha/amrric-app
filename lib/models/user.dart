import 'dart:convert';
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
    debugPrint('Creating User from JSON: $json');
    
    // Convert string 'true'/'false' to bool
    bool parseStringBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    // Parse login attempts
    int parseLoginAttempts(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Parse activity log
    List<Map<String, dynamic>> parseActivityLog(dynamic value) {
      try {
        if (value == null || value == '') return [];
        
        if (value is String) {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return List<Map<String, dynamic>>.from(
              decoded.map((e) => Map<String, dynamic>.from(e))
            );
          }
        }
        
        debugPrint('Failed to parse activity log, returning empty list: $value');
        return [];
      } catch (e) {
        debugPrint('Error parsing activity log: $e');
        return [];
      }
    }

    try {
      final user = User(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == (json['role']?.toString() ?? '').toLowerCase(),
          orElse: () => UserRole.censusUser,
        ),
        municipalityId: json['municipalityId']?.toString(),
        lastLogin: DateTime.tryParse(json['lastLogin']?.toString() ?? '') ?? DateTime.now(),
        isActive: parseStringBool(json['isActive']),
        loginAttempts: parseLoginAttempts(json['loginAttempts']),
        activityLog: parseActivityLog(json['activityLog']),
      );
      debugPrint('Successfully created User object: ${user.toString()}');
      return user;
    } catch (e, stackTrace) {
      debugPrint('Error creating User from JSON: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'municipalityId': municipalityId,
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive.toString(),
      'loginAttempts': loginAttempts.toString(),
      'activityLog': jsonEncode(activityLog),
    };
    debugPrint('Converting User to JSON: $json');
    return json;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, isActive: $isActive, loginAttempts: $loginAttempts)';
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? municipalityId,
    DateTime? lastLogin,
    bool? isActive,
    int? loginAttempts,
    List<Map<String, dynamic>>? activityLog,
  }) {
    debugPrint('Creating copy of User with changes: ${{'id': id, 'email': email, 'name': name, 'role': role, 'isActive': isActive, 'loginAttempts': loginAttempts}}');
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      municipalityId: municipalityId ?? this.municipalityId,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      activityLog: activityLog ?? this.activityLog,
    );
  }

  bool get requiresOfflineCache => role == UserRole.veterinaryUser || role == UserRole.censusUser;
} 