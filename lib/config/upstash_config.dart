import 'package:upstash_redis/upstash_redis.dart';

class UpstashConfig {
  // Using direct values for development - in production, use environment variables
  static const String url = 'https://neutral-toad-19982.upstash.io';
  static const String token = 'AU4OAAIjcDFhMzAzZjcwYzM5ZWM0NWUyYWYwMWIyODY0MGRkNWE1YnAxMA';

  static late final Redis redis;

  static Future<void> initialize() async {
    try {
      redis = Redis(
        url: url,
        token: token,
      );
      
      // Test the connection
      await redis.ping();
      print('Successfully connected to Upstash Redis');
    } catch (e) {
      print('Error connecting to Upstash Redis: $e');
      rethrow;
    }
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
      rethrow;
    }
  }

  static Future<void> delete(String key) async {
    try {
      await redis.del([key]);
    } catch (e) {
      print('Error deleting key $key: $e');
      rethrow;
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