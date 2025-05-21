import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/services/photo_sync_service.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/providers/sync_status_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  late Box<Map<dynamic, dynamic>> _pendingBox;
  late Box<Map<dynamic, dynamic>> _localAnimalsBox;
  late PhotoSyncService _photoSyncService;
  late AnimalService _animalService;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _isSyncing = false;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(minutes: 5);
  late ProviderContainer _container;

  Future<void> init(PhotoSyncService photoSyncService, AnimalService animalService, ProviderContainer container) async {
    _pendingBox = await Hive.openBox<Map<dynamic, dynamic>>('pending_sync');
    _localAnimalsBox = await Hive.openBox<Map<dynamic, dynamic>>('local_animals');
    _photoSyncService = photoSyncService;
    _animalService = animalService;
    _container = container;
    _listenForConnectivity();
    await syncPending();
  }

  // Save animal locally and queue for sync
  Future<void> saveAnimalLocally(Animal animal) async {
    try {
      // Save to local storage
      await _localAnimalsBox.put('animal:${animal.id}', animal.toJson());
      
      // Add to pending sync queue
      await addPendingAnimal(animal);
      
      debugPrint('✅ Saved animal ${animal.id} locally');
    } catch (e) {
      debugPrint('❌ Error saving animal locally: $e');
      rethrow;
    }
  }

  // Get animal from local storage
  Future<Animal?> getLocalAnimal(String id) async {
    try {
      final data = _localAnimalsBox.get('animal:$id');
      if (data != null) {
        return Animal.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting local animal: $e');
      return null;
    }
  }

  // Get all local animals
  Future<List<Animal>> getAllLocalAnimals() async {
    try {
      final animals = <Animal>[];
      final keys = _localAnimalsBox.keys.where((k) => k.toString().startsWith('animal:'));
      
      for (final key in keys) {
        final data = _localAnimalsBox.get(key);
        if (data != null) {
          animals.add(Animal.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      
      return animals;
    } catch (e) {
      debugPrint('❌ Error getting local animals: $e');
      return [];
    }
  }

  Future<void> addPendingAnimal(Animal animal) async {
    await _pendingBox.put('animal:${animal.id}', animal.toJson());
  }

  Future<void> removePendingAnimal(String animalId) async {
    await _pendingBox.delete('animal:$animalId');
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        debugPrint('⚠️ No internet connection, skipping sync');
        _container.read(syncStatusProvider.notifier).setError('No internet connection');
        _scheduleRetry();
        return;
      }

      _container.read(syncStatusProvider.notifier).setSyncing();
      final keys = _pendingBox.keys.where((k) => k.toString().startsWith('animal:'));
      debugPrint('🔄 Syncing ${keys.length} pending animals...');
      
      for (final key in keys) {
        final animalData = _pendingBox.get(key);
        if (animalData != null) {
          try {
            final animal = Animal.fromJson(Map<String, dynamic>.from(animalData));
            await _animalService.updateAnimal(animal);
            await removePendingAnimal(animal.id);
            debugPrint('✅ Synced animal ${animal.id} to Upstash');
          } catch (e) {
            debugPrint('❌ Failed to sync animal $key: $e');
            _container.read(syncStatusProvider.notifier).setError('Failed to sync animal: $e');
            _scheduleRetry();
          }
        }
      }

      // Sync photos
      await _photoSyncService.syncPhotos();
      _retryCount = 0; // Reset retry count on successful sync
      _container.read(syncStatusProvider.notifier).setSuccess();
    } catch (e) {
      debugPrint('❌ Error during sync: $e');
      _container.read(syncStatusProvider.notifier).setError('Sync failed: $e');
      _scheduleRetry();
    } finally {
      _isSyncing = false;
    }
  }

  void _scheduleRetry() {
    if (_retryCount < maxRetries) {
      _retryCount++;
      _retryTimer?.cancel();
      _retryTimer = Timer(retryDelay, () {
        debugPrint('🔄 Retrying sync (attempt $_retryCount of $maxRetries)...');
        syncPending();
      });
    } else {
      debugPrint('⚠️ Max retry attempts reached. Manual sync required.');
      _container.read(syncStatusProvider.notifier).setError('Max retry attempts reached');
    }
  }

  void _listenForConnectivity() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        debugPrint('🌐 Internet connection restored, attempting sync...');
        _container.read(syncStatusProvider.notifier).setIdle();
        syncPending();
      } else {
        _container.read(syncStatusProvider.notifier).setError('Offline mode');
      }
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
    _retryTimer?.cancel();
  }

  PhotoSyncService get photoSyncService => _photoSyncService;
} 