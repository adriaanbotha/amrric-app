import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/treatment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class VetService {
  Future<List<Treatment>> getTreatments(String animalId) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Online: Fetch from Upstash
        final keys = await UpstashConfig.redis.keys('treatment:$animalId:*');
        final treatments = <Treatment>[];

        for (final key in keys) {
          final data = await UpstashConfig.redis.hgetall(key);
          if (data != null && data.isNotEmpty) {
            treatments.add(Treatment.fromJson(data));
          }
        }

        // Update local storage
        final treatmentBox = await Hive.openBox<Treatment>('treatments');
        await treatmentBox.clear();
        await treatmentBox.addAll(treatments);

        return treatments;
      } else {
        // Offline: Fetch from local storage
        final treatmentBox = await Hive.openBox<Treatment>('treatments');
        return treatmentBox.values.where((t) => t.animalId == animalId).toList();
      }
    } catch (e) {
      debugPrint('Error getting treatments: $e');
      return [];
    }
  }
} 