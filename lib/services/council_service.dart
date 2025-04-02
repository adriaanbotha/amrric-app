import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'package:flutter/foundation.dart';
import '../models/council.dart';
import '../config/upstash_config.dart';

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
      final redisData = data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      debugPrint('Redis data to store: $redisData');
      
      await _redis.hset('council:${council.id}', redisData);
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
      final redisData = data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
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
      await _redis.del(['council:$id']);
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
        final data = await _redis.hgetall(key);
        if (data != null && data.isNotEmpty) {
          debugPrint('Council data from Redis: $data');
          councils.add(Council.fromJson(data));
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
      return Council.fromJson(data);
    } catch (e) {
      debugPrint('Error getting council: $e');
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
} 