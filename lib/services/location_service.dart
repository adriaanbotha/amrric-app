import 'package:upstash_redis/upstash_redis.dart';
import '../models/location.dart';
import 'upstash_config.dart';

class LocationService {
  final Redis _redis;

  LocationService(this._redis);

  Future<Location> createLocation(Location location) async {
    if (!location.validate()) {
      throw Exception('Invalid location data');
    }

    // Check if code is unique within council
    final existingLocations = await getLocationsByCouncil(location.councilId);
    if (existingLocations.any((l) => l.code == location.code)) {
      throw Exception('Location code must be unique within council');
    }

    // Check if name is unique within council
    if (existingLocations.any((l) => l.name == location.name)) {
      throw Exception('Location name must be unique within council');
    }

    // Check if altName is unique within council if provided
    if (location.altName != null && 
        existingLocations.any((l) => l.altName == location.altName)) {
      throw Exception('Alternative name must be unique within council');
    }

    // Store location
    await _redis.hset(
      'location:${location.id}',
      location.toJson(),
    );

    // Add to council's location list
    await _redis.sadd('council:${location.councilId}:locations', [location.id]);

    return location;
  }

  Future<Location?> getLocation(String id) async {
    final data = await _redis.hgetall('location:$id');
    if (data == null || data.isEmpty) return null;
    return Location.fromJson(data);
  }

  Future<List<Location>> getLocationsByCouncil(String councilId) async {
    final locationIds = await _redis.smembers('council:$councilId:locations');
    final locations = <Location>[];

    for (final id in locationIds) {
      final location = await getLocation(id);
      if (location != null) {
        locations.add(location);
      }
    }

    return locations;
  }

  Future<List<Location>> searchLocations(String councilId, String query) async {
    final locations = await getLocationsByCouncil(councilId);
    final lowercaseQuery = query.toLowerCase();
    
    return locations.where((location) {
      return location.name.toLowerCase().contains(lowercaseQuery) ||
             (location.altName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             location.code.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<Location> updateLocation(Location location) async {
    if (!location.validate()) {
      throw Exception('Invalid location data');
    }

    final existingLocation = await getLocation(location.id);
    if (existingLocation == null) {
      throw Exception('Location not found');
    }

    // Check if code is unique within council if changed
    if (existingLocation.code != location.code) {
      final existingLocations = await getLocationsByCouncil(location.councilId);
      if (existingLocations.any((l) => l.code == location.code)) {
        throw Exception('Location code must be unique within council');
      }
    }

    // Check if name is unique within council if changed
    if (existingLocation.name != location.name) {
      final existingLocations = await getLocationsByCouncil(location.councilId);
      if (existingLocations.any((l) => l.name == location.name)) {
        throw Exception('Location name must be unique within council');
      }
    }

    // Check if altName is unique within council if changed
    if (existingLocation.altName != location.altName) {
      final existingLocations = await getLocationsByCouncil(location.councilId);
      if (location.altName != null && 
          existingLocations.any((l) => l.altName == location.altName)) {
        throw Exception('Alternative name must be unique within council');
      }
    }

    // Update location
    await _redis.hset(
      'location:${location.id}',
      location.toJson(),
    );

    return location;
  }

  Future<void> deleteLocation(String id) async {
    final location = await getLocation(id);
    if (location == null) {
      throw Exception('Location not found');
    }

    // Check if location has associated houses
    final houseCount = await _redis.scard('location:$id:houses');
    if (houseCount > 0) {
      throw Exception('Cannot delete location with associated houses');
    }

    // Remove from council's location list
    await _redis.srem('council:${location.councilId}:locations', [id]);

    // Delete location
    await _redis.del(['location:$id']);
  }

  Future<void> toggleLocationStatus(String id) async {
    final location = await getLocation(id);
    if (location == null) {
      throw Exception('Location not found');
    }

    final updatedLocation = location.copyWith(
      isActive: !location.isActive,
      updatedAt: DateTime.now(),
    );

    await updateLocation(updatedLocation);
  }

  Future<void> updateLocationType(String id, String locationTypeId) async {
    if (!Location.validLocationTypes.contains(locationTypeId)) {
      throw Exception('Invalid location type');
    }

    final location = await getLocation(id);
    if (location == null) {
      throw Exception('Location not found');
    }

    final updatedLocation = location.copyWith(
      locationTypeId: locationTypeId,
      updatedAt: DateTime.now(),
    );

    await updateLocation(updatedLocation);
  }
} 