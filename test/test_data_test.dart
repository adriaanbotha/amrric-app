import 'package:flutter_test/flutter_test.dart';
import 'package:amrric_app/config/test_data.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'test_helper.dart';

void main() {
  late Redis redis;
  late AuthService authService;

  setUp(() async {
    redis = await setupTestRedis();
    authService = AuthService(redis);
  });

  group('Test Data Generation Tests', () {
    test('Test users are created with correct roles', () async {
      // Create test data
      await createTestData();

      // Test system admin
      await authService.login('admin@amrric.com', 'admin123');
      expect(authService.currentUser?.role, equals(UserRole.systemAdmin));

      // Test municipality admin
      await authService.login('municipal@amrric.com', 'municipal123');
      expect(authService.currentUser?.role, equals(UserRole.municipalityAdmin));
      expect(authService.currentUser?.municipalityId, isNotNull);

      // Test veterinary user
      await authService.login('vet@amrric.com', 'vet123');
      expect(authService.currentUser?.role, equals(UserRole.veterinaryUser));

      // Test census user
      await authService.login('census@amrric.com', 'census123');
      expect(authService.currentUser?.role, equals(UserRole.censusUser));
      expect(authService.currentUser?.locationId, isNotNull);
    });

    test('Test councils are created with locations', () async {
      // Create test data
      await createTestData();

      // Login as admin to verify council data
      await authService.login('admin@amrric.com', 'admin123');

      // Check councils exist
      final councilKeys = await redis.keys('council:*');
      expect(councilKeys, isNotEmpty);

      // Check each council has locations
      for (final key in councilKeys) {
        final councilData = await redis.hgetall(key);
        expect(councilData, isNotNull);
        expect(councilData, isNotEmpty);

        // Check locations for this council
        final councilId = councilData!['id']?.toString();
        expect(councilId, isNotNull);
        
        final locationKeys = await redis.smembers('council:$councilId:locations');
        expect(locationKeys, isNotEmpty);

        // Check each location exists
        for (final locationId in locationKeys) {
          final locationData = await redis.hgetall('location:$locationId');
          expect(locationData, isNotEmpty);
        }
      }
    });

    test('Test data can be reset', () async {
      // Create initial test data
      await createTestData();

      // Add some additional data
      await redis.hset('test:extra', {'key': 'value'});

      // Reset and recreate test data
      await resetTestData();

      // Verify extra data is gone
      final extraData = await redis.hgetall('test:extra');
      expect(extraData, isEmpty);

      // Verify test users still exist
      final adminData = await redis.hgetall('user:admin@amrric.com');
      expect(adminData, isNotEmpty);
    });

    test('Test data includes required fields', () async {
      // Create test data
      await createTestData();

      // Login as admin
      await authService.login('admin@amrric.com', 'admin123');

      // Check municipality admin has required fields
      await authService.login('municipal@amrric.com', 'municipal123');
      expect(authService.currentUser?.municipalityId, isNotNull);
      expect(authService.currentUser?.name, isNotEmpty);
      expect(authService.currentUser?.email, isNotEmpty);
      expect(authService.currentUser?.isActive, isTrue);

      // Check veterinary user has required fields
      await authService.login('vet@amrric.com', 'vet123');
      expect(authService.currentUser?.name, isNotEmpty);
      expect(authService.currentUser?.email, isNotEmpty);
      expect(authService.currentUser?.isActive, isTrue);

      // Check census user has required fields
      await authService.login('census@amrric.com', 'census123');
      expect(authService.currentUser?.locationId, isNotNull);
      expect(authService.currentUser?.name, isNotEmpty);
      expect(authService.currentUser?.email, isNotEmpty);
      expect(authService.currentUser?.isActive, isTrue);
    });
  });
} 