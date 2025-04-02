import 'package:upstash_redis/upstash_redis.dart';
import 'dart:io';

void main() async {
  try {
    // Initialize Redis client
    final redis = Redis(
      url: Platform.environment['UPSTASH_REDIS_REST_URL'] ?? 'https://neutral-toad-19982.upstash.io',
      token: Platform.environment['UPSTASH_REDIS_REST_TOKEN'] ?? 'AU4OAAIjcDFhMzAzZjcwYzM5ZWM0NWUyYWYwMWIyODY0MGRkNWE1YnAxMA',
    );

    // Test user data
    final testUser = {
      'id': 'test1',
      'email': 'test@example.com',
      'name': 'Test User',
      'role': 'systemAdmin',
      'isActive': 'true',
      'lastLogin': DateTime.now().toIso8601String(),
      'activityLog': '[]',
    };

    // Store test user
    await redis.hset('user:test@example.com', testUser);
    await redis.set('password:test@example.com', 'oldpassword');
    print('Test user created with initial password');

    // Test password verification
    final storedPassword = await redis.get('password:test@example.com');
    print('Stored password: $storedPassword');
    print('Password verification test: ${storedPassword == 'oldpassword'}');

    // Update password
    await redis.set('password:test@example.com', 'newpassword');
    print('Password updated to newpassword');

    // Verify new password
    final newStoredPassword = await redis.get('password:test@example.com');
    print('New stored password: $newStoredPassword');
    print('New password verification test: ${newStoredPassword == 'newpassword'}');

    // Clean up
    await redis.del(['user:test@example.com', 'password:test@example.com']);
    print('Test data cleaned up');

  } catch (e) {
    print('Error during test: $e');
  }
} 