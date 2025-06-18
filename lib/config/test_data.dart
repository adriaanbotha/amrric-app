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
import 'package:hive/hive.dart';

Future<void> resetTestData() async {
  try {
    await UpstashConfig.redis.flushall();
  } catch (e) {
    debugPrint('Error resetting test data: $e');
    rethrow;
  }
}

Future<void> createTestData() async {
  try {
    debugPrint('Starting test data creation...');
    
    // First, reset all data
    await resetTestData();
    debugPrint('Reset all data');
    
    // Create test users
    await createTestUsers();
    debugPrint('Created test users');
    
    // Create test councils
    await createTestCouncils();
    debugPrint('Created test councils');
    
    // Create test locations
    await createTestLocations();
    debugPrint('Created test locations');
    
    // Create test houses
    await createTestHouses();
    debugPrint('Created test houses');
    
    // Create test animals
    await createTestAnimals();
    debugPrint('Created test animals');
    
    // Create test census animals
    await createTestCensusAnimals();
    debugPrint('Created test census animals');
    
    // Create test reports
    await createTestReports();
    debugPrint('Created test reports');
    
    // Verify all data was created
    await verifyTestData();
    debugPrint('Verified all test data');
    
    debugPrint('All test data created successfully');
  } catch (e, stack) {
    debugPrint('Error creating test data: $e');
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
  final now = DateTime.now();
  
  final users = [
    User(
      id: '1',
      email: 'admin@amrric.com',
      name: 'System Admin',
      role: UserRole.systemAdmin,
      lastLogin: now,
      isActive: true,
      loginAttempts: 0,
      activityLog: [
        {
          'timestamp': now.toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
      createdAt: now,
      updatedAt: now,
    ),
    User(
      id: '2',
      email: 'municipal@amrric.com',
      name: 'Municipality Admin',
      role: UserRole.municipalityAdmin,
      lastLogin: now,
      isActive: true,
      loginAttempts: 0,
      activityLog: [
        {
          'timestamp': now.toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
      councilId: 'council1',
      createdAt: now,
      updatedAt: now,
    ),
    User(
      id: '3',
      email: 'vet@amrric.com',
      name: 'Veterinary User',
      role: UserRole.veterinaryUser,
      lastLogin: now,
      isActive: true,
      loginAttempts: 0,
      activityLog: [
        {
          'timestamp': now.toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
      createdAt: now,
      updatedAt: now,
    ),
    User(
      id: '4',
      email: 'census@amrric.com',
      name: 'Census User',
      role: UserRole.censusUser,
      lastLogin: now,
      isActive: true,
      loginAttempts: 0,
      activityLog: [
        {
          'timestamp': now.toIso8601String(),
          'action': 'account_created',
          'details': 'Test account created',
        }
      ],
      locationId: 'location_nt_001', // Assign Darwin CBD as test location
      councilId: 'council_nt_001', // Darwin City Council
      createdAt: now,
      updatedAt: now,
    ),
  ];

  for (final user in users) {
    try {
      final userData = user.toJson();
      final redisData = userData.map((key, value) {
        if (value is List) {
          return MapEntry(key, jsonEncode(value));
        } else {
          return MapEntry(key, value?.toString() ?? '');
        }
      });
      
      await UpstashConfig.redis.hset('user:${user.email}', redisData);
      await UpstashConfig.redis.set('password:${user.email}', '${user.email.split('@')[0]}123');
      
      // Store in Hive for offline access
      final userBox = await Hive.openBox<User>('users');
      await userBox.put(user.email, user);
      
      debugPrint('Created user: ${user.email}');
    } catch (e) {
      debugPrint('Error creating user ${user.email}: $e');
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
      // Northern Territory
      Council(
        id: 'council_nt_001',
        name: 'Darwin City Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nt_002',
        name: 'Alice Springs Town Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=2',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nt_003',
        name: 'Katherine Town Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=3',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nt_004',
        name: 'Palmerston City Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=4',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nt_005',
        name: 'Litchfield Council',
        state: 'NT',
        imageUrl: 'https://picsum.photos/200/300?random=5',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Queensland
      Council(
        id: 'council_qld_001',
        name: 'Brisbane City Council',
        state: 'QLD',
        imageUrl: 'https://picsum.photos/200/300?random=6',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_qld_002',
        name: 'Gold Coast City Council',
        state: 'QLD',
        imageUrl: 'https://picsum.photos/200/300?random=7',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_qld_003',
        name: 'Sunshine Coast Regional Council',
        state: 'QLD',
        imageUrl: 'https://picsum.photos/200/300?random=8',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_qld_004',
        name: 'Townsville City Council',
        state: 'QLD',
        imageUrl: 'https://picsum.photos/200/300?random=9',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_qld_005',
        name: 'Cairns Regional Council',
        state: 'QLD',
        imageUrl: 'https://picsum.photos/200/300?random=10',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // New South Wales
      Council(
        id: 'council_nsw_001',
        name: 'City of Sydney',
        state: 'NSW',
        imageUrl: 'https://picsum.photos/200/300?random=11',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nsw_002',
        name: 'City of Parramatta',
        state: 'NSW',
        imageUrl: 'https://picsum.photos/200/300?random=12',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nsw_003',
        name: 'City of Newcastle',
        state: 'NSW',
        imageUrl: 'https://picsum.photos/200/300?random=13',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nsw_004',
        name: 'Wollongong City Council',
        state: 'NSW',
        imageUrl: 'https://picsum.photos/200/300?random=14',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_nsw_005',
        name: 'Central Coast Council',
        state: 'NSW',
        imageUrl: 'https://picsum.photos/200/300?random=15',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Victoria
      Council(
        id: 'council_vic_001',
        name: 'City of Melbourne',
        state: 'VIC',
        imageUrl: 'https://picsum.photos/200/300?random=16',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_vic_002',
        name: 'City of Geelong',
        state: 'VIC',
        imageUrl: 'https://picsum.photos/200/300?random=17',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_vic_003',
        name: 'City of Ballarat',
        state: 'VIC',
        imageUrl: 'https://picsum.photos/200/300?random=18',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_vic_004',
        name: 'City of Bendigo',
        state: 'VIC',
        imageUrl: 'https://picsum.photos/200/300?random=19',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_vic_005',
        name: 'City of Greater Shepparton',
        state: 'VIC',
        imageUrl: 'https://picsum.photos/200/300?random=20',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Western Australia
      Council(
        id: 'council_wa_001',
        name: 'City of Perth',
        state: 'WA',
        imageUrl: 'https://picsum.photos/200/300?random=21',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_wa_002',
        name: 'City of Fremantle',
        state: 'WA',
        imageUrl: 'https://picsum.photos/200/300?random=22',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_wa_003',
        name: 'City of Bunbury',
        state: 'WA',
        imageUrl: 'https://picsum.photos/200/300?random=23',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_wa_004',
        name: 'City of Geraldton',
        state: 'WA',
        imageUrl: 'https://picsum.photos/200/300?random=24',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_wa_005',
        name: 'City of Kalgoorlie-Boulder',
        state: 'WA',
        imageUrl: 'https://picsum.photos/200/300?random=25',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // South Australia
      Council(
        id: 'council_sa_001',
        name: 'City of Adelaide',
        state: 'SA',
        imageUrl: 'https://picsum.photos/200/300?random=26',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_sa_002',
        name: 'City of Mount Gambier',
        state: 'SA',
        imageUrl: 'https://picsum.photos/200/300?random=27',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_sa_003',
        name: 'City of Whyalla',
        state: 'SA',
        imageUrl: 'https://picsum.photos/200/300?random=28',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_sa_004',
        name: 'City of Port Augusta',
        state: 'SA',
        imageUrl: 'https://picsum.photos/200/300?random=29',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_sa_005',
        name: 'City of Port Pirie',
        state: 'SA',
        imageUrl: 'https://picsum.photos/200/300?random=30',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Tasmania
      Council(
        id: 'council_tas_001',
        name: 'City of Hobart',
        state: 'TAS',
        imageUrl: 'https://picsum.photos/200/300?random=31',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_tas_002',
        name: 'City of Launceston',
        state: 'TAS',
        imageUrl: 'https://picsum.photos/200/300?random=32',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_tas_003',
        name: 'City of Devonport',
        state: 'TAS',
        imageUrl: 'https://picsum.photos/200/300?random=33',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_tas_004',
        name: 'City of Burnie',
        state: 'TAS',
        imageUrl: 'https://picsum.photos/200/300?random=34',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Council(
        id: 'council_tas_005',
        name: 'City of Clarence',
        state: 'TAS',
        imageUrl: 'https://picsum.photos/200/300?random=35',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Australian Capital Territory
      Council(
        id: 'council_act_001',
        name: 'ACT Government',
        state: 'ACT',
        imageUrl: 'https://picsum.photos/200/300?random=36',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // First, clear any existing council data
    final existingKeys = await redis.keys('council:*');
    if (existingKeys.isNotEmpty) {
      await redis.del(existingKeys);
    }
    await redis.del(['councils']);

    // Create councils
    for (final council in councils) {
      try {
        final key = 'council:${council.id}';
        final data = council.toJson();
        
        // Convert all values to strings for Redis
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
        
        debugPrint('Council ${council.name} created successfully');
      } catch (e) {
        debugPrint('Error creating council ${council.name}: $e');
        rethrow;
      }
    }

    debugPrint('All test councils created successfully');
  } catch (e) {
    debugPrint('Error creating test councils: $e');
    rethrow;
  }
}

Future<void> createTestAnimals() async {
  debugPrint('Creating test animals...');
  
  try {
    final redis = UpstashConfig.redis;
    
    // First, clear any existing animal data
    final existingKeys = await redis.keys('animal:*');
    if (existingKeys.isNotEmpty) {
      await redis.del(existingKeys);
    }
    await redis.del(['animals']);

    final animals = [
      {
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
        'locationId': 'location_001',
        'councilId': 'council1',
        'photoUrls': ['https://picsum.photos/200/300?random=1'],
        'medicalHistory': {
          'treatments': [
            {
              'id': 'treatment1',
              'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
              'type': 'Vaccination',
              'notes': 'Annual vaccination',
              'medication': 'DHPP',
              'dosage': '1ml',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            },
            {
              'id': 'treatment2',
              'date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
              'type': 'Medication',
              'notes': 'Heartworm prevention',
              'medication': 'Heartgard Plus',
              'dosage': '1 chewable tablet',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
            },
            {
              'id': 'treatment3',
              'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
              'type': 'Procedure',
              'notes': 'Dental cleaning',
              'medication': 'None',
              'dosage': 'N/A',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
            },
            {
              'id': 'treatment4',
              'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
              'type': 'Medication',
              'notes': 'Joint supplement for hip dysplasia',
              'medication': 'Dasuquin',
              'dosage': '2 chewable tablets',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
            }
          ],
          'medications': {
            'current': [
              {
                'id': 'med1',
                'name': 'Heartgard Plus',
                'type': 'Preventive',
                'startDate': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
                'dosage': '1 chewable tablet',
                'frequency': 'Monthly',
                'notes': 'Heartworm prevention',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(days: 15)).toIso8601String()
              },
              {
                'id': 'med2',
                'name': 'Rimadyl',
                'type': 'Pain Management',
                'startDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
                'dosage': '75mg',
                'frequency': 'Twice daily',
                'notes': 'For hip dysplasia pain management',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(hours: 12)).toIso8601String()
              },
              {
                'id': 'med3',
                'name': 'Dasuquin',
                'type': 'Supplement',
                'startDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 27)).toIso8601String(),
                'dosage': '2 chewable tablets',
                'frequency': 'Daily',
                'notes': 'Joint health supplement for hip dysplasia',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(days: 0)).toIso8601String()
              }
            ],
            'history': [
              {
                'id': 'med4',
                'name': 'Amoxicillin',
                'type': 'Antibiotic',
                'startDate': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
                'dosage': '500mg',
                'frequency': 'Twice daily',
                'notes': 'For skin infection',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              },
              {
                'id': 'med5',
                'name': 'Prednisone',
                'type': 'Anti-inflammatory',
                'startDate': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 75)).toIso8601String(),
                'dosage': '20mg',
                'frequency': 'Once daily',
                'notes': 'For allergic reaction',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              },
              {
                'id': 'med6',
                'name': 'Tramadol',
                'type': 'Pain Management',
                'startDate': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 110)).toIso8601String(),
                'dosage': '50mg',
                'frequency': 'Every 8 hours',
                'notes': 'Post-surgery pain management',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              }
            ]
          },
          'allergies': ['Penicillin', 'Sulfa drugs'],
          'chronicConditions': ['Mild hip dysplasia', 'Seasonal allergies'],
          'lastCheckup': DateTime.now().subtract(const Duration(days: 30)).toIso8601String()
        }
      },
      {
        'id': 'animal2',
        'name': 'Luna',
        'species': 'Cat',
        'breed': 'Siamese',
        'color': 'Cream',
        'sex': 'Female',
        'estimatedAge': 2,
        'weight': 4.2,
        'microchipNumber': '987654321',
        'registrationDate': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'isActive': true,
        'houseId': 'house2',
        'locationId': 'location_002',
        'councilId': 'council1',
        'photoUrls': ['https://picsum.photos/200/300?random=2'],
        'medicalHistory': {
          'treatments': [
            {
              'id': 'treatment4',
              'date': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
              'type': 'Vaccination',
              'notes': 'Annual vaccination',
              'medication': 'FVRCP',
              'dosage': '1ml',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
            },
            {
              'id': 'treatment5',
              'date': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
              'type': 'Medication',
              'notes': 'Flea and tick prevention',
              'medication': 'Frontline Plus',
              'dosage': '0.5ml topical',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
            },
            {
              'id': 'treatment6',
              'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
              'type': 'Procedure',
              'notes': 'Spay surgery',
              'medication': 'None',
              'dosage': 'N/A',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
            },
            {
              'id': 'treatment7',
              'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
              'type': 'Medication',
              'notes': 'Dental health supplement',
              'medication': 'Dental Fresh',
              'dosage': '1ml in water',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            }
          ],
          'medications': {
            'current': [
              {
                'id': 'med5',
                'name': 'Frontline Plus',
                'type': 'Preventive',
                'startDate': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
                'dosage': '0.5ml topical',
                'frequency': 'Monthly',
                'notes': 'Flea and tick prevention',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(days: 10)).toIso8601String()
              },
              {
                'id': 'med6',
                'name': 'Metacam',
                'type': 'Pain Management',
                'startDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 4)).toIso8601String(),
                'dosage': '0.5ml',
                'frequency': 'Once daily',
                'notes': 'Post-spay pain management',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(days: 0)).toIso8601String()
              },
              {
                'id': 'med7',
                'name': 'Dental Fresh',
                'type': 'Supplement',
                'startDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 25)).toIso8601String(),
                'dosage': '1ml',
                'frequency': 'Daily',
                'notes': 'Dental health maintenance',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(days: 0)).toIso8601String()
              }
            ],
            'history': [
              {
                'id': 'med8',
                'name': 'Clavamox',
                'type': 'Antibiotic',
                'startDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 23)).toIso8601String(),
                'dosage': '62.5mg',
                'frequency': 'Twice daily',
                'notes': 'Post-spay infection prevention',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              },
              {
                'id': 'med9',
                'name': 'Buprenorphine',
                'type': 'Pain Management',
                'startDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
                'dosage': '0.1ml',
                'frequency': 'Every 8 hours',
                'notes': 'Post-spay pain management',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              }
            ]
          },
          'allergies': ['None known'],
          'chronicConditions': ['None'],
          'lastCheckup': DateTime.now().subtract(const Duration(days: 45)).toIso8601String()
        }
      },
      {
        'id': 'animal3',
        'name': 'Rocky',
        'species': 'Dog',
        'breed': 'Labrador Retriever',
        'color': 'Chocolate',
        'sex': 'Male',
        'estimatedAge': 4,
        'weight': 32.0,
        'microchipNumber': '456789123',
        'registrationDate': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'isActive': true,
        'houseId': 'house3',
        'locationId': 'location_003',
        'councilId': 'council1',
        'photoUrls': ['https://picsum.photos/200/300?random=3'],
        'medicalHistory': {
          'treatments': [
            {
              'id': 'treatment7',
              'date': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
              'type': 'Vaccination',
              'notes': 'Annual vaccination',
              'medication': 'DHPP + Rabies',
              'dosage': '1ml each',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
            },
            {
              'id': 'treatment8',
              'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
              'type': 'Medication',
              'notes': 'Joint supplement',
              'medication': 'Glucosamine',
              'dosage': '500mg daily',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            },
            {
              'id': 'treatment9',
              'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
              'type': 'Procedure',
              'notes': 'Ear infection treatment',
              'medication': 'Ear drops',
              'dosage': '2 drops twice daily',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            },
            {
              'id': 'treatment10',
              'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
              'type': 'Medication',
              'notes': 'Anti-inflammatory for arthritis',
              'medication': 'Meloxicam',
              'dosage': '1.5mg',
              'userId': 'vet@amrric.com',
              'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            }
          ],
          'medications': {
            'current': [
              {
                'id': 'med8',
                'name': 'Glucosamine',
                'type': 'Supplement',
                'startDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
                'dosage': '500mg',
                'frequency': 'Daily',
                'notes': 'Joint health maintenance',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(days: 0)).toIso8601String()
              },
              {
                'id': 'med9',
                'name': 'Otomax',
                'type': 'Antibiotic',
                'startDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
                'dosage': '2 drops',
                'frequency': 'Twice daily',
                'notes': 'Ear infection treatment',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(hours: 12)).toIso8601String()
              },
              {
                'id': 'med10',
                'name': 'Meloxicam',
                'type': 'Anti-inflammatory',
                'startDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 28)).toIso8601String(),
                'dosage': '1.5mg',
                'frequency': 'Once daily',
                'notes': 'Arthritis pain management',
                'prescribedBy': 'vet@amrric.com',
                'lastAdministered': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
                'nextDue': DateTime.now().add(const Duration(days: 0)).toIso8601String()
              }
            ],
            'history': [
              {
                'id': 'med11',
                'name': 'Carprofen',
                'type': 'Pain Management',
                'startDate': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
                'dosage': '75mg',
                'frequency': 'Once daily',
                'notes': 'Post-surgery pain management',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              },
              {
                'id': 'med12',
                'name': 'Cephalexin',
                'type': 'Antibiotic',
                'startDate': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 38)).toIso8601String(),
                'dosage': '500mg',
                'frequency': 'Twice daily',
                'notes': 'Post-surgery infection prevention',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              },
              {
                'id': 'med13',
                'name': 'Tramadol',
                'type': 'Pain Management',
                'startDate': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
                'endDate': DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
                'dosage': '50mg',
                'frequency': 'Every 8 hours',
                'notes': 'Post-surgery pain management',
                'prescribedBy': 'vet@amrric.com',
                'status': 'Completed'
              }
            ]
          },
          'allergies': ['Chicken', 'Corn', 'Soy'],
          'chronicConditions': ['Mild arthritis', 'Food sensitivities'],
          'lastCheckup': DateTime.now().subtract(const Duration(days: 60)).toIso8601String()
        }
      }
    ];

    for (final animal in animals) {
      try {
        final animalKey = 'animal:${animal['id']}';
        
        // Convert all values to strings for Redis
        final redisData = animal.map((key, value) {
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
        
        await redis.hset(animalKey, redisData);
        await redis.sadd('animals', [animal['id']]);
        
        debugPrint('Animal ${animal['name']} created successfully');
      } catch (e) {
        debugPrint('Error creating animal ${animal['name']}: $e');
        rethrow;
      }
    }
    
    debugPrint('All test animals created successfully');
  } catch (e) {
    debugPrint('Error creating test animals: $e');
    rethrow;
  }
}

Future<void> createTestReports() async {
  try {
    final redis = UpstashConfig.redis;
    final now = DateTime.now();
    final pastWeek = now.subtract(const Duration(days: 7));
    final nextWeek = now.add(const Duration(days: 7));
    
    // Clear existing reports
    final existingKeys = await redis.keys('reports:*');
    if (existingKeys.isNotEmpty) {
      await redis.del(existingKeys);
    }
    
    // Generate report data for each user role
    await _createSystemAdminReports(redis, pastWeek, nextWeek);
    await _createMunicipalityAdminReports(redis, pastWeek, nextWeek);
    await _createVeterinaryUserReports(redis, pastWeek, nextWeek);
    await _createCensusUserReports(redis, pastWeek, nextWeek);
    
    // Legacy reports for backwards compatibility
    final reports = [
      {
        'id': 'report_001',
        'type': 'census',
        'title': 'Monthly Animal Census Report - March 2024',
        'description': 'Monthly report of all registered animals in Darwin CBD',
        'councilId': 'council1',
        'locationId': 'location_001',
        'createdBy': 'census@amrric.com',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'completed',
        'data': {
          'totalAnimals': 150,
          'bySpecies': {
            'dog': 80,
            'cat': 60,
            'other': 10
          },
          'byLocation': {
            'Darwin CBD': 100,
            'Nightcliff': 30,
            'Bagot Community': 20
          },
          'vaccinationStatus': {
            'upToDate': 120,
            'overdue': 30
          },
          'microchipStatus': {
            'chipped': 140,
            'notChipped': 10
          },
          'healthStatus': {
            'healthy': 130,
            'needsAttention': 20
          },
          'ageDistribution': {
            'under1': 20,
            '1to3': 50,
            '3to7': 60,
            'over7': 20
          }
        }
      },
      {
        'id': 'report_002',
        'type': 'treatment',
        'title': 'Q1 Treatment Summary - 2024',
        'description': 'Summary of all treatments performed in Q1 2024',
        'councilId': 'council1',
        'locationId': 'location_001',
        'createdBy': 'vet@amrric.com',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'completed',
        'data': {
          'totalTreatments': 45,
          'byType': {
            'vaccination': 30,
            'dental': 10,
            'surgery': 5
          },
          'bySpecies': {
            'dog': 25,
            'cat': 20
          },
          'successRate': 0.95,
          'commonIssues': [
            'Dental disease',
            'Vaccination overdue',
            'Minor injuries'
          ],
          'medicationUsage': {
            'heartworm': 25,
            'flea': 30,
            'worm': 20
          },
          'treatmentOutcomes': {
            'successful': 43,
            'followup': 2
          },
          'costAnalysis': {
            'total': 4500.00,
            'average': 100.00,
            'byType': {
              'vaccination': 1500.00,
              'dental': 2000.00,
              'surgery': 1000.00
            }
          }
        }
      },
      {
        'id': 'report_003',
        'type': 'incident',
        'title': 'Animal Control Incidents Report - March 2024',
        'description': 'Report of animal control incidents in Darwin CBD',
        'councilId': 'council1',
        'locationId': 'location_001',
        'createdBy': 'municipal@amrric.com',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'completed',
        'data': {
          'totalIncidents': 20,
          'byType': {
            'stray': 10,
            'aggressive': 5,
            'injury': 5
          },
          'byLocation': {
            'Darwin CBD': 12,
            'Nightcliff': 5,
            'Bagot Community': 3
          },
          'resolutionTime': {
            'under1Hour': 15,
            '1to4Hours': 5
          },
          'outcomes': {
            'returned': 15,
            'impounded': 5
          },
          'severity': {
            'low': 12,
            'medium': 6,
            'high': 2
          },
          'responseTime': {
            'under30min': 10,
            '30to60min': 8,
            'over60min': 2
          },
          'costAnalysis': {
            'total': 2000.00,
            'average': 100.00,
            'byType': {
              'stray': 1000.00,
              'aggressive': 500.00,
              'injury': 500.00
            }
          }
        }
      },
      {
        'id': 'report_004',
        'type': 'health',
        'title': 'Community Health Report - Q1 2024',
        'description': 'Comprehensive health report for all animals in the community',
        'councilId': 'council1',
        'locationId': 'location_001',
        'createdBy': 'vet@amrric.com',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'completed',
        'data': {
          'totalAnimals': 150,
          'healthStatus': {
            'excellent': 80,
            'good': 50,
            'fair': 15,
            'poor': 5
          },
          'diseasePrevalence': {
            'dental': 20,
            'skin': 15,
            'parasitic': 10,
            'other': 5
          },
          'vaccinationCoverage': {
            'complete': 120,
            'partial': 20,
            'none': 10
          },
          'preventiveCare': {
            'heartworm': 130,
            'flea': 140,
            'worm': 125
          },
          'riskFactors': {
            'age': {
              'under1': 5,
              '1to3': 10,
              '3to7': 15,
              'over7': 20
            },
            'species': {
              'dog': 25,
              'cat': 15
            }
          },
          'recommendations': [
            'Increase vaccination awareness',
            'Implement dental care program',
            'Enhance parasite prevention'
          ]
        }
      }
    ];

    for (final report in reports) {
      final reportKey = 'report:${report['id']}';
      
      // Convert all values to strings for Redis
      final redisData = report.map((key, value) {
        if (value is Map || value is List) {
          return MapEntry(key, jsonEncode(value));
        }
        return MapEntry(key, value.toString());
      });

      await redis.hset(reportKey, redisData);
      await redis.sadd('reports', [report['id']]);
      debugPrint('Created test report: ${report['id']}');
    }

    debugPrint('All test reports created successfully');
  } catch (e) {
    debugPrint('Error creating test reports: $e');
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
  static Future<void> createTestLocations(LocationService locationService) async {
    final councils = await CouncilService().getCouncils();
    if (councils.isEmpty) {
      print('No councils found. Please create councils first.');
      return;
    }

    final darwinCouncil = councils.firstWhere((c) => c.name == 'Darwin City Council');
    final aliceCouncil = councils.firstWhere((c) => c.name == 'Alice Springs Town Council');
    final katherineCouncil = councils.firstWhere((c) => c.name == 'Katherine Town Council');

    final locations = [
      // Darwin City Council locations
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
        name: 'Palmerston',
        altName: 'Palmerston City',
        code: 'DRW04',
        locationTypeId: LocationType.urban,
        councilId: darwinCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Humpty Doo',
        altName: null,
        code: 'DRW05',
        locationTypeId: LocationType.rural,
        councilId: darwinCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),

      // Alice Springs Town Council locations
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
      Location.create().copyWith(
        name: 'Araluen',
        altName: null,
        code: 'ASP04',
        locationTypeId: LocationType.urban,
        councilId: aliceCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'East Side',
        altName: 'East Side Community',
        code: 'ASP05',
        locationTypeId: LocationType.urban,
        councilId: aliceCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),

      // Katherine Town Council locations
      Location.create().copyWith(
        name: 'Katherine CBD',
        altName: 'Town Centre',
        code: 'KAT01',
        locationTypeId: LocationType.urban,
        councilId: katherineCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Katherine East',
        altName: null,
        code: 'KAT02',
        locationTypeId: LocationType.urban,
        councilId: katherineCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Katherine South',
        altName: null,
        code: 'KAT03',
        locationTypeId: LocationType.urban,
        councilId: katherineCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Tindal',
        altName: 'RAAF Base Tindal',
        code: 'KAT04',
        locationTypeId: LocationType.rural,
        councilId: katherineCouncil.id,
        useLotNumber: true,
        isActive: true,
      ),
      Location.create().copyWith(
        name: 'Binjari',
        altName: 'Binjari Community',
        code: 'KAT05',
        locationTypeId: LocationType.indigenous,
        councilId: katherineCouncil.id,
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

Future<void> createTestLocations() async {
  try {
    final redis = UpstashConfig.redis;
    debugPrint('Creating test locations...');

    // First, clear any existing location data
    final existingKeys = await redis.keys('location:*');
    if (existingKeys.isNotEmpty) {
      await redis.del(existingKeys);
    }
    await redis.del(['locations']);

    final locations = [
      // Northern Territory Locations
      {
        'id': 'location_nt_001',
        'name': 'Darwin CBD',
        'altName': 'City Centre',
        'code': 'DRW01',
        'locationTypeId': 'urban',
        'councilId': 'council_nt_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_nt_002',
        'name': 'Nightcliff',
        'altName': null,
        'code': 'DRW02',
        'locationTypeId': 'urban',
        'councilId': 'council_nt_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_nt_003',
        'name': 'Bagot Community',
        'altName': 'Bagot',
        'code': 'DRW03',
        'locationTypeId': 'indigenous',
        'councilId': 'council_nt_001',
        'useLotNumber': false,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_nt_004',
        'name': 'Palmerston City',
        'altName': 'Palmerston',
        'code': 'PAL01',
        'locationTypeId': 'urban',
        'councilId': 'council_nt_004',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_nt_005',
        'name': 'Humpty Doo',
        'altName': null,
        'code': 'LIT01',
        'locationTypeId': 'rural',
        'councilId': 'council_nt_005',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },

      // Queensland Locations
      {
        'id': 'location_qld_001',
        'name': 'Brisbane CBD',
        'altName': 'City Centre',
        'code': 'BNE01',
        'locationTypeId': 'urban',
        'councilId': 'council_qld_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_qld_002',
        'name': 'South Bank',
        'altName': null,
        'code': 'BNE02',
        'locationTypeId': 'urban',
        'councilId': 'council_qld_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_qld_003',
        'name': 'Surfers Paradise',
        'altName': null,
        'code': 'GCC01',
        'locationTypeId': 'urban',
        'councilId': 'council_qld_002',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_qld_004',
        'name': 'Maroochydore',
        'altName': null,
        'code': 'SSC01',
        'locationTypeId': 'urban',
        'councilId': 'council_qld_003',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },

      // New South Wales Locations
      {
        'id': 'location_nsw_001',
        'name': 'Sydney CBD',
        'altName': 'City Centre',
        'code': 'SYD01',
        'locationTypeId': 'urban',
        'councilId': 'council_nsw_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_nsw_002',
        'name': 'Parramatta CBD',
        'altName': 'City Centre',
        'code': 'PRM01',
        'locationTypeId': 'urban',
        'councilId': 'council_nsw_002',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_nsw_003',
        'name': 'Newcastle CBD',
        'altName': 'City Centre',
        'code': 'NCL01',
        'locationTypeId': 'urban',
        'councilId': 'council_nsw_003',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },

      // Victoria Locations
      {
        'id': 'location_vic_001',
        'name': 'Melbourne CBD',
        'altName': 'City Centre',
        'code': 'MEL01',
        'locationTypeId': 'urban',
        'councilId': 'council_vic_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_vic_002',
        'name': 'Geelong CBD',
        'altName': 'City Centre',
        'code': 'GEE01',
        'locationTypeId': 'urban',
        'councilId': 'council_vic_002',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_vic_003',
        'name': 'Ballarat CBD',
        'altName': 'City Centre',
        'code': 'BAL01',
        'locationTypeId': 'urban',
        'councilId': 'council_vic_003',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },

      // Western Australia Locations
      {
        'id': 'location_wa_001',
        'name': 'Perth CBD',
        'altName': 'City Centre',
        'code': 'PER01',
        'locationTypeId': 'urban',
        'councilId': 'council_wa_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_wa_002',
        'name': 'Fremantle CBD',
        'altName': 'City Centre',
        'code': 'FRE01',
        'locationTypeId': 'urban',
        'councilId': 'council_wa_002',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },

      // South Australia Locations
      {
        'id': 'location_sa_001',
        'name': 'Adelaide CBD',
        'altName': 'City Centre',
        'code': 'ADL01',
        'locationTypeId': 'urban',
        'councilId': 'council_sa_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_sa_002',
        'name': 'Mount Gambier CBD',
        'altName': 'City Centre',
        'code': 'MGB01',
        'locationTypeId': 'urban',
        'councilId': 'council_sa_002',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },

      // Tasmania Locations
      {
        'id': 'location_tas_001',
        'name': 'Hobart CBD',
        'altName': 'City Centre',
        'code': 'HOB01',
        'locationTypeId': 'urban',
        'councilId': 'council_tas_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_tas_002',
        'name': 'Launceston CBD',
        'altName': 'City Centre',
        'code': 'LNC01',
        'locationTypeId': 'urban',
        'councilId': 'council_tas_002',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },

      // Australian Capital Territory Locations
      {
        'id': 'location_act_001',
        'name': 'Canberra CBD',
        'altName': 'City Centre',
        'code': 'CBR01',
        'locationTypeId': 'urban',
        'councilId': 'council_act_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'location_act_002',
        'name': 'Belconnen',
        'altName': null,
        'code': 'CBR02',
        'locationTypeId': 'urban',
        'councilId': 'council_act_001',
        'useLotNumber': true,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final location in locations) {
      try {
        final locationKey = 'location:${location['id']}';
        
        // Convert all values to strings for Redis
        final redisData = location.map((key, value) {
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
        
        await redis.hset(locationKey, redisData);
        await redis.sadd('locations', [location['id']]);
        
        // Add location to council's locations set
        final councilLocationsKey = 'council:${location['councilId']}:locations';
        await redis.sadd(councilLocationsKey, [location['id']]);
        
        debugPrint('Location ${location['name']} created successfully');
      } catch (e) {
        debugPrint('Error creating location ${location['name']}: $e');
        rethrow;
      }
    }

    debugPrint('All test locations created successfully');
  } catch (e) {
    debugPrint('Error creating test locations: $e');
    rethrow;
  }
}

Future<void> createTestHouses() async {
  try {
    final redis = UpstashConfig.redis;
    debugPrint('Creating test houses...');

    // First, clear any existing house data
    final existingKeys = await redis.keys('house:*');
    if (existingKeys.isNotEmpty) {
      await redis.del(existingKeys);
    }
    await redis.del(['houses']);

    final houses = [
      // Houses in Darwin CBD (location_nt_001) for census user
      {
        'id': 'house_darwin_001',
        'address': '123 Mitchell Street',
        'lotNumber': '',
        'ownerName': 'John Smith',
        'ownerContact': '0412345678',
        'locationId': 'location_nt_001',
        'councilId': 'council_nt_001',
        'gpsCoordinates': '-12.4634, 130.8456',
        'animalCount': '2',
        'notes': 'Two dogs, friendly owners',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'house_darwin_002',
        'address': '45 Smith Street',
        'lotNumber': '',
        'ownerName': 'Mary Johnson',
        'ownerContact': 'mary.j@email.com',
        'locationId': 'location_nt_001',
        'councilId': 'council_nt_001',
        'gpsCoordinates': '-12.4612, 130.8423',
        'animalCount': '1',
        'notes': 'One cat, indoor only',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'house_darwin_003',
        'address': '78 Knuckey Street',
        'lotNumber': '',
        'ownerName': 'David Wilson',
        'ownerContact': '0423456789',
        'locationId': 'location_nt_001',
        'councilId': 'council_nt_001',
        'gpsCoordinates': '-12.4598, 130.8401',
        'animalCount': '3',
        'notes': 'Two cats and one dog',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'house_darwin_004',
        'address': '12 Cavenagh Street',
        'lotNumber': '',
        'ownerName': 'Sarah Brown',
        'ownerContact': 'sarah.brown@email.com',
        'locationId': 'location_nt_001',
        'councilId': 'council_nt_001',
        'gpsCoordinates': '-12.4587, 130.8434',
        'animalCount': '1',
        'notes': 'One elderly dog',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'house_darwin_005',
        'address': '34 Bennett Street',
        'lotNumber': '',
        'ownerName': 'Michael Davis',
        'ownerContact': '0434567890',
        'locationId': 'location_nt_001',
        'councilId': 'council_nt_001',
        'gpsCoordinates': '-12.4623, 130.8467',
        'animalCount': '0',
        'notes': 'No pets currently',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final house in houses) {
      try {
        final houseKey = 'house:${house['id']}';
        
        // Convert all values to strings for Redis
        final redisData = house.map((key, value) {
          if (value == null) {
            return MapEntry(key, '');
          } else if (value is bool) {
            return MapEntry(key, value.toString());
          } else if (value is List || value is Map) {
            return MapEntry(key, jsonEncode(value));
          } else {
            return MapEntry(key, value.toString());
          }
        });
        
        await redis.hset(houseKey, redisData);
        await redis.sadd('houses', [house['id']]);
        
        debugPrint('House ${house['address']} created successfully');
      } catch (e) {
        debugPrint('Error creating house ${house['address']}: $e');
        rethrow;
      }
    }

    debugPrint('All test houses created successfully');
  } catch (e) {
    debugPrint('Error creating test houses: $e');
    rethrow;
  }
}

Future<void> createTestCensusAnimals() async {
  final redis = UpstashConfig.redis;
  final now = DateTime.now();
  
  // Create animals specifically for Darwin CBD (location_nt_001)
  final List<Map<String, dynamic>> censusTestData = [
    {
      'id': 'census_animal_darwin_001',
      'name': 'Rex',
      'species': 'Dog',
      'breed': 'German Shepherd',
      'color': 'Black and Tan',
      'sex': 'Male',
      'estimatedAge': 4,
      'weight': 32.5,
      'houseId': 'house_darwin_001',
      'locationId': 'location_nt_001',
      'councilId': 'council_nt_001',
      'isActive': true,
      'registrationDate': now.subtract(Duration(days: 30)).toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'photoUrls': <String>[],
      'censusData': {
        'lastCount': now.subtract(Duration(days: 10)).toIso8601String(),
        'condition': 'healthy',
        'location': 'house_darwin_001',
      },
    },
    {
      'id': 'census_animal_darwin_002',
      'name': 'Bella',
      'species': 'Dog',
      'breed': 'Labrador',
      'color': 'Golden',
      'sex': 'Female',
      'estimatedAge': 2,
      'weight': 25.0,
      'houseId': 'house_darwin_001',
      'locationId': 'location_nt_001',
      'councilId': 'council_nt_001',
      'isActive': true,
      'registrationDate': now.subtract(Duration(days: 45)).toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'photoUrls': <String>[],
      'censusData': {
        'lastCount': now.subtract(Duration(days: 10)).toIso8601String(),
        'condition': 'healthy',
        'location': 'house_darwin_001',
      },
    },
    {
      'id': 'census_animal_darwin_003',
      'name': 'Whiskers',
      'species': 'Cat',
      'breed': 'Domestic Shorthair',
      'color': 'Tabby',
      'sex': 'Male',
      'estimatedAge': 3,
      'weight': 4.5,
      'houseId': 'house_darwin_002',
      'locationId': 'location_nt_001',
      'councilId': 'council_nt_001',
      'isActive': true,
      'registrationDate': now.subtract(Duration(days: 60)).toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'photoUrls': <String>[],
      'censusData': {
        'lastCount': now.subtract(Duration(days: 15)).toIso8601String(),
        'condition': 'healthy',
        'location': 'house_darwin_002',
      },
    },
    {
      'id': 'census_animal_darwin_004',
      'name': 'Fluffy',
      'species': 'Cat',
      'breed': 'Persian',
      'color': 'White',
      'sex': 'Female',
      'estimatedAge': 5,
      'weight': 3.8,
      'houseId': 'house_darwin_003',
      'locationId': 'location_nt_001',
      'councilId': 'council_nt_001',
      'isActive': true,
      'registrationDate': now.subtract(Duration(days: 90)).toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'photoUrls': <String>[],
      'censusData': {
        'lastCount': now.subtract(Duration(days: 20)).toIso8601String(),
        'condition': 'needs attention',
        'location': 'house_darwin_003',
      },
    },
    {
      'id': 'census_animal_darwin_005',
      'name': 'Shadow',
      'species': 'Cat',
      'breed': 'Domestic Shorthair',
      'color': 'Black',
      'sex': 'Male',
      'estimatedAge': 1,
      'weight': 3.2,
      'houseId': 'house_darwin_003',
      'locationId': 'location_nt_001',
      'councilId': 'council_nt_001',
      'isActive': true,
      'registrationDate': now.subtract(Duration(days: 15)).toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'photoUrls': <String>[],
      'censusData': {
        'lastCount': now.subtract(Duration(days: 5)).toIso8601String(),
        'condition': 'healthy',
        'location': 'house_darwin_003',
      },
    },
    {
      'id': 'census_animal_darwin_006',
      'name': 'Max',
      'species': 'Dog',
      'breed': 'Beagle',
      'color': 'Tricolor',
      'sex': 'Male',
      'estimatedAge': 6,
      'weight': 15.0,
      'houseId': 'house_darwin_003',
      'locationId': 'location_nt_001',
      'councilId': 'council_nt_001',
      'isActive': true,
      'registrationDate': now.subtract(Duration(days: 120)).toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'photoUrls': <String>[],
      'censusData': {
        'lastCount': now.subtract(Duration(days: 8)).toIso8601String(),
        'condition': 'healthy',
        'location': 'house_darwin_003',
      },
    },
    {
      'id': 'census_animal_darwin_007',
      'name': 'Buddy',
      'species': 'Dog',
      'breed': 'Border Collie',
      'color': 'Black and White',
      'sex': 'Male',
      'estimatedAge': 8,
      'weight': 22.0,
      'houseId': 'house_darwin_004',
      'locationId': 'location_nt_001',
      'councilId': 'council_nt_001',
      'isActive': true,
      'registrationDate': now.subtract(Duration(days: 180)).toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'photoUrls': <String>[],
      'censusData': {
        'lastCount': now.subtract(Duration(days: 12)).toIso8601String(),
        'condition': 'needs attention',
        'location': 'house_darwin_004',
      },
    },
  ];

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
  debugPrint('Test census animal records created successfully');
}

// Helper functions for creating role-specific reports
Future<void> _createSystemAdminReports(dynamic redis, DateTime startDate, DateTime endDate) async {
  // User Activity Report
  final userActivityData = List.generate(20, (i) => {
    'timestamp': startDate.add(Duration(hours: i * 8)).toIso8601String(),
    'action': ['login_success', 'logout', 'data_export', 'user_created', 'settings_changed'][i % 5],
    'userId': 'user_${i % 4 + 1}',
    'userEmail': ['admin@amrric.com', 'municipal@amrric.com', 'vet@amrric.com', 'census@amrric.com'][i % 4],
    'userName': ['System Admin', 'Municipality Admin', 'Veterinary User', 'Census User'][i % 4],
    'userRole': ['systemAdmin', 'municipalityAdmin', 'veterinaryUser', 'censusUser'][i % 4],
    'details': 'Generated test activity',
    'ipAddress': '192.168.1.${i % 254 + 1}',
    'sessionId': 'session_${i}',
  });
  await redis.set('reports:systemAdmin:User Activity', jsonEncode(userActivityData));

  // System Usage Report
  final systemUsageData = List.generate(15, (i) => {
    'timestamp': startDate.add(Duration(hours: i * 12)).toIso8601String(),
    'action': ['login_success', 'logout'][i % 2],
    'userId': 'user_${i % 4 + 1}',
    'userEmail': ['admin@amrric.com', 'municipal@amrric.com', 'vet@amrric.com', 'census@amrric.com'][i % 4],
    'userName': ['System Admin', 'Municipality Admin', 'Veterinary User', 'Census User'][i % 4],
    'userRole': ['systemAdmin', 'municipalityAdmin', 'veterinaryUser', 'censusUser'][i % 4],
    'sessionDuration': i % 2 == 1 ? (30 + i * 5) : null,
    'sessionStartTime': i % 2 == 0 ? startDate.add(Duration(hours: i * 12)).toIso8601String() : null,
  });
  await redis.set('reports:systemAdmin:System Usage', jsonEncode(systemUsageData));

  // Data Retention Report
  final dataRetentionData = List.generate(10, (i) => {
    'dataType': ['Activity Log', 'User Profile', 'Animal Record', 'Treatment Record'][i % 4],
    'recordId': 'record_${i + 1}',
    'userId': 'user_${i % 4 + 1}',
    'userEmail': ['admin@amrric.com', 'municipal@amrric.com', 'vet@amrric.com', 'census@amrric.com'][i % 4],
    'timestamp': startDate.subtract(Duration(days: i * 30)).toIso8601String(),
    'ageInDays': i * 30,
    'dataSize': 1024 + i * 512,
    'retentionStatus': i > 12 ? 'Review Required' : 'Within Policy',
    'lastModified': startDate.subtract(Duration(days: i * 15)).toIso8601String(),
  });
  await redis.set('reports:systemAdmin:Data Retention', jsonEncode(dataRetentionData));

  // Audit Log Report
  final auditLogData = List.generate(25, (i) => {
    'timestamp': startDate.add(Duration(hours: i * 6)).toIso8601String(),
    'action': ['user_login', 'data_access', 'settings_change', 'report_generated', 'data_export'][i % 5],
    'userId': 'user_${i % 4 + 1}',
    'userEmail': ['admin@amrric.com', 'municipal@amrric.com', 'vet@amrric.com', 'census@amrric.com'][i % 4],
    'resource': ['users', 'animals', 'reports', 'settings', 'councils'][i % 5],
    'result': ['success', 'failed'][i % 10 == 0 ? 1 : 0],
    'ipAddress': '192.168.1.${i % 254 + 1}',
    'details': 'Test audit entry ${i + 1}',
  });
  await redis.set('reports:systemAdmin:Audit Log', jsonEncode(auditLogData));
}

Future<void> _createMunicipalityAdminReports(dynamic redis, DateTime startDate, DateTime endDate) async {
  // Municipality Overview Report
  final municipalityData = List.generate(7, (i) => {
    'date': startDate.add(Duration(days: i)).toIso8601String(),
    'totalAnimals': 45 + i * 2,
    'newRegistrations': i + 1,
    'activeIncidents': 2 + (i % 3),
    'completedTreatments': 5 + i,
    'councilId': 'council_nt_001',
    'locationId': 'location_nt_001',
    'staffActivity': 8 + (i % 4),
  });
  await redis.set('reports:municipalityAdmin:Municipality Overview', jsonEncode(municipalityData));

  // Animal Population Report
  final animalPopulationData = List.generate(7, (i) => {
    'date': startDate.add(Duration(days: i)).toIso8601String(),
    'species': ['Dog', 'Cat'][i % 2],
    'count': 20 + i * 3,
    'location': 'Darwin CBD',
    'status': 'active',
    'vaccinated': 18 + i * 2,
    'microchipped': 19 + i * 3,
  });
  await redis.set('reports:municipalityAdmin:Animal Population', jsonEncode(animalPopulationData));

  // Treatment Statistics Report
  final treatmentStatsData = List.generate(10, (i) => {
    'date': startDate.add(Duration(days: i)).toIso8601String(),
    'treatmentType': ['Vaccination', 'Dental', 'Surgery', 'Medication', 'Checkup'][i % 5],
    'count': 3 + (i % 5),
    'species': ['Dog', 'Cat'][i % 2],
    'status': ['completed', 'pending'][i % 8 == 0 ? 1 : 0],
    'cost': 100.0 + i * 25,
    'veterinarian': 'vet@amrric.com',
  });
  await redis.set('reports:municipalityAdmin:Treatment Statistics', jsonEncode(treatmentStatsData));

  // Census Data Report
  final censusData = List.generate(5, (i) => {
    'date': startDate.add(Duration(days: i * 2)).toIso8601String(),
    'location': 'Darwin CBD',
    'totalHouses': 25 + i,
    'housesWithAnimals': 20 + i,
    'totalAnimals': 47 + i * 3,
    'dogs': 28 + i * 2,
    'cats': 19 + i,
    'healthyAnimals': 42 + i * 2,
    'animalsNeedingAttention': 5 + (i % 3),
  });
  await redis.set('reports:municipalityAdmin:Census Data', jsonEncode(censusData));
}

Future<void> _createVeterinaryUserReports(dynamic redis, DateTime startDate, DateTime endDate) async {
  // Treatment Records Report
  final treatmentRecordsData = List.generate(15, (i) => {
    'date': startDate.add(Duration(hours: i * 8)).toIso8601String(),
    'animalId': 'animal_${i % 7 + 1}',
    'animalName': ['Rex', 'Bella', 'Whiskers', 'Fluffy', 'Shadow', 'Max', 'Buddy'][i % 7],
    'species': ['Dog', 'Cat'][i % 2],
    'treatmentType': ['Vaccination', 'Dental Cleaning', 'Surgery', 'Medication', 'Health Check'][i % 5],
    'status': ['completed', 'pending', 'scheduled'][i % 10 < 7 ? 0 : (i % 10 < 9 ? 1 : 2)],
    'veterinarian': 'vet@amrric.com',
    'cost': 75.0 + i * 15,
    'notes': 'Treatment completed successfully',
    'followUpRequired': i % 5 == 0,
  });
  await redis.set('reports:veterinaryUser:Treatment Records', jsonEncode(treatmentRecordsData));

  // Animal Health Report
  final animalHealthData = List.generate(12, (i) => {
    'animalId': 'animal_${i % 7 + 1}',
    'animalName': ['Rex', 'Bella', 'Whiskers', 'Fluffy', 'Shadow', 'Max', 'Buddy'][i % 7],
    'species': ['Dog', 'Cat'][i % 2],
    'lastCheckup': startDate.subtract(Duration(days: i * 5)).toIso8601String(),
    'healthStatus': ['Excellent', 'Good', 'Fair', 'Poor'][i % 4],
    'weight': 15.0 + i * 2.5,
    'vaccinations': ['Up to date', 'Overdue'][i % 8 == 0 ? 1 : 0],
    'conditions': i % 4 == 0 ? ['Dental disease'] : [],
    'nextCheckup': endDate.add(Duration(days: i * 7)).toIso8601String(),
  });
  await redis.set('reports:veterinaryUser:Animal Health', jsonEncode(animalHealthData));

  // Medication Usage Report
  final medicationUsageData = List.generate(18, (i) => {
    'date': startDate.add(Duration(days: i % 7)).toIso8601String(),
    'medicationName': ['Heartworm Prevention', 'Flea Treatment', 'Antibiotics', 'Pain Relief', 'Vitamins'][i % 5],
    'animalId': 'animal_${i % 7 + 1}',
    'animalName': ['Rex', 'Bella', 'Whiskers', 'Fluffy', 'Shadow', 'Max', 'Buddy'][i % 7],
    'dosage': '${i + 1}mg',
    'frequency': ['Daily', 'Weekly', 'Monthly'][i % 3],
    'startDate': startDate.add(Duration(days: i % 7)).toIso8601String(),
    'endDate': startDate.add(Duration(days: (i % 7) + 14)).toIso8601String(),
    'prescribedBy': 'vet@amrric.com',
    'status': ['Active', 'Completed'][i % 6 == 0 ? 1 : 0],
  });
  await redis.set('reports:veterinaryUser:Medication Usage', jsonEncode(medicationUsageData));

  // Veterinary Services Report
  final vetServicesData = List.generate(8, (i) => {
    'date': startDate.add(Duration(days: i)).toIso8601String(),
    'serviceType': ['Consultation', 'Vaccination', 'Surgery', 'Emergency'][i % 4],
    'count': 3 + (i % 5),
    'totalCost': 300.0 + i * 50,
    'averageDuration': 45 + i * 15,
    'satisfaction': 4.5 - (i % 3) * 0.2,
    'location': 'Darwin CBD',
  });
  await redis.set('reports:veterinaryUser:Veterinary Services', jsonEncode(vetServicesData));
}

Future<void> _createCensusUserReports(dynamic redis, DateTime startDate, DateTime endDate) async {
  // Population Census Report
  final populationCensusData = List.generate(7, (i) => {
    'date': startDate.add(Duration(days: i)).toIso8601String(),
    'location': 'Darwin CBD',
    'totalAnimals': 47 + i * 2,
    'species': ['Dog', 'Cat'][i % 2],
    'count': i % 2 == 0 ? 28 + i : 19 + i,
    'healthStatus': ['Healthy', 'Needs Attention'][i % 5 == 0 ? 1 : 0],
    'microchipped': i % 2 == 0 ? 26 + i : 18 + i,
    'vaccinated': i % 2 == 0 ? 25 + i : 17 + i,
    'censusBy': 'census@amrric.com',
  });
  await redis.set('reports:censusUser:Population Census', jsonEncode(populationCensusData));

  // Animal Distribution Report
  final animalDistributionData = List.generate(10, (i) => {
    'houseId': 'house_darwin_00${(i % 5) + 1}',
    'address': ['123 Mitchell Street', '45 Smith Street', '78 Knuckey Street', '12 Cavenagh Street', '34 Bennett Street'][i % 5],
    'animalCount': 1 + (i % 3),
    'dogs': i % 3 == 0 ? 1 + (i % 2) : 0,
    'cats': i % 3 != 0 ? 1 : 0,
    'lastCensus': startDate.add(Duration(days: i % 7)).toIso8601String(),
    'condition': ['Good', 'Needs Attention'][i % 8 == 0 ? 1 : 0],
    'location': 'Darwin CBD',
  });
  await redis.set('reports:censusUser:Animal Distribution', jsonEncode(animalDistributionData));

  // Breed Statistics Report
  final breedStatsData = List.generate(12, (i) => {
    'species': ['Dog', 'Cat'][i % 2],
    'breed': i % 2 == 0 ? 
      ['German Shepherd', 'Labrador', 'Beagle', 'Border Collie', 'Mixed Breed', 'Golden Retriever'][i % 6] :
      ['Domestic Shorthair', 'Persian', 'Siamese', 'Maine Coon', 'British Shorthair', 'Ragdoll'][i % 6],
    'count': 3 + (i % 5),
    'averageAge': 3.5 + (i % 4),
    'healthStatus': ['Excellent', 'Good', 'Fair'][i % 3],
    'location': 'Darwin CBD',
    'lastUpdated': startDate.add(Duration(days: i % 7)).toIso8601String(),
  });
  await redis.set('reports:censusUser:Breed Statistics', jsonEncode(breedStatsData));

  // Location Data Report
  final locationData = List.generate(5, (i) => {
    'date': startDate.add(Duration(days: i)).toIso8601String(),
    'location': 'Darwin CBD',
    'totalHouses': 25 + i,
    'housesVisited': 20 + i,
    'housesWithAnimals': 18 + i,
    'animalsFound': 45 + i * 3,
    'newAnimals': 2 + (i % 3),
    'healthChecks': 40 + i * 2,
    'vaccinationsNeeded': 5 + (i % 4),
    'censusProgress': ((20 + i) / (25 + i) * 100).round(),
  });
  await redis.set('reports:censusUser:Location Data', jsonEncode(locationData));
}