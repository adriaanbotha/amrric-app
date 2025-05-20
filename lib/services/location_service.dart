import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/location.dart';
import 'package:amrric_app/models/location_type.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:flutter/foundation.dart';

final locationsProvider = StateNotifierProvider<LocationService, AsyncValue<List<Location>>>((ref) {
  return LocationService();
});

class LocationService extends StateNotifier<AsyncValue<List<Location>>> {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  static const String _locationsKey = 'locations';

  LocationService() : super(const AsyncValue.loading()) {
    _loadLocations();
  }

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= _maxRetries) {
          debugPrint('Operation failed after $_maxRetries attempts: $e');
          rethrow;
        }
        debugPrint('Operation failed, attempt $attempts of $_maxRetries: $e');
        await Future.delayed(_retryDelay * attempts);
      }
    }
  }

  Future<void> _loadLocations() async {
    try {
      state = const AsyncValue.loading();
      final locations = await getLocations();
      state = AsyncValue.data(locations);
    } catch (e, stack) {
      debugPrint('Error loading locations: $e\n$stack');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addLocation(Location location) async {
    await _withRetry(() async {
      try {
        debugPrint('Adding location: ${location.name}');
        if (!location.validate()) {
          throw Exception('Invalid location data');
        }

        final data = location.toJson();
        debugPrint('Location data: $data');
        
        // Convert all values to strings for Redis
        final redisData = <String, String>{};
        data.forEach((key, value) {
          if (value != null) {
            if (value is Map) {
              redisData[key] = jsonEncode(value);
            } else {
              redisData[key] = value.toString();
            }
          }
        });
        
        debugPrint('Redis data: $redisData');
        await UpstashConfig.redis.hset('location:${location.id}', redisData);
        await UpstashConfig.redis.sadd('council:${location.councilId}:locations', [location.id]);
        
        // Update state immediately
        state.whenData((locations) {
          state = AsyncValue.data([...locations, location]);
        });
        debugPrint('Location added successfully');
      } catch (e, stack) {
        debugPrint('Error adding location: $e\n$stack');
        rethrow;
      }
    });
  }

  Future<void> updateLocation(Location location) async {
    await _withRetry(() async {
      try {
        debugPrint('Updating location: ${location.name}');
        if (!location.validate()) {
          throw Exception('Invalid location data');
        }

        final data = location.toJson();
        debugPrint('Location data: $data');
        
        // Convert all values to strings for Redis
        final redisData = <String, String>{};
        data.forEach((key, value) {
          if (value != null) {
            if (value is Map) {
              redisData[key] = jsonEncode(value);
            } else {
              redisData[key] = value.toString();
            }
          }
        });
        
        debugPrint('Redis data: $redisData');
        await UpstashConfig.redis.hset('location:${location.id}', redisData);
        
        // Update state immediately
        state.whenData((locations) {
          final index = locations.indexWhere((l) => l.id == location.id);
          if (index != -1) {
            final updatedLocations = List<Location>.from(locations);
            updatedLocations[index] = location;
            state = AsyncValue.data(updatedLocations);
          }
        });
        debugPrint('Location updated successfully');
      } catch (e, stack) {
        debugPrint('Error updating location: $e\n$stack');
        rethrow;
      }
    });
  }

  Future<void> deleteLocation(String id) async {
    await _withRetry(() async {
      try {
        final locations = await getLocations();
        final location = locations.firstWhere((l) => l.id == id);
        await UpstashConfig.redis.srem('council:${location.councilId}:locations', [id]);
        await UpstashConfig.redis.del(['location:$id']);
        
        // Update state immediately
        state.whenData((locations) {
          final updatedLocations = locations.where((l) => l.id != id).toList();
          state = AsyncValue.data(updatedLocations);
        });
      } catch (e) {
        debugPrint('Error deleting location: $e');
        rethrow;
      }
    });
  }

  Future<List<Location>> getLocations() async {
    return _withRetry(() async {
      try {
        debugPrint('Getting all locations');
        final keys = await UpstashConfig.redis.keys('location:*');
        debugPrint('Found ${keys.length} location keys');
        final locations = <Location>[];

        for (final key in keys) {
          try {
            final data = await UpstashConfig.redis.hgetall(key);
            debugPrint('Location data for $key: $data');
            if (data != null && data.isNotEmpty) {
              final jsonData = <String, dynamic>{};
              data.forEach((key, value) {
                if (key == 'metadata' && value != null) {
                  try {
                    jsonData[key] = jsonDecode(value);
                  } catch (e) {
                    debugPrint('Error decoding metadata: $e');
                    jsonData[key] = null;
                  }
                } else {
                  jsonData[key] = value;
                }
              });
              locations.add(Location.fromJson(jsonData));
            }
          } catch (e) {
            debugPrint('Error processing location $key: $e');
            continue;
          }
        }
        return locations;
      } catch (e, stack) {
        debugPrint('Error getting locations: $e\n$stack');
        rethrow;
      }
    });
  }

  Future<Location?> getLocation(String id) async {
    return _withRetry(() async {
      try {
        debugPrint('Getting location: $id');
        final data = await UpstashConfig.redis.hgetall('location:$id');
        if (data == null || data.isEmpty) return null;
        final jsonData = <String, dynamic>{};
        data.forEach((key, value) {
          if (key == 'metadata' && value != null) {
            try {
              jsonData[key] = jsonDecode(value);
            } catch (e) {
              debugPrint('Error decoding metadata: $e');
              jsonData[key] = null;
            }
          } else {
            jsonData[key] = value;
          }
        });
        return Location.fromJson(jsonData);
      } catch (e, stack) {
        debugPrint('Error getting location: $e\n$stack');
        rethrow;
      }
    });
  }

  Future<List<Location>> getLocationsByCouncil(String councilId) async {
    return _withRetry(() async {
      try {
        // First try to get the locations as a set
        try {
          final locationIds = await UpstashConfig.redis.smembers('council:$councilId:locations');
          final locations = <Location>[];
          for (final id in locationIds) {
            final location = await getLocation(id);
            if (location != null) {
              locations.add(location);
            }
          }
          return locations;
        } catch (e) {
          // If we get a WRONGTYPE error, we need to fix the data structure
          debugPrint('Error accessing council locations as set: $e');
          if (e.toString().contains('WRONGTYPE')) {
            await _fixCouncilLocationsStructure(councilId);
            // Retry getting locations after fixing the structure
            final locationIds = await UpstashConfig.redis.smembers('council:$councilId:locations');
            final locations = <Location>[];
            for (final id in locationIds) {
              final location = await getLocation(id);
              if (location != null) {
                locations.add(location);
              }
            }
            return locations;
          }
          rethrow;
        }
      } catch (e) {
        debugPrint('Error getting locations by council: $e');
        rethrow;
      }
    });
  }

  Future<void> _fixCouncilLocationsStructure(String councilId) async {
    try {
      // Get the old data
      final oldData = await UpstashConfig.redis.get('council:$councilId:locations');
      if (oldData != null) {
        // Parse the old data
        final List<dynamic> locations = jsonDecode(oldData);
        // Convert to new format (set)
        await UpstashConfig.redis.del(['council:$councilId:locations']);
        if (locations.isNotEmpty) {
          await UpstashConfig.redis.sadd('council:$councilId:locations', locations.map((l) => l.toString()).toList());
        }
      }
    } catch (e) {
      debugPrint('Error fixing council locations structure: $e');
      rethrow;
    }
  }

  Future<List<Location>> searchLocations(String query, {String? councilId}) async {
    try {
      final locations = councilId != null 
          ? await getLocationsByCouncil(councilId)
          : await getLocations();
      
      final lowercaseQuery = query.toLowerCase();
      return locations.where((location) {
        return location.name.toLowerCase().contains(lowercaseQuery) ||
               (location.altName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
               location.code.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('Error searching locations: $e');
      rethrow;
    }
  }

  Future<void> toggleLocationStatus(String id) async {
    try {
      final location = await getLocation(id);
      if (location == null) {
        throw Exception('Location not found');
      }

      final updatedLocation = location.copyWith(
        isActive: !location.isActive,
        updatedAt: DateTime.now(),
      );

      await updateLocation(updatedLocation);
    } catch (e) {
      print('Error toggling location status: $e');
      rethrow;
    }
  }

  Future<void> updateLocationType(String id, LocationType locationType) async {
    final location = await getLocation(id);
    if (location == null) {
      throw Exception('Location not found');
    }

    final updatedLocation = location.copyWith(
      locationTypeId: locationType,
      updatedAt: DateTime.now(),
    );

    await updateLocation(updatedLocation);
  }
} 