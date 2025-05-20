import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';

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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : activityLog = activityLog ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    // Guard: required fields must be present
    if (json['id'] == null || json['email'] == null || json['role'] == null) {
      throw Exception('Missing required user fields: id, email, or role');
    }
    try {
      List<Map<String, dynamic>> activityLog = [];
      
      if (json['activityLog'] != null) {
        if (json['activityLog'] is String) {
          try {
            String logStr = json['activityLog'] as String;
            
            // Check if it's a Dart Map literal format
            if (logStr.startsWith('[{') && !logStr.contains('"')) {
              // First, extract the structure
              final matches = RegExp(r'\{([^}]+)\}').allMatches(logStr);
              final entries = matches.map((match) {
                final entryStr = match.group(1)!;
                final parts = entryStr.split(',').map((part) {
                  final keyValue = part.trim().split(':');
                  if (keyValue.length != 2) return null;
                  
                  final key = keyValue[0].trim();
                  var value = keyValue[1].trim();
                  
                  // Handle special cases
                  if (RegExp(r'^\d+$').hasMatch(value)) {
                    // It's a number, leave as is
                    return '"$key": $value';
                  } else if (value == 'true' || value == 'false') {
                    // It's a boolean, leave as is
                    return '"$key": $value';
                  } else {
                    // It's a string, add quotes
                    return '"$key": "$value"';
                  }
                }).where((e) => e != null).join(',');
                return '{$parts}';
              }).join(',');
              
              logStr = '[$entries]';
            }
            
            final decoded = jsonDecode(logStr);
            if (decoded is List) {
              activityLog = List<Map<String, dynamic>>.from(decoded);
            }
          } catch (e) {
            debugPrint('Error parsing activity log string: $e');
            debugPrint('Original log string: ${json['activityLog']}');
            // Fallback: try to parse the original format directly
            try {
              final rawList = json['activityLog'].toString()
                .substring(1, json['activityLog'].toString().length - 1) // Remove outer []
                .split('}, {')
                .map((entry) {
                  entry = entry.replaceAll('{', '').replaceAll('}', '');
                  final map = <String, dynamic>{};
                  entry.split(',').forEach((pair) {
                    final parts = pair.trim().split(':');
                    if (parts.length == 2) {
                      final key = parts[0].trim();
                      final value = parts[1].trim();
                      map[key] = value;
                    }
                  });
                  return map;
                })
                .toList();
              activityLog = rawList.cast<Map<String, dynamic>>();
            } catch (e2) {
              debugPrint('Fallback parsing also failed: $e2');
            }
          }
        } else if (json['activityLog'] is List) {
          activityLog = (json['activityLog'] as List).map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else if (item is String) {
              try {
                return jsonDecode(item) as Map<String, dynamic>;
              } catch (e) {
                debugPrint('Error parsing activity log item: $e');
                return <String, dynamic>{};
              }
            }
            return <String, dynamic>{};
          }).toList();
        }
      }

      return User(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        role: _parseUserRole(json['role']?.toString() ?? ''),
        municipalityId: json['municipalityId']?.toString(),
        councilId: json['councilId']?.toString(),
        locationId: json['locationId']?.toString(),
        isActive: json['isActive']?.toString().toLowerCase() == 'true',
        lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
        loginAttempts: int.tryParse(json['loginAttempts']?.toString() ?? '0') ?? 0,
        activityLog: activityLog,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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