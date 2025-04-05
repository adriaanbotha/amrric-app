import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'package:flutter/foundation.dart';
import '../models/council.dart';
import '../config/upstash_config.dart';
import 'dart:convert';

final councilsProvider = StateNotifierProvider<CouncilService, AsyncValue<List<Council>>>((ref) {
  return CouncilService();
});

class CouncilService extends StateNotifier<AsyncValue<List<Council>>> {
  final Redis _redis = UpstashConfig.redis;

  CouncilService() : super(const AsyncValue.loading()) {
    loadCouncils();
  }

  Future<void> loadCouncils() async {
    try {
      debugPrint('Loading councils...');
      state = const AsyncValue.loading();
      final councils = await getCouncils();
      debugPrint('Loaded ${councils.length} councils');
      state = AsyncValue.data(councils);
    } catch (e, stack) {
      debugPrint('Error loading councils: $e');
      debugPrint('Stack trace: $stack');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCouncil(Council council) async {
    try {
      debugPrint('Adding council: ${council.name}');
      if (!council.validate()) {
        throw Exception('Invalid council data');
      }

      final data = council.toJson();
      final redisData = data.map((key, value) {
        if (value == null) {
          return MapEntry(key, '');
        } else if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        } else if (value is bool) {
          return MapEntry(key, value.toString());
        } else if (value is List || value is Map) {
          return MapEntry(key, jsonEncode(value));
        } else {
          return MapEntry(key, value.toString());
        }
      });
      
      debugPrint('Redis data to store: $redisData');
      await _redis.hset('council:${council.id}', redisData);
      await _redis.sadd('councils', [council.id]);
      
      // Initialize empty locations set for the council
      final locationsKey = 'council:${council.id}:locations';
      await _redis.del([locationsKey]);
      await _redis.sadd(locationsKey, []);
      
      debugPrint('Council added successfully');
      await loadCouncils();
    } catch (e) {
      debugPrint('Error adding council: $e');
      rethrow;
    }
  }

  Future<void> updateCouncil(Council council) async {
    try {
      debugPrint('Updating council: ${council.name}');
      if (!council.validate()) {
        throw Exception('Invalid council data');
      }

      final data = council.toJson();
      final redisData = data.map((key, value) {
        if (value == null) {
          return MapEntry(key, '');
        } else if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        } else if (value is bool) {
          return MapEntry(key, value.toString());
        } else if (value is List || value is Map) {
          return MapEntry(key, jsonEncode(value));
        } else {
          return MapEntry(key, value.toString());
        }
      });
      
      debugPrint('Redis data to update: $redisData');
      await _redis.hset('council:${council.id}', redisData);
      debugPrint('Council updated successfully');
      await loadCouncils();
    } catch (e) {
      debugPrint('Error updating council: $e');
      rethrow;
    }
  }

  Future<void> deleteCouncil(String id) async {
    try {
      debugPrint('Deleting council: $id');
      // Delete the council data
      await _redis.del(['council:$id']);
      // Delete the council from the councils set
      await _redis.srem('councils', [id]);
      // Delete the council's locations set
      await _redis.del(['council:$id:locations']);
      debugPrint('Council deleted successfully');
      await loadCouncils();
    } catch (e) {
      debugPrint('Error deleting council: $e');
      rethrow;
    }
  }

  Future<List<Council>> getCouncils() async {
    try {
      debugPrint('Getting all councils');
      final keys = await _redis.keys('council:*');
      final councils = <Council>[];

      for (final key in keys) {
        if (!key.startsWith('council:') || key.contains(':locations')) continue;
        
        final data = await _redis.hgetall(key);
        if (data != null && data.isNotEmpty) {
          debugPrint('Council data from Redis: $data');
          // Convert Redis string values to appropriate types
          final jsonData = <String, dynamic>{};
          data.forEach((key, value) {
            if (value == null || value.toString().isEmpty) {
              jsonData[key] = null;
            } else if (key == 'isActive') {
              jsonData[key] = value.toString().toLowerCase() == 'true';
            } else if (key == 'createdAt' || key == 'updatedAt') {
              try {
                final dateStr = value.toString();
                jsonData[key] = dateStr;
              } catch (e) {
                debugPrint('Error parsing date for $key: $e');
                jsonData[key] = null;
              }
            } else {
              jsonData[key] = value;
            }
          });
          
          debugPrint('Creating Council from JSON: $jsonData');
          try {
            councils.add(Council.fromJson(jsonData));
          } catch (e) {
            debugPrint('Error creating Council from JSON: $e');
            debugPrint('Stack trace: ${StackTrace.current}');
          }
        }
      }

      debugPrint('Retrieved ${councils.length} councils');
      return councils;
    } catch (e) {
      debugPrint('Error getting councils: $e');
      rethrow;
    }
  }

