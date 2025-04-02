import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/models/council.dart';
import 'package:upstash_redis/upstash_redis.dart';

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
      'activityLog': [],
    },
    {
      'id': '2',
      'email': 'municipal@amrric.com',
      'name': 'Municipality Admin',
      'role': UserRole.municipalityAdmin,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': [],
    },
    {
      'id': '3',
      'email': 'vet@amrric.com',
      'name': 'Veterinary User',
      'role': UserRole.veterinaryUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': [],
    },
    {
      'id': '4',
      'email': 'census@amrric.com',
      'name': 'Census User',
      'role': UserRole.censusUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': [],
    },
  ];

  for (final user in users) {
    debugPrint('Creating user: ${user['email']}');
    final userData = User(
      id: user['id'] as String,
      email: user['email'] as String,
      name: user['name'] as String,
      role: user['role'] as UserRole,
      lastLogin: user['lastLogin'] as DateTime,
      isActive: user['isActive'] as bool,
      loginAttempts: user['loginAttempts'] as int,
      activityLog: user['activityLog'] as List<Map<String, dynamic>>,
    ).toJson();
    
    debugPrint('User data to store: $userData');
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
  }

  debugPrint('All test users created successfully');
}

Future<void> createTestCouncils() async {
  try {
    final redis = UpstashConfig.redis;
    
    // Create test councils
    final testCouncils = [
      {
        'id': 'council1',
        'name': 'Sydney City Council',
        'state': 'NSW',
        'imageUrl': 'https://example.com/sydney.jpg',
        'isActive': 'true',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'council2',
        'name': 'Melbourne City Council',
        'state': 'VIC',
        'imageUrl': 'https://example.com/melbourne.jpg',
        'isActive': 'true',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'council3',
        'name': 'Darwin City Council',
        'state': 'NT',
        'imageUrl': 'https://example.com/darwin.jpg',
        'isActive': 'true',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    // Clear existing councils
    final existingKeys = await redis.keys('council:*');
    if (existingKeys.isNotEmpty) {
      await redis.del(existingKeys);
    }

    // Add new councils
    for (final council in testCouncils) {
      await redis.hset('council:${council['id']}', council);
      debugPrint('Created council: ${council['name']}');
    }

    debugPrint('All test councils created successfully');
  } catch (e) {
    debugPrint('Error creating test data: $e');
  }
}

class TestData {
  static Map<String, String> getTestCouncil() {
    return {
      'id': 'test1',
      'name': 'Test Council',
      'state': 'NSW',
      'imageUrl': 'https://example.com/image.jpg',
      'isActive': 'true',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static Council createTestCouncil() {
    final data = getTestCouncil();
    return Council(
      id: data['id']!,
      name: data['name']!,
      state: data['state']!,
      imageUrl: data['imageUrl']!,
      isActive: data['isActive']!.toLowerCase() == 'true',
      createdAt: DateTime.parse(data['createdAt']!),
      updatedAt: DateTime.parse(data['updatedAt']!),
    );
  }
} 