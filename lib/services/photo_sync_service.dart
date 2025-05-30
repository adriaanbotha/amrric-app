import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class PhotoSyncService {
  final Redis _redis;
  final Box<Map<dynamic, dynamic>> _localBox;
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();

  PhotoSyncService(this._redis, this._localBox);

  Future<void> savePhoto({
    required String userId,
    required String photoId,
    required Map<String, dynamic> photoData,
    required String filePath,
  }) async {
    try {
      // Read file as bytes and encode as base64
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final updatedPhotoData = Map<String, dynamic>.from(photoData)
        ..['base64'] = base64Data;

      // Always save to local storage first
      await _localBox.put(photoId, updatedPhotoData);
      _logger.i('Saved photo to local storage: $photoId');

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // If online, save to Upstash and remove local file and record
        final key = 'user:$userId:photo:$photoId';
        print('[savePhoto] Saving photo to Upstash: userId=$userId, photoId=$photoId, key=$key, base64 length=${base64Data.length}');
        await _redis.set(key, jsonEncode(updatedPhotoData));
        print('[savePhoto] Saved photo to Upstash: $key');
        await _localBox.delete(photoId);
        if (await file.exists()) await file.delete();
      } else {
        _logger.w('Offline mode: Photo saved locally only');
      }
    } catch (e) {
      print('[savePhoto] Error saving photo to Upstash: $e');
      _logger.e('Error saving photo: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getPhoto({
    required String userId,
    required String photoId,
    required String filePath,
  }) async {
    try {
      print('[getPhoto] Checking local file: $filePath');
      final file = File(filePath);
      if (await file.exists()) {
        print('[getPhoto] Local file exists: $filePath');
        final localData = _localBox.get(photoId);
        if (localData != null) {
          print('[getPhoto] Returning local data for $photoId');
          return Map<String, dynamic>.from(localData);
        }
      }

      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('[getPhoto] Online, fetching from Upstash: user:$userId:photo:$photoId');
        final key = 'user:$userId:photo:$photoId';
        final upstashData = await _redis.get(key);
        Map<String, dynamic>? data;
        if (upstashData is String) {
          data = jsonDecode(upstashData) as Map<String, dynamic>;
        } else if (upstashData is Map) {
          data = Map<String, dynamic>.from(upstashData);
        } else {
          data = null;
        }
        if (data != null) {
          print('[getPhoto] Got data from Upstash for $photoId');
          if (!await file.exists() && data['base64'] != null) {
            final bytes = base64Decode(data['base64']);
            await file.writeAsBytes(bytes);
            print('[getPhoto] Wrote file to $filePath');
          }
          await _localBox.put(photoId, data);
          return data;
        } else {
          print('[getPhoto] No data found in Upstash for $photoId');
        }
      }

      final localData = _localBox.get(photoId);
      if (localData == null) {
        print('[getPhoto] No local data for $photoId');
        return null;
      }
      print('[getPhoto] Returning fallback local data for $photoId');
      return Map<String, dynamic>.from(localData);
    } catch (e) {
      print('[getPhoto] Error: $e');
      _logger.e('Error getting photo: $e');
      rethrow;
    }
  }

  Future<void> deletePhoto(String userId, String photoId) async {
    try {
      // Delete from local storage
      await _localBox.delete(photoId);
      _logger.i('Deleted photo from local storage: $photoId');

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // If online, delete from Upstash
        final key = 'user:$userId:photo:$photoId';
        await _redis.del([key]);
        _logger.i('Deleted photo from Upstash: $photoId');
      } else {
        _logger.w('Offline mode: Photo deleted locally only');
      }
    } catch (e) {
      _logger.e('Error deleting photo: $e');
      rethrow;
    }
  }

  Future<void> syncLocalToUpstash() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _logger.w('Cannot sync: No internet connection');
        return;
      }

      // Get all local photos
      final localPhotos = _localBox.toMap();
      
      // Sync each photo to Upstash
      for (final entry in localPhotos.entries) {
        final photoId = entry.key;
        final photoData = entry.value;
        final userId = photoData['userId'];
        final filePath = photoData['path'];
        if (userId == null || filePath == null) {
          _logger.w('Skipping photo $photoId due to missing userId or path');
          await _localBox.delete(photoId);
          continue;
        }
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64Data = base64Encode(bytes);
          final updatedPhotoData = Map<String, dynamic>.from(photoData)
            ..['base64'] = base64Data;
          final key = 'user:$userId:photo:$photoId';
          await _redis.set(key, jsonEncode(updatedPhotoData));
          _logger.i('Synced photo to Upstash: $photoId');
          await _localBox.delete(photoId);
          await file.delete();
        }
      }
      _logger.i('Sync completed successfully');
    } catch (e) {
      _logger.e('Error syncing to Upstash: $e');
      rethrow;
    }
  }

  // Returns the number of photos pending sync (i.e., in local storage)
  Future<int> getPendingSyncCount() async {
    return _localBox.length;
  }

  // Returns a list of photo paths for a given animalId from local storage
  Future<List<String>> getAnimalPhotos(String animalId) async {
    final photos = <String>[];
    for (final entry in _localBox.toMap().entries) {
      final data = entry.value;
      if (data['animalId'] == animalId && data['path'] != null) {
        photos.add(data['path'] as String);
      }
    }
    return photos;
  }

  // Update queuePhotoForSync to include userId and read file as base64
  Future<void> queuePhotoForSync(String animalId, String photoPath, String userId) async {
    final photoId = photoPath.split('/').last;
    final file = File(photoPath);
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);
    final photoData = {
      'animalId': animalId,
      'userId': userId,
      'path': photoPath,
      'createdAt': DateTime.now().toIso8601String(),
      'base64': base64Data,
    };
    await _localBox.put(photoId, photoData);
    _logger.i('Queued photo for sync: $photoId');
  }

  // Syncs all local photos to Upstash and reports progress via onProgress callback
  Future<void> syncPhotos({Function(double)? onProgress}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _logger.w('Cannot sync: No internet connection');
        return;
      }

      final localPhotos = _localBox.toMap();
      final total = localPhotos.length;
      var synced = 0;

      for (final entry in localPhotos.entries) {
        final photoId = entry.key;
        final photoData = entry.value;
        final userId = photoData['userId'];
        final filePath = photoData['path'];
        if (userId == null || filePath == null) {
          _logger.w('Skipping photo $photoId due to missing userId or path');
          await _localBox.delete(photoId);
          synced++;
          if (onProgress != null) {
            onProgress(synced / total);
          }
          continue;
        }
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64Data = base64Encode(bytes);
          final updatedPhotoData = Map<String, dynamic>.from(photoData)
            ..['base64'] = base64Data;
          final key = 'user:$userId:photo:$photoId';
          print('[syncPhotos] Saving photo to Upstash: userId=$userId, photoId=$photoId, key=$key, base64 length=${base64Data.length}');
          await _redis.set(key, jsonEncode(updatedPhotoData));
          print('[syncPhotos] Saved photo to Upstash: $key');
          await _localBox.delete(photoId);
          await file.delete();
        }
        synced++;
        if (onProgress != null) {
          onProgress(synced / total);
        }
      }
      _logger.i('Sync completed successfully');
    } catch (e) {
      print('[syncPhotos] Error saving photo to Upstash: $e');
      _logger.e('Error syncing photos: $e');
      rethrow;
    }
  }

  Future<void> clearLocalPhotos() async {
    await _localBox.clear();
  }

  Future<void> deletePhotosForAnimal(String animalId) async {
    try {
      // Delete from local storage
      final toDelete = <String>[];
      for (final entry in _localBox.toMap().entries) {
        final data = entry.value;
        if (data['animalId'] == animalId) {
          toDelete.add(entry.key);
        }
      }
      for (final photoId in toDelete) {
        final data = _localBox.get(photoId);
        if (data != null && data['userId'] != null) {
          await deletePhoto(data['userId'], photoId);
        } else {
          await _localBox.delete(photoId);
        }
      }
      _logger.i('Deleted all photos for animal $animalId');
    } catch (e) {
      _logger.e('Error deleting photos for animal $animalId: $e');
      rethrow;
    }
  }
} 