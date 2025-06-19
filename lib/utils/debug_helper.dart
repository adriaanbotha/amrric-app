import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/animal.dart';

class DebugHelper {
  static Future<void> printAllAnimals() async {
    try {
      debugPrint('=== DEBUG: Checking all animals in database ===');
      final keys = await UpstashConfig.redis.keys('animal:*');
      debugPrint('Found ${keys.length} animal keys');
      
      for (final key in keys) {
        try {
          final data = await UpstashConfig.redis.hgetall(key);
          if (data != null && data.isNotEmpty) {
            final name = data['name'] ?? 'Unnamed';
            final houseId = data['houseId'] ?? 'No house';
            final species = data['species'] ?? 'Unknown';
            debugPrint('Animal: $key - Name: $name, Species: $species, HouseId: $houseId');
          }
        } catch (e) {
          debugPrint('Error reading animal $key: $e');
        }
      }
      debugPrint('=== END DEBUG ===');
    } catch (e) {
      debugPrint('Error in debug helper: $e');
    }
  }
  
  static Future<void> printAnimalsWithDefaultHouse() async {
    try {
      debugPrint('=== DEBUG: Checking animals with default house ===');
      final keys = await UpstashConfig.redis.keys('animal:*');
      
      for (final key in keys) {
        try {
          final data = await UpstashConfig.redis.hgetall(key);
          if (data != null && data['houseId'] == 'default') {
            final name = data['name'] ?? 'Unnamed';
            final species = data['species'] ?? 'Unknown';
            debugPrint('Found animal with default house: $key - Name: $name, Species: $species');
          }
        } catch (e) {
          debugPrint('Error reading animal $key: $e');
        }
      }
      debugPrint('=== END DEBUG ===');
    } catch (e) {
      debugPrint('Error in debug helper: $e');
    }
  }
  
  static Future<void> cleanupAnimalsWithDefaultHouse() async {
    try {
      debugPrint('=== CLEANUP: Removing animals with default house ===');
      final keys = await UpstashConfig.redis.keys('animal:*');
      int deletedCount = 0;
      
      for (final key in keys) {
        try {
          final data = await UpstashConfig.redis.hgetall(key);
          if (data != null && data['houseId'] == 'default') {
            final name = data['name'] ?? 'Unnamed';
            final species = data['species'] ?? 'Unknown';
            final animalId = key.replaceFirst('animal:', '');
            
            debugPrint('Deleting animal with default house: $key - Name: $name, Species: $species');
            
            // Delete the animal data
            await UpstashConfig.redis.del([key]);
            
            // Remove from indexes
            await UpstashConfig.redis.srem('animals', [animalId]);
            await UpstashConfig.redis.srem('animals:all', [animalId]);
            await UpstashConfig.redis.srem('animals:house:default', [animalId]);
            
            deletedCount++;
          }
        } catch (e) {
          debugPrint('Error deleting animal $key: $e');
        }
      }
      
      debugPrint('Cleanup completed. Deleted $deletedCount animals with default house.');
      debugPrint('=== END CLEANUP ===');
    } catch (e) {
      debugPrint('Error in cleanup: $e');
    }
  }
} 