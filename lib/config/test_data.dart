import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/models/council.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'package:amrric_app/services/location_service.dart';
import 'package:amrric_app/services/council_service.dart';
import 'package:amrric_app/models/location.dart';
import 'package:amrric_app/models/location_type.dart';

Future<void> createTestData() async {
  debugPrint('Starting test data creation...');
  await createTestUsers();
  await createTestCouncils();
  await verifyTestData();
  debugPrint('Test data creation completed');
}

Future<void> verifyTestData() async {
  debugPrint('\nVerifying test data...');
  
  // Verify users and passwords
  final users = [
    'admin@amrric.com',
    'municipal@amrric.com',
    'vet@amrric.com',
    'census@amrric.com',
  ];

  for (final email in users) {
    debugPrint('\nVerifying user: $email');
    final userData = await UpstashConfig.redis.hgetall('user:$email');
    debugPrint('User data: $userData');
    
    final password = await UpstashConfig.redis.get('password:$email');
    debugPrint('Stored password: $password');
  }

  // Verify councils
  debugPrint('\nVerifying councils...');
  final councilKeys = await UpstashConfig.redis.keys('council:*');
  for (final key in councilKeys) {
    final councilData = await UpstashConfig.redis.hgetall(key);
    debugPrint('\nCouncil $key data: $councilData');
  }
}

Future<void> createTestUsers() async {
  debugPrint('Creating test users...');
  final users = [
    {
      'id': '1',
      'email': 'admin@amrric.com',
      'name': 'System Admin',
      'role': UserRole.systemAdmin,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': <Map<String, dynamic>>[],
    },
    {
      'id': '2',
      'email': 'municipal@amrric.com',
      'name': 'Municipality Admin',
      'role': UserRole.municipalityAdmin,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': <Map<String, dynamic>>[],
    },
    {
      'id': '3',
      'email': 'vet@amrric.com',
      'name': 'Veterinary User',
      'role': UserRole.veterinaryUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': <Map<String, dynamic>>[],
    },
    {
      'id': '4',
      'email': 'census@amrric.com',
      'name': 'Census User',
      'role': UserRole.censusUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': <Map<String, dynamic>>[],
    },
  ];

  for (final user in users) {
    try {
      debugPrint('Creating user: ${user['email']}');
      
      // Create the User object with explicit type casting
      final userObj = User(
        id: user['id'] as String,
        email: user['email'] as String,
        name: user['name'] as String,
        role: user['role'] as UserRole,
        lastLogin: user['lastLogin'] as DateTime,
        isActive: user['isActive'] as bool,
        loginAttempts: user['loginAttempts'] as int,
        activityLog: List<Map<String, dynamic>>.from(user['activityLog'] as List),
      );

      // Convert to JSON with proper serialization
      final userData = userObj.toJson();
      debugPrint('User data to store: $userData');
      
      // Convert all values to strings for Redis
      final redisData = userData.map((key, value) => MapEntry(key, value.toString()));
      debugPrint('Redis data to store: $redisData');
      
      await UpstashConfig.redis.hset(
        'user:${user['email']}',
        redisData,
      );
      
      debugPrint('Storing password for user: ${user['email']}');
      await UpstashConfig.redis.set('password:${user['email']}', user['email']);
      debugPrint('Password stored successfully for user: ${user['email']}');
      debugPrint('User ${user['email']} created successfully');
    } catch (e, stack) {
      debugPrint('Error creating user ${user['email']}: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  debugPrint('All test users created successfully');
}

Future<void> createTestCouncils() async {
  try {
    final redis = UpstashConfig.redis;
    debugPrint('Creating test councils...');

    // Clear existing councils
    final existingKeys = await redis.keys('council:*');
    if (existingKeys.isNotEmpty) {
      await redis.del(existingKeys);
      debugPrint('Cleared existing councils');
    }

    final now = DateTime.now();
    final councils = [
      Council(
        id: 'council1',
        name: 'Darwin City Council',
        state: 'NT',
        imageUrl: 'https://example.com/darwin.jpg',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council2',
        name: 'Alice Springs Town Council',
        state: 'NT',
        imageUrl: 'https://example.com/alice.jpg',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council3',
        name: 'Katherine Town Council',
        state: 'NT',
        imageUrl: 'https://example.com/katherine.jpg',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Add new councils
    for (final council in councils) {
      final data = council.toJson();
      final redisData = data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      await redis.hset('council:${council.id}', redisData);
      debugPrint('Created council: ${council.name}');
    }

    debugPrint('All test councils created successfully');
  } catch (e, stack) {
    debugPrint('Error creating test councils: $e');
    debugPrint('Stack trace: $stack');
  }
}

class TestData {
  static Future<void> createTestData(CouncilService councilService, LocationService locationService) async {
    await createTestCouncils();
    await createTestLocations(locationService);
  }

  static Future<void> createTestLocations(LocationService locationService) async {
    final councils = await CouncilService().getCouncils();
    if (councils.isEmpty) {
      print('No councils found. Please create councils first.');
      return;
    }

    final darwinCouncil = councils.firstWhere((c) => c.name == 'Darwin City Council');
    final aliceCouncil = councils.firstWhere((c) => c.name == 'Alice Springs Town Council');

    final locations = [
      Location.create().copyWith(
        name: 'Darwin CBD',
        altName: 'City Centre',
        code: 'DRW01',
        locationTypeId: LocationType.urban,
        councilId: darwinCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Nightcliff',
        altName: null,
        code: 'DRW02',
        locationTypeId: LocationType.urban,
        councilId: darwinCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Bagot Community',
        altName: 'Bagot',
        code: 'DRW03',
        locationTypeId: LocationType.indigenous,
        councilId: darwinCouncil.id,
        useLotNumber: false,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Alice Springs CBD',
        altName: 'Town Centre',
        code: 'ASP01',
        locationTypeId: LocationType.urban,
        councilId: aliceCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Larapinta',
        altName: null,
        code: 'ASP02',
        locationTypeId: LocationType.urban,
        councilId: aliceCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Hermannsburg',
        altName: 'Ntaria',
        code: 'ASP03',
        locationTypeId: LocationType.indigenous,
        councilId: aliceCouncil.id,
        useLotNumber: false,
        isActive: true,
      ),
    ];

    for (final location in locations) {
      try {
        await locationService.addLocation(location);
        print('Added test location: ${location.name}');
      } catch (e) {
        print('Error adding test location ${location.name}: $e');
      }
    }
  }
} 