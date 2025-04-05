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
  final String? councilId; // For council-specific operations
  final String? locationId; // For location-specific operations
  final DateTime? lastLogin;
  final bool isActive;
  final int loginAttempts;
  final List<Map<String, dynamic>> activityLog;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.municipalityId,
    this.councilId,
    this.locationId,
    this.lastLogin,
    required this.isActive,
    this.loginAttempts = 0,
    List<Map<String, dynamic>>? activityLog,
  }) : activityLog = activityLog ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Parse activity log
      List<Map<String, dynamic>> activityLog = [];
      if (json['activityLog'] != null) {
        if (json['activityLog'] is String) {
          try {
            final decoded = jsonDecode(json['activityLog']);
            if (decoded is List) {
              activityLog = decoded.map((e) => e as Map<String, dynamic>).toList();
            }
          } catch (e) {
            debugPrint('Error parsing activity log string: $e');
            // If parsing fails, try to parse as a list of strings
            try {
              final list = jsonDecode('[' + json['activityLog'] + ']');
              if (list is List) {
                activityLog = list.map((e) => e as Map<String, dynamic>).toList();
              }
            } catch (e) {
              debugPrint('Error parsing activity log as list: $e');
            }
          }
        } else if (json['activityLog'] is List) {
          activityLog = json['activityLog'].map((e) {
            if (e is String) {
              try {
                return jsonDecode(e) as Map<String, dynamic>;
              } catch (e) {
                debugPrint('Error parsing activity log entry: $e');
                return <String, dynamic>{};
              }
            }
            return e as Map<String, dynamic>;
          }).toList();
        }
      }

      return User(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        role: _parseUserRole(json['role']?.toString() ?? ''),
        municipalityId: json['municipalityId']?.toString() ?? '',
        councilId: json['councilId']?.toString() ?? '',
        locationId: json['locationId']?.toString() ?? '',
        isActive: json['isActive']?.toString().toLowerCase() == 'true',
        lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
        loginAttempts: int.tryParse(json['loginAttempts']?.toString() ?? '0') ?? 0,
        activityLog: activityLog,
      );
    } catch (e, stack) {
      debugPrint('Error parsing User from JSON: $e');
      debugPrint('Stack trace: $stack');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'loginAttempts': loginAttempts,
      'lastLogin': lastLogin?.toIso8601String(),
      'municipalityId': municipalityId,
      'councilId': councilId,
      'locationId': locationId,
      'activityLog': activityLog,
    };
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
    String? councilId,
    String? locationId,
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
      councilId: councilId ?? this.councilId,
      locationId: locationId ?? this.locationId,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      activityLog: activityLog ?? this.activityLog,
    );
  }

  bool get requiresOfflineCache => role == UserRole.veterinaryUser || role == UserRole.censusUser;

  static UserRole _parseUserRole(String value) {
    if (value.isEmpty) throw Exception('Invalid role: $value');
    final roleStr = value.toLowerCase();
    switch (roleStr) {
      case 'systemadmin':
        return UserRole.systemAdmin;
      case 'municipalityadmin':
        return UserRole.municipalityAdmin;
      case 'veterinaryuser':
        return UserRole.veterinaryUser;
      case 'censususer':
        return UserRole.censusUser;
      default:
        throw Exception('Invalid role: $value');
    }
  }
} 