import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/models/council.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'package:amrric_app/services/location_service.dart';
import 'package:amrric_app/services/council_service.dart';
import 'package:amrric_app/models/location.dart';
import 'package:amrric_app/models/location_type.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/house.dart';
import 'package:amrric_app/models/medical_history.dart';
import 'package:amrric_app/models/vaccination.dart';
import 'package:amrric_app/models/treatment.dart';
import 'package:amrric_app/models/photo_url.dart';
import 'package:amrric_app/models/registration_date.dart';
import 'package:amrric_app/models/last_updated.dart';
import 'package:amrric_app/models/is_active.dart';
import 'package:amrric_app/models/house_id.dart';
import 'package:amrric_app/models/location_id.dart';
import 'package:amrric_app/models/council_id.dart';
import 'package:amrric_app/models/photo_urls.dart';
import 'package:amrric_app/models/vaccinations.dart';
import 'package:amrric_app/models/treatments.dart';
import 'package:amrric_app/models/estimated_age.dart';
import 'package:amrric_app/models/weight.dart';
import 'package:amrric_app/models/microchip_number.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

Future<void> resetTestData() async {
  debugPrint('Resetting test data...');
  
  try {
    // Instead of using flushdb, we'll delete keys by type
    final allKeys = await UpstashConfig.redis.keys('*');
    debugPrint('Found ${allKeys.length} keys to delete');
    
    for (final key in allKeys) {
      try {
        // Get the type of the key
        final keyType = await UpstashConfig.redis.type(key);
        debugPrint('Key $key has type: $keyType');
        
        // Delete based on type
        switch (keyType) {
          case 'string':
            await UpstashConfig.redis.del([key]);
            break;
          case 'hash':
            await UpstashConfig.redis.del([key]);
            break;
          case 'set':
            await UpstashConfig.redis.del([key]);
            break;
          default:
            debugPrint('Unknown type for key $key: $keyType');
            await UpstashConfig.redis.del([key]);
        }
      } catch (e) {
        debugPrint('Error deleting key $key: $e');
        // Continue with other keys even if one fails
      }
    }
    
    // Wait a moment to ensure all deletes are processed
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Verify all keys are deleted
    final remainingKeys = await UpstashConfig.redis.keys('*');
    if (remainingKeys.isEmpty) {
      debugPrint('All keys successfully deleted');
    } else {
      debugPrint('Warning: ${remainingKeys.length} keys remaining: $remainingKeys');
    }
    
    // Recreate test data
    await createTestData();
    debugPrint('Test data reset completed');
  } catch (e, stack) {
    debugPrint('Error resetting test data: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

Future<void> createTestData() async {
  debugPrint('Starting test data creation...');
  try {
    // Check if data already exists
    final hasUsers = await UpstashConfig.redis.exists(['user:admin@amrric.com']);
    final hasCouncils = await UpstashConfig.redis.exists(['council:council1']);
    final hasAnimals = await UpstashConfig.redis.exists(['animals']);

    if (hasUsers == 0) {
      debugPrint('No users found, creating test users...');
      await createTestUsers();
      debugPrint('Users created successfully');
    } else {
      debugPrint('Users already exist, skipping creation');
    }
    
    if (hasCouncils == 0) {
      debugPrint('No councils found, creating test councils...');
      await createTestCouncils();
      debugPrint('Councils created successfully');
    } else {
      debugPrint('Councils already exist, skipping creation');
    }
    
    final locationService = LocationService();
    final locations = await locationService.getLocations();
    if (locations.isEmpty) {
      debugPrint('No locations found, creating test locations...');
      await TestData.createTestLocations(locationService);
      debugPrint('Locations created successfully');
    } else {
      debugPrint('Locations already exist, skipping creation');
    }
    
    if (hasAnimals == 0) {
      debugPrint('No animals found, creating test animals...');
      await createTestAnimals();
      debugPrint('Animals created successfully');
    } else {
      debugPrint('Animals already exist, skipping creation');
    }
    
    await verifyTestData();
    debugPrint('Test data verification completed');
  } catch (e, stack) {
    debugPrint('Error in createTestData: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

Future<void> verifyTestData() async {
  debugPrint('\nVerifying test data...');
  
  try {
    // Verify users and passwords
    final users = [
      {
        'email': 'admin@amrric.com',
        'password': 'admin123',
      },
      {
        'email': 'municipal@amrric.com',
        'password': 'municipal123',
      },
      {
        'email': 'vet@amrric.com',
        'password': 'vet123',
      },
      {
        'email': 'census@amrric.com',
        'password': 'census123',
      },
    ];

    debugPrint('\nVerifying users...');
    for (final user in users) {
      final userKey = 'user:${user['email']}';
      final exists = await UpstashConfig.redis.exists([userKey]);
      if (exists == 0) {
        debugPrint('Warning: User ${user['email']} not found');
        continue;
      }
      
      final userData = await UpstashConfig.redis.hgetall(userKey);
      if (userData == null || userData.isEmpty) {
        debugPrint('Warning: No data found for user ${user['email']}');
        continue;
      }
      debugPrint('User data for ${user['email']}: $userData');
      
      final passwordKey = 'password:${user['email']}';
      final passwordExists = await UpstashConfig.redis.exists([passwordKey]);
      if (passwordExists == 0) {
        debugPrint('Warning: Password for ${user['email']} not found');
        continue;
      }
      
      final password = await UpstashConfig.redis.get(passwordKey);
      if (password != user['password']) {
        debugPrint('Warning: Password mismatch for ${user['email']}. Expected: ${user['password']}, Got: $password');
        continue;
      }
      debugPrint('User ${user['email']} verified successfully');
    }

    // Verify councils exist
    debugPrint('\nVerifying councils...');
    final councilKeys = await UpstashConfig.redis.keys('council:*');
    if (councilKeys.isEmpty) {
      debugPrint('Warning: No councils found');
    } else {
      debugPrint('Found ${councilKeys.length} councils');
      for (final key in councilKeys) {
        try {
          final councilData = await UpstashConfig.redis.hgetall(key);
          if (councilData != null && councilData.isNotEmpty) {
            debugPrint('Council $key data: $councilData');
          } else {
            debugPrint('Warning: No data found for council $key');
          }
        } catch (e) {
          debugPrint('Error accessing council $key: $e');
        }
      }
    }

    // Verify animals exist
    debugPrint('\nVerifying animals...');
    final animalKeys = await UpstashConfig.redis.keys('animal:*');
    if (animalKeys.isEmpty) {
      debugPrint('Warning: No animals found');
    } else {
      debugPrint('Found ${animalKeys.length} animals');
      for (final key in animalKeys) {
        final animalData = await UpstashConfig.redis.hgetall(key);
        if (animalData != null && animalData.isNotEmpty) {
          debugPrint('Animal $key data: $animalData');
        }
      }
    }

    debugPrint('\nVerification completed');
  } catch (e, stack) {
    debugPrint('Error during verification: $e');
    debugPrint('Stack trace: $stack');
    // Don't rethrow verification errors, just log them
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
      'activityLog': <Map<String, dynamic>>[
        {
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
    },
    {
      'id': '2',
      'email': 'municipal@amrric.com',
      'name': 'Municipality Admin',
      'role': UserRole.municipalityAdmin,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': <Map<String, dynamic>>[
        {
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
      'councilId': 'council1',
    },
    {
      'id': '3',
      'email': 'vet@amrric.com',
      'name': 'Veterinary User',
      'role': UserRole.veterinaryUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': <Map<String, dynamic>>[
        {
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
    },
    {
      'id': '4',
      'email': 'census@amrric.com',
      'name': 'Census User',
      'role': UserRole.censusUser,
      'lastLogin': DateTime.now(),
      'isActive': true,
      'loginAttempts': 0,
      'activityLog': <Map<String, dynamic>>[
        {
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
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
        activityLog: (user['activityLog'] as List).cast<Map<String, dynamic>>(),
        municipalityId: user['municipalityId'] as String?,
        councilId: user['councilId'] as String?,
      );

      // Convert to JSON with proper serialization
      final userData = userObj.toJson();
      debugPrint('User data to store: $userData');
      
      // Convert all values to strings for Redis, ensuring proper type handling
      final redisData = userData.map((key, value) {
        if (value is bool) {
          return MapEntry(key, value.toString());
        } else if (value is List) {
          return MapEntry(key, jsonEncode(value));
        } else {
          return MapEntry(key, value?.toString() ?? '');
        }
      });
      debugPrint('Redis data to store: $redisData');
      
      await UpstashConfig.redis.hset(
        'user:${user['email']}',
        redisData,
      );
      
      debugPrint('Storing password for user: ${user['email']}');
      // Set the correct password for each user based on their role
      final password = switch (user['role']) {
        UserRole.systemAdmin => 'admin123',
        UserRole.municipalityAdmin => 'municipal123',
        UserRole.veterinaryUser => 'vet123',
        UserRole.censusUser => 'census123',
        _ => user['email'] as String,
      };
      await UpstashConfig.redis.set('password:${user['email']}', password);
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

    final now = DateTime.now();
    final councils = [
      Council(
        id: 'council1',
        name: 'Darwin City Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council2',
        name: 'Alice Springs Town Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=2',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council3',
        name: 'Katherine Town Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=3',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council4',
        name: 'Palmerston City Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=4',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council5',
        name: 'Litchfield Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=5',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Verify and create/update councils
    for (final council in councils) {
      try {
        final key = 'council:${council.id}';
        final locationsKey = 'council:${council.id}:locations';
        
        // Check if this specific council exists
        final exists = await redis.exists([key]);
        if (exists > 0) {
          debugPrint('Council ${council.name} exists, verifying data...');
          final councilData = await redis.hgetall(key);
          if (councilData != null && councilData.isNotEmpty) {
            debugPrint('Council ${council.name} data verified: $councilData');
            // Ensure locations set exists and is the correct type
            final type = await redis.type(locationsKey);
            if (type != 'set') {
              debugPrint('Recreating locations set for council ${council.name}');
              await redis.del([locationsKey]);
              await redis.sadd(locationsKey, []);
            }
            continue;
          }
        }

        debugPrint('Creating/updating council: ${council.name}');
        final data = council.toJson();
        final redisData = data.map((key, value) {
          if (value == null) {
            return MapEntry(key, '');
          } else if (value is DateTime) {
            return MapEntry(key, value.toIso8601String());
          } else if (value is bool) {
            return MapEntry(key, value.toString());
          } else if (value is List || value is Map) {
            return MapEntry(key, jsonEncode(value));
          } else {
            return MapEntry(key, value.toString());
          }
        });
        
        await redis.hset(key, redisData);
        await redis.sadd('councils', [council.id]);
        
        // Initialize empty locations set for the council
        await redis.del([locationsKey]);
        await redis.sadd(locationsKey, []);
        
        // Verify the council was created/updated
        final storedData = await redis.hgetall(key);
        if (storedData == null || storedData.isEmpty) {
          throw Exception('Council ${council.name} was created but has no data');
        }
        debugPrint('Council ${council.name} created/updated successfully: $storedData');
      } catch (e, stack) {
        debugPrint('Error creating/updating council ${council.name}: $e');
        debugPrint('Stack trace: $stack');
        rethrow;
      }
    }

    // Verify all councils are in the councils set
    final councilSet = await redis.smembers('councils');
    debugPrint('Councils set contains: $councilSet');
    
    debugPrint('Test councils creation/verification completed');
  } catch (e, stack) {
    debugPrint('Error creating test councils: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

Future<void> createTestAnimals() async {
  debugPrint('Creating test animals...');
  
  try {
    // Check if test animal exists
    final testAnimalKey = 'animal:animal1';
    final exists = await UpstashConfig.redis.exists([testAnimalKey]);
    
    if (exists > 0) {
      debugPrint('Test animal already exists, verifying data...');
      final animalData = await UpstashConfig.redis.hgetall(testAnimalKey);
      if (animalData != null && animalData.isNotEmpty) {
        debugPrint('Test animal data verified: $animalData');
        return;
      }
    }
    
    debugPrint('Creating test animal...');
    final animal = {
      'id': 'animal1',
      'name': 'Rex',
      'species': 'Dog',
      'breed': 'German Shepherd',
      'color': 'Black and Tan',
      'sex': 'Male',
      'estimatedAge': 3,
      'weight': 35.5,
      'microchipNumber': '123456789',
      'registrationDate': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'isActive': true,
      'houseId': 'house1',
      'locationId': 'location_6',  // Match census user's location
      'councilId': 'council1',     // Match test council
      'photoUrls': <String>[],
      'medicalHistory': {
        'treatments': [
          {
            'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            'type': 'Dental Cleaning',
            'notes': 'Regular dental checkup and cleaning'
          }
        ],
        'medications': [
          {
            'name': 'Heartworm Prevention',
            'startDate': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
            'endDate': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
            'dosage': '1 tablet monthly'
          }
        ]
      }
    };

    // Create the animal object
    final animalObj = Animal.fromJson(animal);
    
    // Convert to Redis format - ensure all values are strings
    final redisData = <String, String>{};
    final jsonData = animalObj.toJson();
    jsonData.forEach((key, value) {
      if (value == null) {
        redisData[key] = '';
      } else if (value is DateTime) {
        redisData[key] = value.toIso8601String();
      } else if (value is bool) {
        redisData[key] = value.toString();
      } else if (value is List || value is Map) {
        redisData[key] = jsonEncode(value);
      } else {
        redisData[key] = value.toString();
      }
    });
    
    // Store the animal data
    await UpstashConfig.redis.hset(testAnimalKey, redisData);
    
    // Add to animals set
    await UpstashConfig.redis.sadd('animals', ['animal1']);
    
    // Verify the animal was created
    final storedData = await UpstashConfig.redis.hgetall(testAnimalKey);
    if (storedData == null || storedData.isEmpty) {
      throw Exception('Test animal was created but has no data');
    }
    
    debugPrint('Test animal created successfully: $storedData');
  } catch (e, stack) {
    debugPrint('Error in createTestAnimals: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

Future<void> clearAllData() async {
  debugPrint('Clearing all data...');
  try {
    // First, backup the test users and their passwords
    final testUsers = [
      'user:admin@amrric.com',
      'user:municipal@amrric.com',
      'user:vet@amrric.com',
      'user:census@amrric.com',
    ];
    final testPasswords = [
      'password:admin@amrric.com',
      'password:municipal@amrric.com',
      'password:vet@amrric.com',
      'password:census@amrric.com',
    ];

    // Backup user data
    final userData = <String, Map<String, String>>{};
    for (final userKey in testUsers) {
      final data = await UpstashConfig.redis.hgetall(userKey);
      if (data != null) {
        userData[userKey] = data.map((key, value) => MapEntry(key, value.toString()));
      }
    }

    // Backup passwords
    final passwords = <String, String>{};
    for (final passwordKey in testPasswords) {
      final password = await UpstashConfig.redis.get(passwordKey);
      if (password != null) {
        passwords[passwordKey] = password;
      }
    }

    // Backup test animal
    final testAnimalKey = 'animal:animal1';
    final testAnimalData = await UpstashConfig.redis.hgetall(testAnimalKey);
    final animalData = testAnimalData?.map((key, value) => MapEntry(key, value.toString()));

    // Backup test councils
    final councilKeys = await UpstashConfig.redis.keys('council:*');
    final councilData = <String, Map<String, String>>{};
    for (final key in councilKeys) {
      final data = await UpstashConfig.redis.hgetall(key);
      if (data != null) {
        councilData[key] = data.map((k, v) => MapEntry(k, v.toString()));
      }
    }

    // Get all keys except the ones we want to preserve
    final allKeys = await UpstashConfig.redis.keys('*');
    final keysToDelete = allKeys.where((key) => 
      !testUsers.contains(key) &&
      !testPasswords.contains(key) &&
      key != testAnimalKey &&
      !councilKeys.contains(key)
    ).toList();

    // Delete all keys except preserved ones
    if (keysToDelete.isNotEmpty) {
      await UpstashConfig.redis.del(keysToDelete);
    }
    debugPrint('Cleared all non-test data');

    // Verify test data is still present
    for (final userKey in testUsers) {
      final exists = await UpstashConfig.redis.exists([userKey]);
      if (exists == 0) {
        debugPrint('Warning: Test user $userKey was not preserved');
      }
    }

    for (final councilKey in councilKeys) {
      final exists = await UpstashConfig.redis.exists([councilKey]);
      if (exists == 0) {
        debugPrint('Warning: Test council $councilKey was not preserved');
      }
    }

    final animalExists = await UpstashConfig.redis.exists([testAnimalKey]);
    if (animalExists == 0) {
      debugPrint('Warning: Test animal was not preserved');
    }

    debugPrint('Data clearing completed with test data preserved');
  } catch (e, stack) {
    debugPrint('Error clearing all data: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

Future<void> clearAnimals() async {
  debugPrint('Clearing animal data...');
  try {
    final animalKeys = await UpstashConfig.redis.keys('animal:*');
    if (animalKeys.isNotEmpty) {
      for (final key in animalKeys) {
        await UpstashConfig.redis.del([key]);
      }
    }
    await UpstashConfig.redis.del(['animals']);
    debugPrint('Animal data cleared successfully');
  } catch (e, stack) {
    debugPrint('Error clearing animal data: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

Future<void> clearCouncils() async {
  debugPrint('Clearing council data...');
  try {
    final councilKeys = await UpstashConfig.redis.keys('council:*');
    if (councilKeys.isNotEmpty) {
      for (final key in councilKeys) {
        await UpstashConfig.redis.del([key]);
      }
    }
    debugPrint('Council data cleared successfully');
  } catch (e, stack) {
    debugPrint('Error clearing council data: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

Future<void> clearLocations() async {
  debugPrint('Clearing location data...');
  try {
    final locationKeys = await UpstashConfig.redis.keys('location:*');
    if (locationKeys.isNotEmpty) {
      for (final key in locationKeys) {
        await UpstashConfig.redis.del([key]);
      }
    }
    debugPrint('Location data cleared successfully');
  } catch (e, stack) {
    debugPrint('Error clearing location data: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
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