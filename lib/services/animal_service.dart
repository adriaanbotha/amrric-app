import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/sync_service.dart';
import 'package:amrric_app/utils/permission_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:amrric_app/services/photo_sync_service.dart';
import 'package:hive/hive.dart';
import 'package:amrric_app/models/animal_image.dart';

final animalsProvider = StateNotifierProvider<AnimalService, AsyncValue<List<Animal>>>((ref) {
  return AnimalService(ref.watch(authServiceProvider), ref.container);
});

class AnimalService extends StateNotifier<AsyncValue<List<Animal>>> {
  final AuthService _authService;
  final AnimalPermissions _permissions;
  late SyncService _syncService;
  bool _isInitialized = false;
  final ProviderContainer _container;

  AnimalService(this._authService, this._container) 
      : _permissions = AnimalPermissions(_authService),
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (!_isInitialized) {
      final photoBox = await Hive.openBox<Map<dynamic, dynamic>>('photos');
      _syncService = SyncService();
      await _syncService.init(
        PhotoSyncService(UpstashConfig.redis, photoBox),
        this,
        _container,
      );
      _isInitialized = true;
      loadAnimals();
    }
  }

  Future<void> loadAnimals() async {
    try {
      debugPrint('Loading animals...');
      state = const AsyncValue.loading();
      
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      List<Animal> animals;
      
      if (connectivity == ConnectivityResult.none) {
        // Load from local storage when offline
        debugPrint('📱 Offline mode: Loading animals from local storage');
        animals = await _syncService.getAllLocalAnimals();
      } else {
        // Load from Upstash when online
        debugPrint('🌐 Online mode: Loading animals from Upstash');
        animals = await getAnimals();
        
        // Update local storage with latest data
        for (final animal in animals) {
          await _syncService.saveAnimalLocally(animal);
        }
      }
      
      debugPrint('Loaded ${animals.length} animals');
      state = AsyncValue.data(animals);
    } catch (e, stack) {
      debugPrint('Error loading animals: $e\n$stack');
      state = AsyncValue.error(e, stack);
    }
  }

  // Create animal with role-based validation
  Future<Animal> addAnimal(Animal animal) async {
    if (!await _permissions.canCreateAnimal()) {
      throw Exception('Permission denied: Cannot create animal');
    }

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Ensure photoUrls are file names only
      final photoUrls = animal.photoUrls.map((url) => url.split('/').last).toList();
      final updatedAnimal = animal.copyWith(photoUrls: photoUrls);

      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      
      if (connectivity == ConnectivityResult.none) {
        // Save locally when offline
        debugPrint('📱 Offline mode: Saving animal locally');
        await _syncService.saveAnimalLocally(updatedAnimal);
        return updatedAnimal;
      }

      // Store the animal data in Upstash when online
      final animalData = updatedAnimal.toJson();
      final processedData = animalData.map((key, value) {
        if (value is Map || value is List) {
          return MapEntry(key, jsonEncode(value));
        }
        return MapEntry(key, value.toString());
      });

      await UpstashConfig.redis.hset(
        'animal:${updatedAnimal.id}',
        processedData,
      );

      // Add the animal ID to the set of all animals
      await UpstashConfig.redis.sadd('animals', [updatedAnimal.id]);

      // Add to indexes
      await UpstashConfig.redis.sadd('animals:all', [updatedAnimal.id]);
      await UpstashConfig.redis.sadd('animals:location:${updatedAnimal.locationId}', [updatedAnimal.id]);
      await UpstashConfig.redis.sadd('animals:house:${updatedAnimal.houseId}', [updatedAnimal.id]);

      if (user.role == UserRole.veterinaryUser) {
        await UpstashConfig.redis.sadd('animals:medical', [updatedAnimal.id]);
      }

      // Save locally as well
      await _syncService.saveAnimalLocally(updatedAnimal);

      debugPrint('Animal created successfully: ${updatedAnimal.id}');
      return updatedAnimal;
    } catch (e, stackTrace) {
      debugPrint('Error creating animal: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Animal>> getAnimals() async {
    try {
      debugPrint('Getting all animals');
      final keys = await UpstashConfig.redis.keys('animal:*');
      debugPrint('Found ${keys.length} animal keys');
      final animals = <Animal>[];

      for (final key in keys) {
        try {
          final data = await UpstashConfig.redis.hgetall(key);
          debugPrint('Animal data for $key: $data');
          if (data != null && data.isNotEmpty) {
            final jsonData = <String, dynamic>{};
            data.forEach((key, value) {
              if (key == 'metadata' && value != null) {
                try {
                  jsonData[key] = jsonDecode(value);
                } catch (e) {
                  debugPrint('Error decoding metadata: $e');
                  jsonData[key] = null;
                }
              } else {
                jsonData[key] = value;
              }
            });
            animals.add(Animal.fromJson(jsonData));
          }
        } catch (e) {
          debugPrint('Error processing animal $key: $e');
          continue;
        }
      }
      return animals;
    } catch (e, stack) {
      debugPrint('Error getting animals: $e\n$stack');
      rethrow;
    }
  }

  // Update animal with role-based validation
  Future<Animal> updateAnimal(Animal animal) async {
    if (!await _permissions.canEditAnimal()) {
      throw Exception('Permission denied: Cannot update animal');
    }

    try {
      // Ensure photoUrls are file names only
      final photoUrls = animal.photoUrls.map((url) => url.split('/').last).toList();
      final updatedAnimal = animal.copyWith(photoUrls: photoUrls);

      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      
      if (connectivity == ConnectivityResult.none) {
        // Save locally when offline
        debugPrint('📱 Offline mode: Saving animal update locally');
        await _syncService.saveAnimalLocally(updatedAnimal);
        return updatedAnimal;
      }

      final animalData = updatedAnimal.toJson();
      final id = updatedAnimal.id;

      // Convert complex types to JSON strings
      final processedData = animalData.map((key, value) {
        if (value is List || value is Map) {
          return MapEntry(key, jsonEncode(value));
        }
        return MapEntry(key, value.toString());
      });

      // Update the animal data in Upstash
      await UpstashConfig.redis.hset(
        'animal:$id',
        processedData,
      );

      // Save locally as well
      await _syncService.saveAnimalLocally(updatedAnimal);

      debugPrint('Animal updated successfully: $id');
      return updatedAnimal;
    } catch (e, stackTrace) {
      debugPrint('Error updating animal: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Delete animal with role-based validation
  Future<void> deleteAnimal(String id) async {
    if (!await _permissions.canDeleteAnimal()) {
      throw Exception('Permission denied: Cannot delete animal');
    }

    try {
      // Delete all photos for this animal
      await _syncService.photoSyncService.deletePhotosForAnimal(id);

      final animals = await getAnimals();
      animals.removeWhere((a) => a.id == id);
      await UpstashConfig.redis.set('animals', json.encode(animals.map((a) => a.toJson()).toList()));

      // Get animal data first to remove from indexes
      final animalData = await UpstashConfig.redis.hgetall('animal:$id');
      if (animalData != null && animalData.isNotEmpty) {
        final processedData = animalData.map((key, value) {
          if (value is String && (key == 'medicalHistory' || key == 'censusData' || key == 'metadata')) {
            try {
              return MapEntry(key, jsonDecode(value));
            } catch (e) {
              debugPrint('Error parsing $key: $e');
              return MapEntry(key, {});
            }
          }
          return MapEntry(key, value);
        });
        
        final animal = Animal.fromJson(processedData);

        // Remove from indexes
        await UpstashConfig.redis.srem('animals:all', [id]);
        await UpstashConfig.redis.srem('animals:location:${animal.locationId}', [id]);
        await UpstashConfig.redis.srem('animals:house:${animal.houseId}', [id]);
        await UpstashConfig.redis.srem('animals:medical', [id]);

        // Delete the animal data
        await UpstashConfig.redis.del(['animal:$id']);
      }

      debugPrint('Animal deleted successfully: $id');
    } catch (e, stackTrace) {
      debugPrint('Error deleting animal: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Add medical record with role validation
  Future<void> addMedicalRecord(String animalId, Map<String, dynamic> medicalData) async {
    if (!await _permissions.canAddMedicalRecords()) {
      throw Exception('Permission denied: Cannot add medical records');
    }

    try {
      final animal = await getAnimal(animalId);
      if (animal == null) throw Exception('Animal not found');

      final updatedMedicalHistory = {
        ...?animal.medicalHistory,
        DateTime.now().toIso8601String(): medicalData,
      };

      final updatedAnimal = animal.copyWith(
        medicalHistory: updatedMedicalHistory,
        lastUpdated: DateTime.now(),
      );

      await updateAnimal(updatedAnimal);
      await UpstashConfig.redis.sadd('animals:medical', [animalId]);

      debugPrint('Medical record added successfully for animal: $animalId');
    } catch (e, stackTrace) {
      debugPrint('Error adding medical record: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Animal?> getAnimal(String id) async {
    try {
      debugPrint('Getting animal: $id');
      final data = await UpstashConfig.redis.hgetall('animal:$id');
      if (data == null || data.isEmpty) return null;
      final jsonData = <String, dynamic>{};
      data.forEach((key, value) {
        if (key == 'metadata' && value != null) {
          try {
            jsonData[key] = jsonDecode(value);
          } catch (e) {
            debugPrint('Error decoding metadata: $e');
            jsonData[key] = null;
          }
        } else {
          jsonData[key] = value;
        }
      });
      return Animal.fromJson(jsonData);
    } catch (e, stack) {
      debugPrint('Error getting animal: $e\n$stack');
      rethrow;
    }
  }

  // Get statistics for the system or a specific council
  Future<Map<String, dynamic>> getStatistics(String? councilId) async {
    try {
      final animalIds = await UpstashConfig.redis.smembers('animals');
      int totalAnimals = 0;
      int activeAnimals = 0;
      int animalsWithMedicalRecords = 0;
      int totalCouncils = 0;

      for (final id in animalIds) {
        final animalData = await UpstashConfig.redis.hgetall('animal:$id');
        if (animalData == null || animalData.isEmpty) continue;

        try {
          final animal = Animal.fromJson(animalData);
          
          // Filter by council if specified
          if (councilId != null && animal.councilId != councilId) {
            continue;
          }

          totalAnimals++;
          if (animal.isActive) activeAnimals++;
          if (animal.medicalHistory != null && animal.medicalHistory!.isNotEmpty) {
            animalsWithMedicalRecords++;
          }
        } catch (e) {
          debugPrint('Error parsing animal data: $e');
          continue;
        }
      }

      // Get total councils if not filtering by council
      if (councilId == null) {
        final councils = await UpstashConfig.redis.smembers('councils');
        totalCouncils = councils.length;
      }

      return {
        'totalAnimals': totalAnimals,
        'activeAnimals': activeAnimals,
        'animalsWithMedicalRecords': animalsWithMedicalRecords,
        'totalCouncils': totalCouncils,
      };
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      rethrow;
    }
  }

  // Get all councils
  Future<List<String>> getCouncils() async {
    try {
      final councils = await UpstashConfig.redis.smembers('councils');
      return councils.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('Error getting councils: $e');
      rethrow;
    }
  }

  // Get animals by council
  Future<List<Animal>> getAnimalsByCouncil(String? councilId) async => getAnimals();

  // Get animals with medical focus
  Future<List<Animal>> getAnimalsWithMedicalFocus() async => getAnimals();

  // Get animals with basic info only
  Future<List<Animal>> getAnimalsByBasicInfo() async => getAnimals();

  Future<List<Animal>> getAnimalsByLocation(String locationId) async => getAnimals();

  Future<Animal?> getAnimalById(String id) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Online: Fetch from Upstash
        final animalData = await UpstashConfig.redis.hgetall('animal:$id');
        if (animalData == null || animalData.isEmpty) return null;

        final animal = Animal.fromJson(animalData);
        // Fetch images from Upstash
        final imageKeys = await UpstashConfig.redis.smembers('animal:$id:images');
        final images = await Future.wait(
          imageKeys.map((key) => UpstashConfig.redis.hgetall(key)).toList(),
        );
        animal.images = images
            .where((img) => img != null && img.isNotEmpty)
            .map((img) => AnimalImage.fromJson(img!))
            .toList();
        return animal;
      } else {
        // Offline: Fetch from local storage (Hive)
        final animalBox = await Hive.openBox<Animal>('animals');
        final animal = animalBox.get(id);
        // Skip image retrieval in offline mode
        return animal;
      }
    } catch (e) {
      debugPrint('Error getting animal: $e');
      return null;
    }
  }
} 