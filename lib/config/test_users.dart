import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';

Future<void> createTestUsers() async {
  final users = [
    {
      'id': '1',
      'email': 'admin@amrric.com',
      'name': 'System Admin',
      'role': UserRole.systemAdmin,
      'lastLogin': DateTime.now(),
      'isActive': true,
    },
    {
      'id': '2',
      'email': 'municipal@amrric.com',
      'name': 'Municipality Admin',
      'role': UserRole.municipalityAdmin,
      'lastLogin': DateTime.now(),
      'isActive': true,
    },
    {
      'id': '3',
      'email': 'vet@amrric.com',
      'name': 'Veterinary User',
      'role': UserRole.veterinaryUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
    },
    {
      'id': '4',
      'email': 'census@amrric.com',
      'name': 'Census User',
      'role': UserRole.censusUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
    },
  ];

  for (final user in users) {
    final userObj = User(
      id: user['id'] as String,
      email: user['email'] as String,
      name: user['name'] as String,
      role: user['role'] as UserRole,
      lastLogin: user['lastLogin'] as DateTime,
      isActive: user['isActive'] as bool,
    );
    final userData = userObj.toJson();
    // Convert all values to strings for Redis, ensuring proper JSON encoding for lists
    final redisData = userData.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.toString());
      } else {
        return MapEntry(key, value?.toString() ?? '');
      }
    });
    await UpstashConfig.redis.hset('user:${user['email']}', redisData);
    await UpstashConfig.redis.set('password:${user['email']}', user['email']);
  }

  print('Test users created successfully');
} 