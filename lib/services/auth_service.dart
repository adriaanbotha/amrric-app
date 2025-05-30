import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  User? _currentUser;

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= _maxRetries) {
          debugPrint('Operation failed after $_maxRetries attempts: $e');
          rethrow;
        }
        debugPrint('Operation failed, attempt $attempts of $_maxRetries: $e');
        await Future.delayed(_retryDelay * attempts);
      }
    }
  }

  Future<void> setLastLoggedInEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_logged_in_email', email);
  }

  Future<String?> getLastLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_logged_in_email');
  }

  Future<void> clearLastLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_logged_in_email');
  }

  Future<User?> getCurrentUser() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Try Upstash first
        try {
          final userHash = await UpstashConfig.redis.hgetall(_currentUserKey);
          if (userHash != null && userHash.isNotEmpty) {
            _currentUser = User.fromJson(userHash.map((key, value) => MapEntry(key, value.toString())));
            return _currentUser;
          }
          final userJson = await UpstashConfig.redis.get(_currentUserKey);
          if (userJson != null) {
            final user = User.fromJson(json.decode(userJson));
            await setCurrentUser(user);
            return user;
          }
        } catch (e) {
          debugPrint('Online getCurrentUser failed, falling back to offline: $e');
          // Fallback to offline
        }
      }

      // Offline or Upstash failed: get from Hive
      final userBox = await Hive.openBox<User>('users');
      final lastEmail = await getLastLoggedInEmail();
      if (lastEmail != null) {
        final user = userBox.get(lastEmail);
        _currentUser = user;
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      _currentUser = null;
      return null;
    }
  }

  User? get currentUser => _currentUser;

  Future<void> setCurrentUser(User user) async {
    await _withRetry(() async {
      try {
        // Delete any existing data first
        await UpstashConfig.redis.del([_currentUserKey]);
        
        // Store in new hash format
        final userData = user.toJson();
        final redisData = userData.map((key, value) {
          if (value is List) {
            return MapEntry(key, jsonEncode(value));
          } else {
            return MapEntry(key, value?.toString() ?? '');
          }
        });
        await UpstashConfig.redis.hset(_currentUserKey, redisData);
        _currentUser = user;
      } catch (e) {
        debugPrint('Error setting current user: $e');
        rethrow;
      }
    });
  }

  Future<void> logout() async {
    await _withRetry(() async {
      try {
        await UpstashConfig.redis.del([_currentUserKey]);
        _currentUser = null;
        // Do not clear authStateProvider here; handle it in the UI after logout.
      } catch (e) {
        debugPrint('Error logging out: $e');
        rethrow;
      }
    });
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<User?> login(String email, String password) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        try {
          // Online: Try Upstash
          final userData = await UpstashConfig.redis.hgetall('user:$email');
          if (userData == null || userData.isEmpty) {
            debugPrint('No user data found for email: $email');
            return null;
          }
          final storedPassword = await UpstashConfig.redis.get('password:$email');
          if (storedPassword != password) {
            debugPrint('Invalid password for email: $email');
            return null;
          }
          final user = User.fromJson(userData.map((key, value) => MapEntry(key, value.toString())));
          final updatedUser = user.copyWith(
            lastLogin: DateTime.now(),
            activityLog: [
              ...user.activityLog,
              {
                'timestamp': DateTime.now().toIso8601String(),
                'action': 'login',
                'details': 'User logged in successfully',
              },
            ],
            localPasswordHash: hashPassword(password),
          );
          await updateUser(updatedUser);
          await setCurrentUser(updatedUser);
          final userBox = await Hive.openBox<User>('users');
          await userBox.put(email, updatedUser);
          await setLastLoggedInEmail(email);
          return updatedUser;
        } catch (e) {
          debugPrint('Online login failed, falling back to offline: $e');
          // Fallback to offline
        }
      }

      // Offline: Check local storage
      final userBox = await Hive.openBox<User>('users');
      final user = userBox.get(email);
      if (user == null) {
        throw Exception('Offline login not allowed. Please log in online first.');
      }
      if (user.localPasswordHash != hashPassword(password)) {
        throw Exception('Incorrect password for offline login.');
      }
      await setLastLoggedInEmail(email);
      return user;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  bool hasPermission(String permission) {
    // This method should be refactored to be async if you want to check the current user from Redis
    // For now, always return true (or implement a different logic as needed)
    return true;
  }

  Future<List<User>> getAllUsers() async {
    final keys = await UpstashConfig.redis.keys('user:*');
    final users = <User>[];
    
    for (final key in keys) {
      final userJson = await UpstashConfig.redis.hgetall(key);
      if (userJson != null && userJson.isNotEmpty) {
        users.add(User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString()))));
      }
    }
    
    return users;
  }

  Future<void> deleteUser(String email) async {
    await UpstashConfig.redis.del(['user:$email', 'password:$email']);
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? councilId,
    String? municipalityId,
  }) async {
    final userExists = await UpstashConfig.redis.hgetall('user:$email');
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
          'details': 'User account created by system',
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
    
    await UpstashConfig.redis.hset('user:$email', redisData);
    await UpstashConfig.redis.set('password:$email', password);
  }

  Future<void> updateUser(User user) async {
    final currentUserJson = await UpstashConfig.redis.hgetall('user:${user.email}');
    if (currentUserJson != null && currentUserJson.isNotEmpty) {
      final currentUser = User.fromJson(currentUserJson.map((key, value) => MapEntry(key, value.toString())));
      final updatedUser = user.copyWith(
        activityLog: [
          ...currentUser.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': 'profile_updated',
            'details': 'User profile updated by system',
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
      await UpstashConfig.redis.hset('user:${user.email}', redisData);
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
      await UpstashConfig.redis.hset('user:${user.email}', redisData);
    }
  }

  Future<void> updatePassword(String email, String newPassword) async {
    debugPrint('Updating password for user: $email');
    final userJson = await UpstashConfig.redis.hgetall('user:$email');
    if (userJson != null && userJson.isNotEmpty) {
      final user = User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString())));
      final updatedUser = user.copyWith(
        activityLog: [
          ...user.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': 'password_changed',
            'details': 'Password changed by system',
          },
        ],
      );
      final userData = updatedUser.toJson();
      await UpstashConfig.redis.hset('user:$email', userData.map((key, value) => MapEntry(key, value.toString())));
    }
    await UpstashConfig.redis.set('password:$email', newPassword);
    debugPrint('Password updated successfully for user: $email');
  }

  Future<bool> verifyPassword(String email, String password) async {
    debugPrint('Verifying password for user: $email');
    final storedPassword = await UpstashConfig.redis.get('password:$email');
    final isValid = storedPassword == password;
    debugPrint('Password verification result: $isValid');
    return isValid;
  }

  Future<void> toggleUserStatus(String email, bool isActive) async {
    final userJson = await UpstashConfig.redis.hgetall('user:$email');
    if (userJson != null && userJson.isNotEmpty) {
      final user = User.fromJson(userJson.map((key, value) => MapEntry(key, value.toString())));
      final updatedUser = user.copyWith(
        isActive: isActive,
        activityLog: [
          ...user.activityLog,
          {
            'timestamp': DateTime.now().toIso8601String(),
            'action': isActive ? 'account_activated' : 'account_deactivated',
            'details': 'Account ${isActive ? 'activated' : 'deactivated'} by system',
          },
        ],
      );
      final userData = updatedUser.toJson();
      await UpstashConfig.redis.hset('user:$email', userData.map((key, value) => MapEntry(key, value.toString())));
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StateProvider<User?>((ref) {
  return null;
}); 