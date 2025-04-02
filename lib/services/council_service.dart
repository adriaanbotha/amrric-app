import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upstash_redis/upstash_redis.dart';
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
      state = const AsyncValue.loading();
      final councils = await getCouncils();
      state = AsyncValue.data(councils);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCouncil(Council council) async {
    try {
      final data = council.toMap();
      await _redis.hset('council:${council.id}', data);
      await loadCouncils();
    } catch (e) {
      print('Error adding council: $e');
      rethrow;
    }
  }

  Future<void> updateCouncil(Council council) async {
    try {
      final data = council.toMap();
      await _redis.hset('council:${council.id}', data);
      await loadCouncils();
    } catch (e) {
      print('Error updating council: $e');
      rethrow;
    }
  }

  Future<void> deleteCouncil(String id) async {
    try {
      await _redis.del(['council:$id']);
      await loadCouncils();
    } catch (e) {
      print('Error deleting council: $e');
      rethrow;
    }
  }

  Future<List<Council>> getCouncils() async {
    try {
      final keys = await _redis.keys('council:*');
      final councils = <Council>[];

      for (final key in keys) {
        final data = await _redis.hgetall(key);
        if (data != null && data.isNotEmpty) {
          councils.add(Council.fromMap(data));
        }
      }

      return councils;
    } catch (e) {
      print('Error getting councils: $e');
      rethrow;
    }
  }

  Future<Council?> getCouncil(String id) async {
    try {
      final data = await _redis.hgetall('council:$id');
      if (data == null || data.isEmpty) return null;
      return Council.fromMap(data);
    } catch (e) {
      print('Error getting council: $e');
      rethrow;
    }
  }

  // Search councils by name
  Future<List<Council>> searchCouncils(String query) async {
    final councils = await getCouncils();
    final lowercaseQuery = query.toLowerCase();
    
    return councils.where((council) {
      return council.name.toLowerCase().contains(lowercaseQuery) ||
             council.state.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Toggle council status
  Future<void> toggleCouncilStatus(String id) async {
    final council = await getCouncil(id);
    if (council == null) {
      throw Exception('Council not found');
    }

    final updatedCouncil = council.copyWith(
      isActive: !council.isActive,
      updatedAt: DateTime.now(),
    );

    await updateCouncil(updatedCouncil);
  }
} 