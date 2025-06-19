import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/upstash_config.dart';
import '../models/house.dart';

class HouseService {
  static const String _keyPrefix = 'house:';
  static const String _indexKey = 'houses';

  // Get all houses
  Future<List<House>> getHouses() async {
    try {
      final redis = UpstashConfig.redis;
      final houseIds = await redis.smembers(_indexKey);
      
      if (houseIds.isEmpty) {
        return [];
      }

      final houses = <House>[];
      for (final houseId in houseIds) {
        final houseData = await redis.hgetall('$_keyPrefix$houseId');
        if (houseData != null && houseData.isNotEmpty) {
          try {
            final house = House.fromJson(houseData.map((k, v) => MapEntry(k, v.toString())));
            houses.add(house);
          } catch (e) {
            debugPrint('Error parsing house $houseId: $e');
          }
        }
      }

      return houses;
    } catch (e) {
      debugPrint('Error getting houses: $e');
      return [];
    }
  }

  // Get houses by location
  Future<List<House>> getHousesByLocation(String locationId) async {
    try {
      final allHouses = await getHouses();
      return allHouses.where((house) => house.locationId == locationId).toList();
    } catch (e) {
      debugPrint('Error getting houses by location: $e');
      return [];
    }
  }

  // Get houses by council
  Future<List<House>> getHousesByCouncil(String councilId) async {
    try {
      final allHouses = await getHouses();
      return allHouses.where((house) => house.councilId == councilId).toList();
    } catch (e) {
      debugPrint('Error getting houses by council: $e');
      return [];
    }
  }

  // Get single house
  Future<House?> getHouse(String houseId) async {
    try {
      final redis = UpstashConfig.redis;
      final houseData = await redis.hgetall('$_keyPrefix$houseId');
      
      if (houseData == null || houseData.isEmpty) {
        return null;
      }

      return House.fromJson(houseData.map((k, v) => MapEntry(k, v.toString())));
    } catch (e) {
      debugPrint('Error getting house $houseId: $e');
      return null;
    }
  }

  // Create house
  Future<House> createHouse(House house) async {
    try {
      if (!house.validate()) {
        throw Exception('Invalid house data');
      }

      final redis = UpstashConfig.redis;
      final houseData = house.toJson().map((k, v) => MapEntry(k, v?.toString() ?? ''));
      
      await redis.hset('$_keyPrefix${house.id}', houseData);
      await redis.sadd(_indexKey, [house.id]);
      
      debugPrint('House ${house.id} created successfully');
      return house;
    } catch (e) {
      debugPrint('Error creating house: $e');
      rethrow;
    }
  }

  // Update house
  Future<House> updateHouse(House house) async {
    try {
      if (!house.validate()) {
        throw Exception('Invalid house data');
      }

      final redis = UpstashConfig.redis;
      final updatedHouse = house.copyWith(updatedAt: DateTime.now());
      final houseData = updatedHouse.toJson().map((k, v) => MapEntry(k, v?.toString() ?? ''));
      
      await redis.hset('$_keyPrefix${house.id}', houseData);
      
      debugPrint('House ${house.id} updated successfully');
      return updatedHouse;
    } catch (e) {
      debugPrint('Error updating house: $e');
      rethrow;
    }
  }

  // Delete house
  Future<void> deleteHouse(String houseId) async {
    try {
      final redis = UpstashConfig.redis;
      
      // Check if house exists
      final exists = await redis.exists(['$_keyPrefix$houseId']);
      if (exists == 0) {
        throw Exception('House not found');
      }

      // TODO: Check if house has associated animals before deletion
      // This would require checking animal residence records

      await redis.del(['$_keyPrefix$houseId']);
      await redis.srem(_indexKey, [houseId]);
      
      debugPrint('House $houseId deleted successfully');
    } catch (e) {
      debugPrint('Error deleting house: $e');
      rethrow;
    }
  }

  // Search houses
  Future<List<House>> searchHouses(String query) async {
    try {
      final allHouses = await getHouses();
      final lowercaseQuery = query.toLowerCase();
      
      return allHouses.where((house) {
        return house.fullAddress.toLowerCase().contains(lowercaseQuery) ||
               (house.houseNumber?.toLowerCase().contains(lowercaseQuery) ?? false) ||
               (house.streetName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
               (house.suburb?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e) {
      debugPrint('Error searching houses: $e');
      return [];
    }
  }

  // Get house statistics
  Future<Map<String, dynamic>> getHouseStatistics() async {
    try {
      final houses = await getHouses();
      
      return {
        'totalHouses': houses.length,
        'activeHouses': houses.where((h) => h.isActive).length,
        'inactiveHouses': houses.where((h) => !h.isActive).length,
        'housesWithCoordinates': houses.where((h) => h.latitude != null && h.longitude != null).length,
        'averageHousesPerLocation': houses.isNotEmpty 
            ? houses.map((h) => h.locationId).toSet().length 
            : 0,
      };
    } catch (e) {
      debugPrint('Error getting house statistics: $e');
      return {};
    }
  }

  // Bulk operations
  Future<void> createHouses(List<House> houses) async {
    for (final house in houses) {
      await createHouse(house);
    }
  }

  Future<void> deleteHousesByLocation(String locationId) async {
    try {
      final houses = await getHousesByLocation(locationId);
      for (final house in houses) {
        await deleteHouse(house.id);
      }
    } catch (e) {
      debugPrint('Error deleting houses by location: $e');
      rethrow;
    }
  }
} 