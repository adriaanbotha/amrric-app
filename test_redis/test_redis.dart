import 'dart:io';
import 'package:upstash_redis/upstash_redis.dart';

void main() async {
  try {
    // Initialize Redis client
    final redis = Redis(
      url: Platform.environment['UPSTASH_REDIS_REST_URL'] ?? 'https://neutral-toad-19982.upstash.io',
      token: Platform.environment['UPSTASH_REDIS_REST_TOKEN'] ?? 'AU4OAAIjcDFhMzAzZjcwYzM5ZWM0NWUyYWYwMWIyODY0MGRkNWE1YnAxMA',
    );
    
    // Test council data
    final councilData = {
      'id': 'test1',
      'name': 'Test Council',
      'state': 'NSW',
      'imageUrl': 'https://example.com/image.jpg',
      'isActive': 'true',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Store council data
    await redis.hset('council:test1', councilData);
    print('Successfully stored council data');

    // Retrieve council data
    final retrievedData = await redis.hgetall('council:test1');
    print('Retrieved council data: $retrievedData');

    // Clean up
    await redis.del(['council:test1']);
    print('Test completed successfully');
  } catch (e) {
    print('Error during test: $e');
  }
} 