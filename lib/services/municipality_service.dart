import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/municipality.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class MunicipalityService {
  Future<List<Municipality>> getMunicipalities() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Online: Fetch from Upstash
        final keys = await UpstashConfig.redis.keys('municipality:*');
        final municipalities = <Municipality>[];

        for (final key in keys) {
          final data = await UpstashConfig.redis.hgetall(key);
          if (data != null && data.isNotEmpty) {
            municipalities.add(Municipality.fromJson(data));
          }
        }

        // Update local storage
        final municipalityBox = await Hive.openBox<Municipality>('municipalities');
        await municipalityBox.clear();
        await municipalityBox.addAll(municipalities);

        return municipalities;
      } else {
        // Offline: Fetch from local storage
        final municipalityBox = await Hive.openBox<Municipality>('municipalities');
        return municipalityBox.values.toList();
      }
    } catch (e) {
      debugPrint('Error getting municipalities: $e');
      return [];
    }
  }
} 