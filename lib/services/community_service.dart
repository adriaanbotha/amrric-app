import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/community.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class CommunityService {
  Future<List<Community>> getCommunities() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Online: Fetch from Upstash
        final keys = await UpstashConfig.redis.keys('community:*');
        final communities = <Community>[];

        for (final key in keys) {
          final data = await UpstashConfig.redis.hgetall(key);
          if (data != null && data.isNotEmpty) {
            communities.add(Community.fromJson(data));
          }
        }

        // Update local storage
        final communityBox = await Hive.openBox<Community>('communities');
        await communityBox.clear();
        await communityBox.addAll(communities);

        return communities;
      } else {
        // Offline: Fetch from local storage
        final communityBox = await Hive.openBox<Community>('communities');
        return communityBox.values.toList();
      }
    } catch (e) {
      debugPrint('Error getting communities: $e');
      return [];
    }
  }
} 