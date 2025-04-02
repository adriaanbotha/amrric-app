import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/models/council.dart';

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
  debugPrint('Creating test councils...');
  final councils = [
    {
      'id': '1',
      'name': 'Darwin City Council',
      'state': 'NT',
      'imageUrl': null,
      'isActive': true,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': '2',
      'name': 'Alice Springs Town Council',
      'state': 'NT',
      'imageUrl': null,
      'isActive': true,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'id': '3',
      'name': 'Katherine Town Council',
      'state': 'NT',
      'imageUrl': null,
      'isActive': true,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
  ];

  for (final council in councils) {
    debugPrint('Creating council: ${council['name']}');
    final councilData = Council(
      id: council['id'] as String,
      name: council['name'] as String,
      state: council['state'] as String,
      imageUrl: council['imageUrl'] as String?,
      isActive: council['isActive'] as bool,
      createdAt: council['createdAt'] as DateTime,
      updatedAt: council['updatedAt'] as DateTime,
    ).toJson();
    
    debugPrint('Council data to store: $councilData');
    final redisData = councilData.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    debugPrint('Redis data to store: $redisData');
    
    await UpstashConfig.redis.hset(
      'council:${council['id']}',
      redisData,
    );
    debugPrint('Council ${council['name']} created successfully');
  }

  debugPrint('All test councils created successfully');
} 