import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upstash_redis/upstash_redis.dart';

class UpstashConfig {
  static Redis? _redis;

  static Redis get redis {
    if (_redis == null) {
      throw Exception('Redis not initialized. Call initialize() first.');
    }
    return _redis!;
  }

  static Future<Redis> initialize() async {
    if (_redis != null) {
      debugPrint('Redis already initialized');
      return _redis!;
    }

    final url = dotenv.env['UPSTASH_REDIS_REST_URL'];
    final token = dotenv.env['UPSTASH_REDIS_REST_TOKEN'];

    debugPrint('Initializing Redis with URL: $url');

    if (url == null || token == null) {
      throw Exception('Missing Upstash Redis configuration. Please check your .env file.');
    }

    try {
      _redis = Redis(
        url: url,
        token: token,
      );

      // Test the connection
      final result = await _redis!.ping();
      debugPrint('Redis ping result: $result');
      debugPrint('Successfully connected to Upstash Redis');
      return _redis!;
    } catch (e, stackTrace) {
      debugPrint('Error connecting to Redis: $e');
      debugPrint('Stack trace: $stackTrace');
      _redis = null;
      rethrow;
    }
  }

  static Future<void> reset() async {
    if (_redis == null) {
      throw Exception('Redis not initialized. Call initialize() first.');
    }

    try {
      // Get all keys
      final keys = await _redis!.keys('*');
      debugPrint('Found ${keys.length} keys to delete');

      // Delete all keys in batches
      if (keys.isNotEmpty) {
        for (var i = 0; i < keys.length; i += 100) {
          final batch = keys.skip(i).take(100).toList();
          await _redis!.del(batch);
          debugPrint('Deleted keys ${i + 1} to ${i + batch.length}');
        }
      }

      debugPrint('Successfully cleared all Redis keys');
    } catch (e, stackTrace) {
      debugPrint('Error resetting Redis: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Helper methods for common Redis operations
  static Future<String?> get(String key) async {
    try {
      return await redis.get(key);
    } catch (e) {
      debugPrint('Error getting key $key: $e');
      return null;
    }
  }

  static Future<void> set(String key, String value) async {
    try {
      await redis.set(key, value);
    } catch (e) {
      debugPrint('Error setting key $key: $e');
      rethrow;
    }
  }

  static Future<void> delete(String key) async {
    try {
      await redis.del([key]);
    } catch (e) {
      debugPrint('Error deleting key $key: $e');
      rethrow;
    }
  }

  static Future<List<String>> keys(String pattern) async {
    try {
      final result = await redis.keys(pattern);
      return result.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('Error getting keys with pattern $pattern: $e');
      return [];
    }
  }
} 