  Future<Council?> getCouncil(String id) async {
    try {
      debugPrint('Getting council: $id');
      final data = await _redis.hgetall('council:$id');
      if (data == null || data.isEmpty) {
        debugPrint('Council not found');
        return null;
      }
      debugPrint('Council data from Redis: $data');
      
      // Convert Redis string values to appropriate types
      final jsonData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value == null || value.toString().isEmpty) {
          jsonData[key] = null;
        } else if (key == 'isActive') {
          jsonData[key] = value.toString().toLowerCase() == 'true';
        } else if (key == 'createdAt' || key == 'updatedAt') {
          try {
            jsonData[key] = DateTime.parse(value.toString());
          } catch (e) {
            debugPrint('Error parsing date for $key: $e');
            jsonData[key] = null;
          }
        } else {
          jsonData[key] = value;
        }
      });
      
      // Ensure locations set exists
      final locationsKey = 'council:$id:locations';
      final type = await _redis.type(locationsKey);
      if (type != 'set') {
        debugPrint('Key $locationsKey is not a set, recreating as empty set');
        await _redis.del([locationsKey]);
        await _redis.sadd(locationsKey, []);
      }
      
      return Council.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error getting council: $e');
      rethrow;
    }
  }

  Future<List<String>> getCouncilLocations(String councilId) async {
    try {
      debugPrint('Getting locations for council: $councilId');
      final locationsKey = 'council:$councilId:locations';
      
      // Check if the key exists and is a set
      final type = await _redis.type(locationsKey);
      if (type != 'set') {
        debugPrint('Key $locationsKey is not a set, recreating as empty set');
        await _redis.del([locationsKey]);
        await _redis.sadd(locationsKey, []);
        return [];
      }
      
      // Get all members of the set
      final members = await _redis.smembers(locationsKey);
      if (members == null) {
        debugPrint('No locations found for council $councilId');
        return [];
      }
      
      // Convert members to List<String>
      final locations = members.map((member) => member.toString()).toList();
      debugPrint('Retrieved ${locations.length} locations for council $councilId');
      return locations;
    } catch (e) {
      debugPrint('Error getting council locations: $e');
      return []; // Return empty list instead of rethrowing to prevent app crashes
    }
  }

  Future<void> addLocationToCouncil(String councilId, String locationId) async {
    try {
      debugPrint('Adding location $locationId to council $councilId');
      final key = 'council:$councilId:locations';
      
      // First check if the key exists and is a set
      final type = await _redis.type(key);
      if (type != 'set') {
        debugPrint('Key $key is not a set, recreating as empty set');
        await _redis.del([key]);
        await _redis.sadd(key, []);
      }
      
      // Add the location to the set
      await _redis.sadd(key, [locationId]);
      debugPrint('Location $locationId added to council $councilId');
    } catch (e) {
      debugPrint('Error adding location to council: $e');
      rethrow;
    }
  }

  Future<void> removeLocationFromCouncil(String councilId, String locationId) async {
    try {
      debugPrint('Removing location $locationId from council $councilId');
      final key = 'council:$councilId:locations';
      
      // First check if the key exists and is a set
      final type = await _redis.type(key);
      if (type != 'set') {
        debugPrint('Key $key is not a set, recreating as empty set');
        await _redis.del([key]);
        await _redis.sadd(key, []);
        return;
      }
      
      // Remove the location from the set
      await _redis.srem(key, [locationId]);
      debugPrint('Location $locationId removed from council $councilId');
    } catch (e) {
      debugPrint('Error removing location from council: $e');
      rethrow;
    }
  }

  Future<List<Council>> searchCouncils(String query) async {
    debugPrint('Searching councils with query: $query');
    final councils = await getCouncils();
    final lowercaseQuery = query.toLowerCase();
    
    return councils.where((council) {
      return council.name.toLowerCase().contains(lowercaseQuery) ||
             council.state.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> toggleCouncilStatus(String id) async {
    try {
      debugPrint('Toggling council status: $id');
      final council = await getCouncil(id);
      if (council == null) {
        throw Exception('Council not found');
      }

      final updatedCouncil = council.copyWith(
        isActive: !council.isActive,
        updatedAt: DateTime.now(),
      );

      await updateCouncil(updatedCouncil);
      debugPrint('Council status toggled successfully');
    } catch (e) {
      debugPrint('Error toggling council status: $e');
      rethrow;
    }
  }

  Future<void> repairCouncilData() async {
    try {
      debugPrint('Starting council data repair...');
      final keys = await _redis.keys('council:*');
      
      for (final key in keys) {
        if (!key.startsWith('council:') || key.contains(':locations')) continue;
        
        final councilId = key.replaceAll('council:', '');
        final locationsKey = 'council:$councilId:locations';
        
        // Check and fix the locations set
        final type = await _redis.type(locationsKey);
        if (type != 'set') {
          debugPrint('Repairing locations set for council $councilId');
          await _redis.del([locationsKey]);
          // Initialize with a dummy value and then remove it to create an empty set
          await _redis.sadd(locationsKey, ['dummy']);
          await _redis.srem(locationsKey, ['dummy']);
        }
        
        // Ensure council is in the councils set
        final isMember = await _redis.sismember('councils', councilId);
        if (isMember == 0) {  // 0 means not a member
          debugPrint('Adding council $councilId to councils set');
          await _redis.sadd('councils', [councilId]);
        }
      }
      
      debugPrint('Council data repair completed');
    } catch (e) {
      debugPrint('Error repairing council data: $e');
      rethrow;
    }
  }
} 