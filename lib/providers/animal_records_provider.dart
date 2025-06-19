import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/animal_records_service.dart';

// Provider for the Animal Records Service
final animalRecordsServiceProvider = Provider<AnimalRecordsService>((ref) {
  return AnimalRecordsService();
});

// Provider for animal records for a specific animal
final animalRecordsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, animalId) async {
  final service = ref.read(animalRecordsServiceProvider);
  return await service.getAnimalRecords(animalId);
});

// Provider for records by type
final recordsByTypeProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, recordType) async {
  final service = ref.read(animalRecordsServiceProvider);
  return await service.getRecordsByType(recordType);
});

// Provider for record statistics
final recordStatisticsProvider = FutureProvider.family<Map<String, int>, String?>((ref, animalId) async {
  final service = ref.read(animalRecordsServiceProvider);
  return await service.getRecordStatistics(animalId: animalId);
});

// Provider for recent records
final recentRecordsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final service = ref.read(animalRecordsServiceProvider);
  return await service.getRecentRecords(limit: limit);
}); 