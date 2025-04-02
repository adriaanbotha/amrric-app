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

  static Future<void> initialize() async {
    if (_redis != null) {
      print('Redis already initialized');
      return;
    }

    final url = dotenv.env['UPSTASH_REDIS_REST_URL'];
    final token = dotenv.env['UPSTASH_REDIS_REST_TOKEN'];

    print('Initializing Redis with URL: $url');

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
      print('Redis ping result: $result');

      // Test getting councils
      final councilKeys = await _redis!.keys('council:*');
      print('Found ${councilKeys.length} council keys: $councilKeys');

      print('Successfully connected to Upstash Redis');
    } catch (e, stackTrace) {
      print('Error connecting to Redis: $e');
      print('Stack trace: $stackTrace');
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
      print('Found ${keys.length} keys to delete');

      // Delete all keys in batches
      if (keys.isNotEmpty) {
        for (var i = 0; i < keys.length; i += 100) {
          final batch = keys.skip(i).take(100).toList();
          await _redis!.del(batch);
          print('Deleted keys ${i + 1} to ${i + batch.length}');
        }
      }

      print('Successfully cleared all Redis keys');
    } catch (e, stackTrace) {
      print('Error resetting Redis: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 