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
    await UpstashConfig.redis.set('user:${user['email']}', User(
      id: user['id'] as String,
      email: user['email'] as String,
      name: user['name'] as String,
      role: user['role'] as UserRole,
      lastLogin: user['lastLogin'] as DateTime,
      isActive: user['isActive'] as bool,
    ).toJson());
    await UpstashConfig.redis.set('password:${user['email']}', user['email']);
  }

  print('Test users created successfully');
} 