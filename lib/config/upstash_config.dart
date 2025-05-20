import 'package:upstash_redis/upstash_redis.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class UpstashConfig {
  static late final Redis redis;

  static Future<void> initialize() async {
    await dotenv.load();
    final endpoint = dotenv.env['UPSTASH_REDIS_URL'] ?? '';
    final token = dotenv.env['UPSTASH_REDIS_TOKEN'] ?? '';
    if (endpoint.isEmpty || token.isEmpty) {
      throw Exception('UPSTASH_REDIS_URL and UPSTASH_REDIS_TOKEN must be set in .env file');
    }
    redis = Redis(
      url: endpoint,
      token: token,
    );
  }

  static Future<void> reset() async {
    try {
      debugPrint('Starting Upstash data reset...');
      
      // Get all keys
      final keys = await redis.keys('*');
      debugPrint('Found ${keys.length} keys to delete');
      
      // Delete all keys if any exist
      if (keys.isNotEmpty) {
        await redis.del(keys);
        debugPrint('Successfully deleted all keys');
      } else {
        debugPrint('No keys found to delete');
      }

      // Verify deletion
      final remainingKeys = await redis.keys('*');
      if (remainingKeys.isNotEmpty) {
        throw Exception('Failed to delete all keys. ${remainingKeys.length} keys remain.');
      }
      
      debugPrint('Upstash data reset completed successfully');
    } catch (e) {
      debugPrint('Error during Upstash reset: $e');
      throw Exception('Failed to reset Upstash data: $e');
    }
  }

  static Future<bool> verifyConnection() async {
    try {
      await redis.ping();
      return true;
    } catch (e) {
      debugPrint('Error verifying Upstash connection: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDataStats() async {
    try {
      final keys = await redis.keys('*');
      final stats = <String, int>{};
      
      for (final key in keys) {
        final type = await redis.type(key);
        stats[type.toString()] = (stats[type.toString()] ?? 0) + 1;
      }
      
      return {
        'total_keys': keys.length,
        'key_types': stats,
      };
    } catch (e) {
      debugPrint('Error getting Upstash stats: $e');
      rethrow;
    }
  }
} 