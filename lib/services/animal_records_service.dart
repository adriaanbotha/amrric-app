import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/user.dart';

class AnimalRecordsService {
  static const String _recordsPrefix = 'animal_record';
  static const String _recordsIndexPrefix = 'animal_records';
  static const String _typeIndexPrefix = 'records';

  // Record Types
  static const String typeCondition = 'condition';
  static const String typeBehaviour = 'behaviour';
  static const String typeComment = 'comment';
  static const String typeClinicalNotes = 'clinical_notes';

  // Predefined Conditions
  static const List<String> conditions = [
    'Healthy',
    'Injured',
    'Sick',
    'Malnourished',
    'Pregnant',
    'Nursing',
    'Deceased',
    'Needs Attention',
    'Under Treatment',
    'Recovering',
    'Critical',
    'Stable',
  ];

  // Predefined Behaviours - organized by categories
  static const List<String> behaviours = [
    // General Behaviors
    'Roaming',
    'Hunting',
    'Barking',
    'Fearful',
    
    // Chasing Behaviors
    'Chasing Dogs',
    'Chasing',
    'Chasing Bikes',
    'Chasing Cars',
    
    // Threatening Behaviors
    'Threatening Dogs',
    'Threatening',
    
    // Biting Behaviors
    'Biting',
    'Biting Dogs',
    'Biting People',
  ];

  // Behavior categories for better organization
  static const Map<String, List<String>> behaviourCategories = {
    'General': ['Roaming', 'Hunting', 'Barking', 'Fearful'],
    'Chasing': ['Chasing Dogs', 'Chasing', 'Chasing Bikes', 'Chasing Cars'],
    'Threatening': ['Threatening Dogs', 'Threatening'],
    'Biting': ['Biting', 'Biting Dogs', 'Biting People'],
  };

