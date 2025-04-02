import 'package:upstash_redis/upstash_redis.dart';

class UpstashConfig {
  static const String url = String.fromEnvironment('UPSTASH_REDIS_URL');
  static const String token = String.fromEnvironment('UPSTASH_REDIS_TOKEN');

  static late final Redis redis;

  static Future<void> initialize() async {
    redis = Redis(
      url: url,
      token: token,
    );
  }

  // Helper methods for common Redis operations
  static Future<String?> get(String key) async {
    try {
      return await redis.get(key);
    } catch (e) {
      print('Error getting key $key: $e');
      return null;
    }
  }

  static Future<void> set(String key, String value) async {
    try {
      await redis.set(key, value);
    } catch (e) {
      print('Error setting key $key: $e');
    }
  }

  static Future<void> delete(String key) async {
    try {
      await redis.del([key]);
    } catch (e) {
      print('Error deleting key $key: $e');
    }
  }

  static Future<List<String>> keys(String pattern) async {
    try {
      final result = await redis.keys(pattern);
      return result.map((e) => e.toString()).toList();
    } catch (e) {
      print('Error getting keys with pattern $pattern: $e');
      return [];
    }
  }
} 