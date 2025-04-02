import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';
import 'package:upstash_redis/upstash_redis.dart';

class AuthService {
  final Redis _redis;
  User? _currentUser;
  String? _authToken;

  AuthService(this._redis);

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    final userJson = await _redis.get('user:$email');
    if (userJson == null) {
      throw Exception('User not found');
    }

    final storedPassword = await _redis.get('password:$email');
    if (storedPassword != password) {
      // Increment login attempts
      final user = User.fromJson(userJson);
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
      await _redis.set('user:$email', updatedUser.toJson());
      throw Exception('Invalid password');
    }

    final user = User.fromJson(userJson);
    if (!user.isActive) {
      throw Exception('User account is inactive');
    }

    // Reset login attempts and update last login
    final updatedUser = user.copyWith(
      loginAttempts: 0,
      lastLogin: DateTime.now(),
      activityLog: [
        ...user.activityLog,
        {
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'login_success',
          'details': 'Successful login',
        },
      ],
    );
    await _redis.set('user:$email', updatedUser.toJson());
    _currentUser = updatedUser;
    return true;
  }

  Future<void> logout() async {
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
      await _redis.set('user:${user.email}', updatedUser.toJson());
    }
    _currentUser = null;
  }

  Future<bool> checkAuth() async {
    if (_authToken == null) return false;
    
    try {
      final tokenData = await _redis.get('token:$_authToken');
      if (tokenData == null) return false;
      
      _currentUser = User.fromJson(tokenData);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    
    switch (_currentUser!.role) {
      case UserRole.systemAdmin:
        return true;
      case UserRole.municipalityAdmin:
        return permission.startsWith('municipality:');
      case UserRole.veterinaryUser:
        return permission.startsWith('veterinary:') || permission.startsWith('census:');
      case UserRole.censusUser:
        return permission.startsWith('census:');
    }
  }

  Future<List<User>> getAllUsers() async {
    final keys = await _redis.keys('user:*');
    final users = <User>[];
    
    for (final key in keys) {
      final userJson = await _redis.get(key);
      if (userJson != null) {
        users.add(User.fromJson(userJson));
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
  }) async {
    final userExists = await _redis.get('user:$email');
    if (userExists != null) {
      throw Exception('User already exists');
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
      lastLogin: DateTime.now(),
      isActive: true,
      activityLog: [
        {
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'account_created',
          'details': 'User account created by ${_currentUser?.name ?? 'system'}',
        },
      ],
    );

    await _redis.set('user:$email', user.toJson());
    await _redis.set('password:$email', password);
  }

  Future<void> updateUser(User user) async {
    final currentUserJson = await _redis.get('user:${user.email}');
    if (currentUserJson != null) {
      final currentUser = User.fromJson(currentUserJson);
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
      await _redis.set('user:${user.email}', updatedUser.toJson());
    } else {
      await _redis.set('user:${user.email}', user.toJson());
    }
  }

  Future<void> updatePassword(String email, String newPassword) async {
    final userJson = await _redis.get('user:$email');
    if (userJson != null) {
      final user = User.fromJson(userJson);
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
      await _redis.set('user:$email', updatedUser.toJson());
    }
    await _redis.set('password:$email', newPassword);
  }

  Future<void> toggleUserStatus(String email, bool isActive) async {
    final userJson = await _redis.get('user:$email');
    if (userJson != null) {
      final user = User.fromJson(userJson);
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
      await _redis.set('user:$email', updatedUser.toJson());
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(UpstashConfig.redis);
});

final authStateProvider = StateProvider<User?>((ref) {
  return null;
}); 