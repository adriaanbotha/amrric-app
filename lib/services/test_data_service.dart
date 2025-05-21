import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';

class TestDataService {
  final GetIt ref = GetIt.I<GetIt>();

  Future<void> createTestAnimals() async {
    debugPrint('Creating test animals...');
    
    final animalService = ref.read(animalsProvider.notifier);
    
    // Create test animals
    final testAnimals = [
      Animal(
        id: 'animal1',
        name: 'Max',
        species: 'Dog',
        breed: 'Mixed',
        color: 'Brown',
        sex: 'Male',
        estimatedAge: 3,
        weight: 15.5,
        microchipNumber: 'CHIP001',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house1',
        locationId: 'location_6',
        councilId: 'council1',
        ownerId: 'owner1',
        photoUrls: ['https://example.com/max.jpg'],
        medicalHistory: {
          'vaccinations': {
            'rabies': '2024-01-01',
            'dhpp': '2024-02-01',
          }
        },
        censusData: {
          'lastCensus': '2024-03-01',
          'condition': 'good',
        },
        metadata: {
          'notes': 'Friendly dog',
        },
      ),
      Animal(
        id: 'animal2',
        name: 'Luna',
        species: 'Cat',
        breed: 'Domestic Shorthair',
        color: 'Black',
        sex: 'Female',
        estimatedAge: 2,
        weight: 4.2,
        microchipNumber: 'CHIP002',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house2',
        locationId: 'location_6',
        councilId: 'council1',
        ownerId: 'owner2',
        photoUrls: ['https://example.com/luna.jpg'],
        medicalHistory: {
          'vaccinations': {
            'fvrcp': '2024-01-15',
            'rabies': '2024-02-15',
          }
        },
        censusData: {
          'lastCensus': '2024-03-01',
          'condition': 'excellent',
        },
        metadata: {
          'notes': 'Indoor cat',
        },
      ),
      Animal(
        id: 'animal3',
        name: 'Rocky',
        species: 'Dog',
        breed: 'German Shepherd',
        color: 'Black and Tan',
        sex: 'Male',
        estimatedAge: 4,
        weight: 30.0,
        microchipNumber: 'CHIP003',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house3',
        locationId: 'location_7',
        councilId: 'council2',
        ownerId: 'owner3',
        photoUrls: ['https://example.com/rocky.jpg'],
        medicalHistory: {
          'vaccinations': {
            'rabies': '2024-01-20',
            'dhpp': '2024-02-20',
          }
        },
        censusData: {
          'lastCensus': '2024-03-01',
          'condition': 'good',
        },
        metadata: {
          'notes': 'Guard dog',
        },
      ),
    ];

    // Add each test animal
    for (final animal in testAnimals) {
      try {
        await animalService.addAnimal(animal);
        debugPrint('Created test animal: ${animal.name}');
      } catch (e) {
        debugPrint('Error creating test animal ${animal.name}: $e');
      }
    }

    debugPrint('Test animals created successfully');
  }

  Future<void> fixCouncilLocationsStructure(String councilId) async {
    // Delete the key so it can be recreated as a set
    await _redis.del('council:$councilId:locations');
  }

  Future<void> createTestCouncils() async {
    debugPrint('Creating test councils...');
    
    // Clear existing councils
    await _redis.del('councils');
    debugPrint('Cleared existing councils');

    // Create test councils
    final testCouncils = [
      Council(
        id: 'council1',
        name: 'Darwin City Council',
        state: 'NT',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=1',
      ),
      Council(
        id: 'council2',
        name: 'Alice Springs Town Council',
        state: 'NT',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=2',
      ),
      Council(
        id: 'council3',
        name: 'Katherine Town Council',
        state: 'NT',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=3',
      ),
    ];

    // Add each council
    for (final council in testCouncils) {
      try {
        debugPrint('Converting Council to JSON: $council');
        await fixCouncilLocationsStructure(council.id);
        await _redis.hset('council:${council.id}', council.toJson());
        await _redis.sadd('councils', [council.id]);
        debugPrint('Created council: ${council.name}');
      } catch (e) {
        debugPrint('Error creating council ${council.name}: $e');
      }
    }

    debugPrint('All test councils created successfully');
  }

  Future<void> createTestUsers() async {
    debugPrint('Creating test users...');
    final authService = ref.read(authServiceProvider);

    final testUsers = [
      {
        'email': 'admin@amrric.com',
        'password': 'admin123',
        'name': 'Admin User',
        'role': UserRole.admin,
        'councilId': 'council1',
      },
      {
        'email': 'vet@amrric.com',
        'password': 'vet123',
        'name': 'Vet User',
        'role': UserRole.veterinaryUser,
        'councilId': 'council1',
      },
      {
        'email': 'user@amrric.com',
        'password': 'user123',
        'name': 'Regular User',
        'role': UserRole.user,
        'councilId': 'council2',
      },
    ];

    for (final user in testUsers) {
      try {
        await authService.createUser(
          email: user['email'] as String,
          password: user['password'] as String,
          name: user['name'] as String,
          role: user['role'] as UserRole,
          councilId: user['councilId'] as String,
        );
        debugPrint('Created test user: ${user['email']}');
      } catch (e) {
        debugPrint('Error creating test user ${user['email']}: $e');
      }
    }
    debugPrint('Test users created successfully');
  }

  Future<void> createTestData() async {
    try {
      debugPrint('Starting test data creation...');
      
      await createTestUsers();
      await createTestCouncils();
      await createTestAnimals();
      
      debugPrint('\nVerifying test data...\n');
      await verifyTestData();
      
      debugPrint('Test data created successfully');
    } catch (e) {
      debugPrint('Error creating test data: $e');
      rethrow;
    }
  }
} 