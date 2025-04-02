import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';

Future<void> createTestUsers() async {
  final users = [
    User(
      id: '1',
      email: 'admin@amrric.com',
      name: 'System Admin',
      role: UserRole.systemAdmin,
      lastLogin: DateTime.now(),
      isActive: true,
    ),
    User(
      id: '2',
      email: 'municipal@amrric.com',
      name: 'Municipality Admin',
      role: UserRole.municipalityAdmin,
      municipalityId: 'municipality1',
      lastLogin: DateTime.now(),
      isActive: true,
    ),
    User(
      id: '3',
      email: 'vet@amrric.com',
      name: 'Veterinary User',
      role: UserRole.veterinary,
      lastLogin: DateTime.now(),
      isActive: true,
    ),
    User(
      id: '4',
      email: 'census@amrric.com',
      name: 'Census User',
      role: UserRole.normal,
      lastLogin: DateTime.now(),
      isActive: true,
    ),
  ];

  for (final user in users) {
    await UpstashConfig.redis.set(
      'user:${user.email}',
      user.toJson(),
    );
    // Set password as email for testing
    await UpstashConfig.redis.set(
      'password:${user.email}',
      user.email,
    );
  }

  print('Test users created successfully');
} 