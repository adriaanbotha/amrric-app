import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/config/upstash_config.dart';

final councilServiceProvider = Provider<CouncilService>((ref) => CouncilService());

class CouncilService {
  static const String _councilsKey = 'councils';

  Future<List<Council>> getCouncils() async {
    try {
      final councilIds = await UpstashConfig.redis.smembers(_councilsKey);
      if (councilIds.isEmpty) return [];

      final councils = <Council>[];
      for (final id in councilIds) {
        final councilData = await UpstashConfig.redis.hgetall('council:$id');
        if (councilData != null && councilData.isNotEmpty) {
          try {
            councils.add(Council.fromJson(councilData));
          } catch (e) {
            debugPrint('Error parsing council data for $id: $e');
          }
        }
      }
      return councils;
    } catch (e) {
      debugPrint('Error getting councils: $e');
      return [];
    }
  }

  Future<void> saveCouncil(Council council) async {
    try {
      // Convert council data to Redis-compatible format
      final councilData = council.toJson().map((key, value) {
        if (value is bool) {
          return MapEntry(key, value.toString());
        } else if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        } else {
          return MapEntry(key, value?.toString() ?? '');
        }
      });

      await UpstashConfig.redis.hset('council:${council.id}', councilData);
      await UpstashConfig.redis.sadd(_councilsKey, [council.id]);
    } catch (e) {
      debugPrint('Error saving council: $e');
      rethrow;
    }
  }

  Future<void> deleteCouncil(String id) async {
    try {
      await UpstashConfig.redis.del(['council:$id']);
      await UpstashConfig.redis.srem(_councilsKey, [id]);
    } catch (e) {
      debugPrint('Error deleting council: $e');
      rethrow;
    }
  }
} 