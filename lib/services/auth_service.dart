import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';
import 'package:upstash_redis/upstash_redis.dart';

class AuthService {
  final Redis _redis;
  User? _currentUser;
  String? _authToken;

  AuthService(this._redis) {
    debugPrint('AuthService initialized');
  }

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    debugPrint('Attempting login for email: $email');
    
    try {
      final userJson = await _redis.hgetall('user:$email');
      debugPrint('Retrieved user data: $userJson');
      
      if (userJson == null || userJson.isEmpty) {
        debugPrint('User not found: $email');
        throw Exception('User not found');
      }

      final storedPassword = await _redis.get('password:$email');
      debugPrint('Retrieved stored password for comparison');
      
      if (storedPassword != password) {
        debugPrint('Invalid password attempt for user: $email');
        // Increment login attempts
        final user = User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString())));
        final updatedUser = user.copyWith(
          loginAttempts: user.loginAttempts + 1,
          activityLog: [
            ...user.activityLog,
            {
              'timestamp': DateTime.now().toIso8601String(),
              'action': 'login_failed',
              'details': 'Invalid password attempt',
            },
          ],
        );
        final userData = updatedUser.toJson();
        await _redis.hset('user:$email', userData.map((key, value) => MapEntry(key, value.toString())));
        throw Exception('Invalid password');
      }

      // Reset login attempts on successful login
      final user = User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString())));
      final updatedUser = user.copyWith(
        loginAttempts: 0,
        lastLogin: DateTime.now(),
        activityLog: [
          ...user.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': 'login_success',
            'details': 'User logged in successfully',
          },
        ],
      );
      final userData = updatedUser.toJson();
      await _redis.hset('user:$email', userData.map((key, value) => MapEntry(key, value.toString())));

      _currentUser = updatedUser;
      _authToken = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      await _redis.set('current:user', email);
      debugPrint('Login successful for user: $email');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Login error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('Logging out user: ${_currentUser?.email}');
    if (_currentUser != null) {
      final user = _currentUser!;
      final updatedUser = user.copyWith(
        activityLog: [
          ...user.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': 'logout',
            'details': 'User logged out',
          },
        ],
      );
      final userData = updatedUser.toJson();
      await _redis.hset('user:${user.email}', userData.map((key, value) => MapEntry(key, value.toString())));
      await _redis.del(['current:user']);
    }
    _currentUser = null;
    debugPrint('Logout complete');
  }

  Future<bool> checkAuth() async {
    debugPrint('Checking authentication status');
    if (_authToken == null) return false;
    
    try {
      final tokenData = await _redis.hgetall('token:$_authToken');
      debugPrint('Retrieved token data: $tokenData');
      
      if (tokenData == null || tokenData.isEmpty) return false;
      
      _currentUser = User.fromJson(tokenData.map((key, value) => MapEntry(key, value.toString())));
      debugPrint('Authentication successful for user: ${_currentUser?.email}');
      return true;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    
    switch (_currentUser!.role) {
      case UserRole.systemAdmin:
        return true;  // System admin has all permissions
      case UserRole.municipalityAdmin:
        return permission.startsWith('municipality:') ||
               permission.startsWith('animal:view') ||
               permission.startsWith('animal:edit') ||
               permission.startsWith('animal:validate');
      case UserRole.veterinaryUser:
        return permission.startsWith('veterinary:') ||
               permission.startsWith('animal:') ||  // Full animal management access
               permission.startsWith('medical:');   // Medical record access
      case UserRole.censusUser:
        return permission.startsWith('census:') ||
               permission.startsWith('animal:basic:');  // Basic animal operations only
    }
  }

  Future<List<User>> getAllUsers() async {
    final keys = await _redis.keys('user:*');
    final users = <User>[];
    
    for (final key in keys) {
      final userJson = await _redis.hgetall(key);
      if (userJson != null && userJson.isNotEmpty) {
        users.add(User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString()))));
      }
    }
    
    return users;
  }

  Future<void> deleteUser(String email) async {
    await _redis.del(['user:$email', 'password:$email']);
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? councilId,
    String? municipalityId,
  }) async {
    final userExists = await _redis.hgetall('user:$email');
    if (userExists != null && userExists.isNotEmpty) {
      throw Exception('User already exists');
    }

    final now = DateTime.now();
    final user = User(
      id: now.millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
      lastLogin: now,
      isActive: true,
      councilId: councilId,
      municipalityId: municipalityId,
      createdAt: now,
      updatedAt: now,
      activityLog: [
        {
          'timestamp': now.toIso8601String(),
          'action': 'account_created',
          'details': 'User account created by ${_currentUser?.name ?? 'system'}',
        },
      ],
    );

    final userData = user.toJson();
    // Convert all values to strings for Redis, ensuring proper JSON encoding for lists
    final redisData = userData.map((key, value) {
      if (value is List) {
        return MapEntry(key, jsonEncode(value));
      } else {
        return MapEntry(key, value?.toString() ?? '');
      }
    });
    
    await _redis.hset('user:$email', redisData);
    await _redis.set('password:$email', password);
  }

  Future<void> updateUser(User user) async {
    final currentUserJson = await _redis.hgetall('user:${user.email}');
    if (currentUserJson != null && currentUserJson.isNotEmpty) {
      final currentUser = User.fromJson(currentUserJson.map((key, value) => MapEntry(key, value.toString())));
      final updatedUser = user.copyWith(
        activityLog: [
          ...currentUser.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': 'profile_updated',
            'details': 'User profile updated by ${_currentUser?.name ?? 'system'}',
          },
        ],
      );
      final userData = updatedUser.toJson();
      // Convert all values to strings for Redis, ensuring proper JSON encoding for lists
      final redisData = userData.map((key, value) {
        if (value is List) {
          return MapEntry(key, jsonEncode(value));
        } else {
          return MapEntry(key, value?.toString() ?? '');
        }
      });
      await _redis.hset('user:${user.email}', redisData);
    } else {
      final userData = user.toJson();
      // Convert all values to strings for Redis, ensuring proper JSON encoding for lists
      final redisData = userData.map((key, value) {
        if (value is List) {
          return MapEntry(key, jsonEncode(value));
        } else {
          return MapEntry(key, value?.toString() ?? '');
        }
      });
      await _redis.hset('user:${user.email}', redisData);
    }
  }

  Future<void> updatePassword(String email, String newPassword) async {
    debugPrint('Updating password for user: $email');
    final userJson = await _redis.hgetall('user:$email');
    if (userJson != null && userJson.isNotEmpty) {
      final user = User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString())));
      final updatedUser = user.copyWith(
        activityLog: [
          ...user.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': 'password_changed',
            'details': 'Password changed by ${_currentUser?.name ?? 'system'}',
          },
        ],
      );
      final userData = updatedUser.toJson();
      await _redis.hset('user:$email', userData.map((key, value) => MapEntry(key, value.toString())));
    }
    await _redis.set('password:$email', newPassword);
    debugPrint('Password updated successfully for user: $email');
  }

  Future<bool> verifyPassword(String email, String password) async {
    debugPrint('Verifying password for user: $email');
    final storedPassword = await _redis.get('password:$email');
    final isValid = storedPassword == password;
    debugPrint('Password verification result: $isValid');
    return isValid;
  }

  Future<void> toggleUserStatus(String email, bool isActive) async {
    final userJson = await _redis.hgetall('user:$email');
    if (userJson != null && userJson.isNotEmpty) {
      final user = User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString())));
      final updatedUser = user.copyWith(
        isActive: isActive,
        activityLog: [
          ...user.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': isActive ? 'account_activated' : 'account_deactivated',
            'details': 'Account ${isActive ? 'activated' : 'deactivated'} by ${_currentUser?.name ?? 'system'}',
          },
        ],
      );
      final userData = updatedUser.toJson();
      await _redis.hset('user:$email', userData.map((key, value) => MapEntry(key, value.toString())));
    }
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final email = await _redis.get('current:user');
    if (email == null) return null;

    final userData = await _redis.hgetall('user:$email');
    if (userData == null || userData.isEmpty) return null;

    return User.fromJson(userData.map((key, value) => MapEntry(key, value.toString())));
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(UpstashConfig.redis);
});

final authStateProvider = StateProvider<User?>((ref) {
  return null;
}); 