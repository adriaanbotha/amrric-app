import 'package:upstash_redis/upstash_redis.dart';
import 'dart:convert';

Future<void> main() async {
  final redis = Redis(
    url: const String.fromEnvironment('UPSTASH_REDIS_URL', defaultValue: 'https://neutral-toad-19982.upstash.io'),
    token: const String.fromEnvironment('UPSTASH_REDIS_TOKEN', defaultValue: 'AU4OAAIjcDFhMzAzZjcwYzM5ZWM0NWUyYWYwMWIyODY0MGRkNWE1YnAxMA'),
  );
  final now = DateTime.now();
  final List<Map<String, dynamic>> censusTestData = List.generate(19, (i) => {
    'id': 'census_animal_${i+1}',
    'species': i % 2 == 0 ? 'Dog' : 'Cat',
    'sex': i % 3 == 0 ? 'Male' : 'Female',
    'estimatedAge': (i % 10) + 1,
    'color': i % 2 == 0 ? 'Brown' : 'Black',
    'houseId': 'house_${(i % 5) + 1}',
    'locationId': 'location_${(i % 3) + 1}',
    'councilId': 'council_1',
    'isActive': true,
    'registrationDate': now.subtract(Duration(days: i * 2)).toIso8601String(),
    'lastUpdated': now.toIso8601String(),
    'photoUrls': <String>[],
    'censusData': jsonEncode({
      'lastCount': now.subtract(Duration(days: i * 2)).toIso8601String(),
      'condition': i % 4 == 0 ? 'healthy' : 'needs attention',
      'location': 'house_${(i % 5) + 1}',
    }),
  });

  for (final animal in censusTestData) {
    final key = 'animal:${animal['id']}';
    final redisData = animal.map((k, v) {
      if (v is List || v is Map) {
        return MapEntry(k, jsonEncode(v));
      } else {
        return MapEntry(k, v.toString());
      }
    });
    await redis.hset(key, redisData);
    await redis.sadd('animals', [animal['id']]);
  }
  print('Test census animal records created successfully');
} 