  /// Add a new record for an animal
  Future<String> addRecord({
    required String animalId,
    required String recordType,
    required String description,
    required User author,
    String? specificValue, // For condition/behaviour selection
    String? notes,
    String? locationId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final recordId = '${recordType}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Validate record type
      if (!_isValidRecordType(recordType)) {
        throw ArgumentError('Invalid record type: $recordType');
      }

      // Validate specific values for condition/behaviour
      if (recordType == typeCondition && specificValue != null) {
        // For condition assessments, allow summaries or predefined conditions
        if (!conditions.contains(specificValue) && !specificValue.contains('Body:')) {
          throw ArgumentError('Invalid condition: $specificValue');
        }
      }
      
      if (recordType == typeBehaviour && specificValue != null) {
        if (!behaviours.contains(specificValue)) {
          throw ArgumentError('Invalid behaviour: $specificValue');
        }
      }

      // Create record data
      final record = {
        'id': recordId,
        'animalId': animalId,
        'type': recordType,
        'description': description,
        'specificValue': specificValue ?? '',
        'notes': notes ?? '',
        'timestamp': timestamp,
        'author': author.name ?? 'Unknown',
        'authorId': author.id?.toString() ?? 'unknown',
        'authorRole': author.role.toString(),
        'locationId': locationId ?? 'unknown',
        'createdAt': timestamp,
        'updatedAt': timestamp,
        ...?additionalData,
      };

      debugPrint('📝 Adding $recordType record for animal $animalId');
      debugPrint('Record data: $record');

      // Save record to Upstash
      final key = '$_recordsPrefix:$animalId:$recordId';
      await UpstashConfig.redis.hset(
        key, 
        record.map((k, v) => MapEntry(k, v.toString()))
      );
      
      // Add to indexes
      await UpstashConfig.redis.sadd('$_recordsIndexPrefix:$animalId', [recordId]);
      await UpstashConfig.redis.sadd('$_typeIndexPrefix:$recordType', [recordId]);
      await UpstashConfig.redis.sadd('$_typeIndexPrefix:all', [recordId]);
      
      // Add to author index
      await UpstashConfig.redis.sadd('records:author:${author.id}', [recordId]);
      
      // Add to location index if provided
      if (locationId != null) {
        await UpstashConfig.redis.sadd('records:location:$locationId', [recordId]);
      }

      debugPrint('✅ Record saved successfully: $recordId');
      return recordId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error adding record: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all records for a specific animal
  Future<List<Map<String, dynamic>>> getAnimalRecords(String animalId) async {
    try {
      debugPrint('📖 Loading records for animal: $animalId');
      
      final recordIds = await UpstashConfig.redis.smembers('$_recordsIndexPrefix:$animalId');
      final records = <Map<String, dynamic>>[];
      
      for (final recordId in recordIds) {
        final recordData = await UpstashConfig.redis.hgetall('$_recordsPrefix:$animalId:$recordId');
        if (recordData != null && recordData.isNotEmpty) {
          // Convert all values to strings and parse JSON fields if needed
          final processedRecord = <String, dynamic>{};
          recordData.forEach((key, value) {
            processedRecord[key] = value.toString();
          });
          records.add(processedRecord);
        }
      }
      
      // Sort by timestamp (newest first)
      records.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
      
      debugPrint('✅ Loaded ${records.length} records for animal $animalId');
      return records;
    } catch (e) {
      debugPrint('❌ Error loading animal records: $e');
      return [];
    }
  }

  /// Get records by type
  Future<List<Map<String, dynamic>>> getRecordsByType(String recordType) async {
    try {
      if (!_isValidRecordType(recordType)) {
        throw ArgumentError('Invalid record type: $recordType');
      }

      final recordIds = await UpstashConfig.redis.smembers('$_typeIndexPrefix:$recordType');
      final records = <Map<String, dynamic>>[];
      
      for (final recordId in recordIds) {
        // Extract animal ID from record ID pattern
        final parts = recordId.split('_');
        if (parts.length >= 2) {
          final animalId = parts[1]; // This might need adjustment based on actual ID format
          final recordData = await UpstashConfig.redis.hgetall('$_recordsPrefix:$animalId:$recordId');
          if (recordData != null && recordData.isNotEmpty) {
            final processedRecord = <String, dynamic>{};
            recordData.forEach((key, value) {
              processedRecord[key] = value.toString();
            });
            records.add(processedRecord);
          }
        }
      }
      
      // Sort by timestamp (newest first)
      records.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
      
      return records;
    } catch (e) {
      debugPrint('Error loading records by type: $e');
      return [];
    }
  }

  /// Update an existing record
  Future<void> updateRecord({
    required String animalId,
    required String recordId,
    required String description,
    required User author,
    String? specificValue,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final key = '$_recordsPrefix:$animalId:$recordId';
      
      // Get existing record
      final existingRecord = await UpstashConfig.redis.hgetall(key);
      if (existingRecord == null || existingRecord.isEmpty) {
        throw Exception('Record not found: $recordId');
      }

      // Update fields
      final updates = {
        'description': description,
        'specificValue': specificValue ?? existingRecord['specificValue'] ?? '',
        'notes': notes ?? existingRecord['notes'] ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
        'lastModifiedBy': author.name ?? 'Unknown',
        'lastModifiedById': author.id?.toString() ?? 'unknown',
        ...?additionalData,
      };

      await UpstashConfig.redis.hset(key, updates.map((k, v) => MapEntry(k, v.toString())));
      
      debugPrint('✅ Record updated successfully: $recordId');
    } catch (e) {
      debugPrint('❌ Error updating record: $e');
      rethrow;
    }
  }

  /// Delete a record
  Future<void> deleteRecord(String animalId, String recordId) async {
    try {
      final key = '$_recordsPrefix:$animalId:$recordId';
      
      // Get record data before deletion to clean up indexes
      final recordData = await UpstashConfig.redis.hgetall(key);
      if (recordData != null && recordData.isNotEmpty) {
        final recordType = recordData['type'];
        final authorId = recordData['authorId'];
        final locationId = recordData['locationId'];

        // Remove from indexes
        await UpstashConfig.redis.srem('$_recordsIndexPrefix:$animalId', [recordId]);
        await UpstashConfig.redis.srem('$_typeIndexPrefix:$recordType', [recordId]);
        await UpstashConfig.redis.srem('$_typeIndexPrefix:all', [recordId]);
        
        if (authorId != null) {
          await UpstashConfig.redis.srem('records:author:$authorId', [recordId]);
        }
        
        if (locationId != null) {
          await UpstashConfig.redis.srem('records:location:$locationId', [recordId]);
        }
      }

      // Delete the record
      await UpstashConfig.redis.del([key]);
      
      debugPrint('✅ Record deleted successfully: $recordId');
    } catch (e) {
      debugPrint('❌ Error deleting record: $e');
      rethrow;
    }
  }

  /// Get record statistics
  Future<Map<String, int>> getRecordStatistics({String? animalId, String? locationId}) async {
    try {
      final stats = <String, int>{};
      
      if (animalId != null) {
        // Get stats for specific animal
        final records = await getAnimalRecords(animalId);
        for (final record in records) {
          final type = record['type'] ?? 'unknown';
          stats[type] = (stats[type] ?? 0) + 1;
        }
      } else {
        // Get global stats
        for (final type in [typeCondition, typeBehaviour, typeComment, typeClinicalNotes]) {
          final recordIds = await UpstashConfig.redis.smembers('$_typeIndexPrefix:$type');
          stats[type] = recordIds.length;
        }
      }
      
      return stats;
    } catch (e) {
      debugPrint('Error getting record statistics: $e');
      return {};
    }
  }

  /// Get recent records across all animals
  Future<List<Map<String, dynamic>>> getRecentRecords({int limit = 10}) async {
    try {
      final allRecordIds = await UpstashConfig.redis.smembers('$_typeIndexPrefix:all');
      final records = <Map<String, dynamic>>[];
      
      // This is a simplified approach - in a real app, you'd want to use a sorted set
      // with timestamps as scores for better performance
      for (final recordId in allRecordIds.take(limit * 2)) { // Get more than needed for sorting
        // Try to find the record in different animal namespaces
        // This is inefficient but works for the demo
        final animalIds = await UpstashConfig.redis.smembers('animals:all');
        for (final animalId in animalIds) {
          final recordData = await UpstashConfig.redis.hgetall('$_recordsPrefix:$animalId:$recordId');
          if (recordData != null && recordData.isNotEmpty) {
            final processedRecord = <String, dynamic>{};
            recordData.forEach((key, value) {
              processedRecord[key] = value.toString();
            });
            records.add(processedRecord);
            break; // Found the record, move to next
          }
        }
      }
      
      // Sort by timestamp and limit
      records.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
      return records.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting recent records: $e');
      return [];
    }
  }

  /// Validate record type
  bool _isValidRecordType(String recordType) {
    return [typeCondition, typeBehaviour, typeComment, typeClinicalNotes].contains(recordType);
  }

  /// Clean up orphaned records (records for animals that no longer exist)
  Future<int> cleanupOrphanedRecords() async {
    try {
      debugPrint('🧹 Starting cleanup of orphaned records...');
      
      final allRecordIds = await UpstashConfig.redis.smembers('$_typeIndexPrefix:all');
      final existingAnimalIds = await UpstashConfig.redis.smembers('animals:all');
      
      int deletedCount = 0;
      
      for (final recordId in allRecordIds) {
        // Extract animal ID from record (this assumes record ID format)
        bool recordExists = false;
        for (final animalId in existingAnimalIds) {
          final recordData = await UpstashConfig.redis.hgetall('$_recordsPrefix:$animalId:$recordId');
          if (recordData != null && recordData.isNotEmpty) {
            recordExists = true;
            break;
          }
        }
        
        if (!recordExists) {
          // Clean up the record from all indexes
          await UpstashConfig.redis.srem('$_typeIndexPrefix:all', [recordId]);
          for (final type in [typeCondition, typeBehaviour, typeComment, typeClinicalNotes]) {
            await UpstashConfig.redis.srem('$_typeIndexPrefix:$type', [recordId]);
          }
          deletedCount++;
        }
      }
      
      debugPrint('✅ Cleanup completed: $deletedCount orphaned records removed');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Error during cleanup: $e');
      return 0;
    }
  }
} 