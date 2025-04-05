import 'package:flutter_test/flutter_test.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'test_helper.dart';

void main() {
  late Redis redis;
  late AuthService authService;
  late AnimalService animalService;

  setUp(() async {
    redis = await setupTestRedis();
    authService = AuthService(redis);
    animalService = AnimalService(redis, authService);
  });

  group('Animal Management Tests', () {
    test('Create and retrieve animal as system admin', () async {
      // Login as system admin
      await authService.login('admin@amrric.com', 'admin123');

      // Create test animal
      final animal = Animal(
        id: 'test_animal_1',
        name: 'Test Dog 1',
        species: 'Dog',
        breed: 'Labrador',
        color: 'Black',
        sex: 'Male',
        estimatedAge: 2,
        weight: 25.5,
        microchipNumber: '123456789',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house_1',
        locationId: 'location_1',
        councilId: 'council_1',
        ownerId: 'owner_1',
        photoUrls: ['https://example.com/photo1.jpg'],
        medicalHistory: {
          'vaccinations': ['rabies', 'parvo'],
          'lastCheckup': DateTime.now().toIso8601String(),
        },
        censusData: {
          'lastCount': DateTime.now().toIso8601String(),
          'condition': 'healthy',
        },
        metadata: {
          'notes': 'Test animal for system admin',
        },
      );

      // Add animal
      final createdAnimal = await animalService.addAnimal(animal);
      expect(createdAnimal.id, equals(animal.id));
      expect(createdAnimal.species, equals(animal.species));

      // Retrieve animals
      final animals = await animalService.getAnimals();
      expect(animals, isNotEmpty);
      expect(animals.any((a) => a.id == animal.id), isTrue);
    });

    test('Municipality admin can only see their council animals', () async {
      // Login as municipality admin
      await authService.login('municipal@amrric.com', 'municipal123');

      // Create test animals for different councils
      final animalInCouncil = Animal(
        id: 'test_animal_2',
        name: 'Test Cat 1',
        species: 'Cat',
        breed: 'Siamese',
        color: 'White',
        sex: 'Female',
        estimatedAge: 1,
        weight: 4.5,
        microchipNumber: '987654321',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house_2',
        locationId: 'location_2',
        councilId: 'council1',
        ownerId: 'owner_2',
        photoUrls: ['https://example.com/photo2.jpg'],
        medicalHistory: {
          'vaccinations': ['feline leukemia'],
          'lastCheckup': DateTime.now().toIso8601String(),
        },
        censusData: {
          'lastCount': DateTime.now().toIso8601String(),
          'condition': 'healthy',
        },
        metadata: {
          'notes': 'Test animal for municipality admin',
        },
      );

      final animalOtherCouncil = Animal(
        id: 'test_animal_3',
        name: 'Test Dog 2',
        species: 'Dog',
        breed: 'German Shepherd',
        color: 'Brown',
        sex: 'Male',
        estimatedAge: 3,
        weight: 30.0,
        microchipNumber: '456789123',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house_3',
        locationId: 'location_3',
        councilId: 'different_council',
        ownerId: 'owner_3',
        photoUrls: ['https://example.com/photo3.jpg'],
        medicalHistory: {
          'vaccinations': ['rabies', 'distemper'],
          'lastCheckup': DateTime.now().toIso8601String(),
        },
        censusData: {
          'lastCount': DateTime.now().toIso8601String(),
          'condition': 'healthy',
        },
        metadata: {
          'notes': 'Test animal for different council',
        },
      );

      // Login as admin to create animals
      await authService.login('admin@amrric.com', 'admin123');
      await animalService.addAnimal(animalInCouncil);
      await animalService.addAnimal(animalOtherCouncil);

      // Login back as municipality admin
      await authService.login('municipal@amrric.com', 'municipal123');
      final animals = await animalService.getAnimals();

      expect(animals.length, equals(1));
      expect(animals.first.councilId, equals(authService.currentUser!.municipalityId));
    });

    test('Veterinary user can see all animals', () async {
      // Login as vet
      await authService.login('vet@amrric.com', 'vet123');

      // Create test animals with and without medical records
      final animalWithMedical = Animal(
        id: 'test_animal_4',
        name: 'Test Dog 3',
        species: 'Dog',
        breed: 'Golden Retriever',
        color: 'Golden',
        sex: 'Female',
        estimatedAge: 4,
        weight: 28.0,
        microchipNumber: '789123456',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house_4',
        locationId: 'location_4',
        councilId: 'council_1',
        ownerId: 'owner_4',
        photoUrls: ['https://example.com/photo4.jpg'],
        medicalHistory: {
          'vaccinations': ['rabies', 'parvo', 'distemper'],
          'lastCheckup': DateTime.now().toIso8601String(),
          'treatments': ['flea treatment', 'deworming'],
        },
        censusData: {
          'lastCount': DateTime.now().toIso8601String(),
          'condition': 'healthy',
        },
        metadata: {
          'notes': 'Test animal with medical records',
        },
      );

      final animalWithoutMedical = Animal(
        id: 'test_animal_5',
        name: 'Test Cat 2',
        species: 'Cat',
        breed: 'Persian',
        color: 'Gray',
        sex: 'Male',
        estimatedAge: 2,
        weight: 5.0,
        microchipNumber: '321654987',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house_5',
        locationId: 'location_5',
        councilId: 'council_1',
        ownerId: 'owner_5',
        photoUrls: ['https://example.com/photo5.jpg'],
        censusData: {
          'lastCount': DateTime.now().toIso8601String(),
          'condition': 'healthy',
        },
        metadata: {
          'notes': 'Test animal without medical records',
        },
      );

      // Reset the Redis database to ensure clean test environment
      await redis.del(await redis.keys('animal:*'));
      await redis.del(['animals']);

      // Login as admin to create animals
      await authService.login('admin@amrric.com', 'admin123');
      await animalService.addAnimal(animalWithMedical);
      await animalService.addAnimal(animalWithoutMedical);

      // Login back as vet
      await authService.login('vet@amrric.com', 'vet123');
      final animals = await animalService.getAnimals();

      // Vet should now see all animals
      expect(animals.length, equals(2));
      expect(animals.any((a) => a.id == animalWithMedical.id), isTrue);
      expect(animals.any((a) => a.id == animalWithoutMedical.id), isTrue);
    });

    test('Census user can see basic animal data', () async {
      // Login as census user
      await authService.login('census@amrric.com', 'census123');
      
      // Reset the Redis database to ensure clean test environment
      await redis.del(await redis.keys('animal:*'));
      await redis.del(['animals']);

      // The location ID for census test
      final testLocationId = 'location_6';
      
      // Set location ID for census user
      final censusUser = authService.currentUser!;
      await redis.hset('user:${censusUser.email}', {'locationId': testLocationId});
      
      // Create test animal
      final animal = Animal(
        id: 'test_animal_6',
        name: 'Test Dog 4',
        species: 'Dog',
        breed: 'Beagle',
        color: 'Tricolor',
        sex: 'Male',
        estimatedAge: 1,
        weight: 12.0,
        microchipNumber: '654987321',
        registrationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        houseId: 'house_6',
        locationId: testLocationId,
        councilId: 'council_1',
        ownerId: 'owner_6',
        photoUrls: ['https://example.com/photo6.jpg'],
        censusData: {
          'lastCount': DateTime.now().toIso8601String(),
          'condition': 'healthy',
          'location': 'house_6',
        },
        metadata: {
          'notes': 'Test animal for census user',
        },
      );

      // Login as admin to create animal
      await authService.login('admin@amrric.com', 'admin123');
      await animalService.addAnimal(animal);

      // Login back as census user
      await authService.login('census@amrric.com', 'census123');
      final animals = await animalService.getAnimalsByBasicInfo();

      expect(animals.length, equals(1));
      expect(animals.first.id, equals(animal.id));
      expect(animals.first.locationId, equals(testLocationId));
    });

    test('Incremental search filters animals correctly', () async {
      // Login as admin
      await authService.login('admin@amrric.com', 'admin123');
      
      // Create test animals with different names, species, and breeds
      final animals = [
        Animal(
          id: 'search_animal_1',
          name: 'Buddy',
          species: 'Dog',
          breed: 'Labrador',
          color: 'Black',
          sex: 'Male',
          estimatedAge: 2,
          registrationDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          isActive: true,
          houseId: 'house_1',
          locationId: 'location_1',
          councilId: 'council_1',
          photoUrls: [],
        ),
        Animal(
          id: 'search_animal_2',
          name: 'Whiskers',
          species: 'Cat',
          breed: 'Siamese',
          color: 'White',
          sex: 'Female',
          estimatedAge: 3,
          registrationDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          isActive: true,
          houseId: 'house_1',
          locationId: 'location_1',
          councilId: 'council_1',
          photoUrls: [],
        ),
        Animal(
          id: 'search_animal_3',
          name: 'Rex',
          species: 'Dog',
          breed: 'German Shepherd',
          color: 'Brown',
          sex: 'Male',
          estimatedAge: 4,
          registrationDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          isActive: true,
          houseId: 'house_1',
          locationId: 'location_1',
          councilId: 'council_1',
          photoUrls: [],
        ),
      ];
      
      // Reset the Redis database to ensure clean test environment
      await redis.del(await redis.keys('animal:*'));
      await redis.del(['animals']);
      
      // Add all animals
      for (final animal in animals) {
        await animalService.addAnimal(animal);
      }
      
      // Create a mock AnimalManagementScreen state to test search
      final mockSearchQuery = 'lab'; // Should match Labrador
      final allAnimals = await animalService.getAnimals();
      
      // Manually filter the way the UI would
      final filteredAnimals = allAnimals.where((animal) {
        final name = animal.name?.toLowerCase() ?? '';
        final species = animal.species.toLowerCase();
        final breed = animal.breed?.toLowerCase() ?? '';
        final id = animal.id.toLowerCase();
        
        return name.contains(mockSearchQuery) || 
               species.contains(mockSearchQuery) || 
               breed.contains(mockSearchQuery) ||
               id.contains(mockSearchQuery);
      }).toList();
      
      // Verify filtering works correctly - should find only the Labrador
      expect(filteredAnimals.length, equals(1));
      expect(filteredAnimals.first.breed, equals('Labrador'));
      
      // Test another search term
      final catSearchQuery = 'cat';
      final catFilteredAnimals = allAnimals.where((animal) {
        final name = animal.name?.toLowerCase() ?? '';
        final species = animal.species.toLowerCase();
        final breed = animal.breed?.toLowerCase() ?? '';
        final id = animal.id.toLowerCase();
        
        return name.contains(catSearchQuery) || 
               species.contains(catSearchQuery) || 
               breed.contains(catSearchQuery) ||
               id.contains(catSearchQuery);
      }).toList();
      
      expect(catFilteredAnimals.length, equals(1));
      expect(catFilteredAnimals.first.species, equals('Cat'));
    });
  });
} 