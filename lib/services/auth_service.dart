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
    try {
      // Check if user exists
      final userKey = 'user:$email';
      final userData = await _redis.get(userKey);
      
      if (userData == null) {
        throw Exception('User not found');
      }

      // Check password (for testing, password is same as email)
      final storedPassword = await _redis.get('password:$email');
      if (storedPassword != password) {
        throw Exception('Invalid password');
      }

      final user = User.fromJson(userData);
      if (!user.isActive) {
        throw Exception('User account is inactive');
      }

      // Generate and store token
      _authToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
      await _redis.set('token:$_authToken', user.toJson());

      _currentUser = user;
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    if (_authToken != null) {
      await _redis.del(['token:$_authToken']);
    }
    _currentUser = null;
    _authToken = null;
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
      case UserRole.veterinary:
        return permission.startsWith('veterinary:') || permission.startsWith('census:');
      case UserRole.normal:
        return permission.startsWith('census:');
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(UpstashConfig.redis);
});

final authStateProvider = StateProvider<User?>((ref) {
  return null;
}); 