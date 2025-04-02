import 'package:upstash_redis/upstash_redis.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/config/upstash_config.dart';

class CouncilService {
  final Redis _redis;

  CouncilService(this._redis);

  // Create a new council
  Future<Council> createCouncil(Council council) async {
    if (!council.validate()) {
      throw Exception('Invalid council data');
    }

    // Check if name is unique
    final existingCouncils = await getCouncils();
    if (existingCouncils.any((c) => c.name == council.name)) {
      throw Exception('Council name must be unique');
    }

    // Store council
    final councilData = council.toJson();
    await _redis.hset(
      'council:${council.id}',
      councilData.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );

    return council;
  }

  // Get a council by ID
  Future<Council?> getCouncil(String id) async {
    final data = await _redis.hgetall('council:$id');
    if (data == null || data.isEmpty) return null;
    return Council.fromJson(data);
  }

  // Get all councils
  Future<List<Council>> getCouncils() async {
    final keys = await _redis.keys('council:*');
    final councils = <Council>[];

    for (final key in keys) {
      final data = await _redis.hgetall(key);
      if (data != null && data.isNotEmpty) {
        councils.add(Council.fromJson(data));
      }
    }

    return councils;
  }

  // Get councils by state
  Future<List<Council>> getCouncilsByState(String state) async {
    final councilIds = await _redis.smembers('councils:state:$state');
    final councils = <Council>[];

    for (final id in councilIds) {
      final council = await getCouncil(id);
      if (council != null) {
        councils.add(council);
      }
    }

    return councils;
  }

  // Update a council
  Future<Council> updateCouncil(Council council) async {
    if (!council.validate()) {
      throw Exception('Invalid council data');
    }

    final existingCouncil = await getCouncil(council.id);
    if (existingCouncil == null) {
      throw Exception('Council not found');
    }

    // Check if name is unique if changed
    if (existingCouncil.name != council.name) {
      final existingCouncils = await getCouncils();
      if (existingCouncils.any((c) => c.name == council.name)) {
        throw Exception('Council name must be unique');
      }
    }

    // Update council
    final councilData = council.toJson();
    await _redis.hset(
      'council:${council.id}',
      councilData.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );

    return council;
  }

  // Delete a council
  Future<void> deleteCouncil(String id) async {
    final council = await getCouncil(id);
    if (council == null) {
      throw Exception('Council not found');
    }

    // Check if council has associated locations
    final locationCount = await _redis.scard('council:$id:locations');
    if (locationCount > 0) {
      throw Exception('Cannot delete council with associated locations');
    }

    // Delete council
    await _redis.del(['council:$id']);
  }

  // Search councils by name
  Future<List<Council>> searchCouncils(String query) async {
    final councils = await getCouncils();
    final lowercaseQuery = query.toLowerCase();
    
    return councils.where((council) {
      return council.name.toLowerCase().contains(lowercaseQuery) ||
             council.state.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Toggle council status
  Future<void> toggleCouncilStatus(String id) async {
    final council = await getCouncil(id);
    if (council == null) {
      throw Exception('Council not found');
    }

    final updatedCouncil = council.copyWith(
      isActive: !council.isActive,
      updatedAt: DateTime.now(),
    );

    await updateCouncil(updatedCouncil);
  }

  // Update council image
  Future<Council> updateCouncilImage(String id, String imageUrl) async {
    final council = await getCouncil(id);
    if (council == null) {
      throw Exception('Council not found');
    }

    final updatedCouncil = council.copyWith(
      imageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    final councilData = updatedCouncil.toJson();
    await _redis.hset(
      'council:${updatedCouncil.id}',
      councilData.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
    return updatedCouncil;
  }

  // Update council configuration
  Future<Council> updateCouncilConfiguration(String id, Map<String, dynamic> configuration) async {
    final council = await getCouncil(id);
    if (council == null) {
      throw Exception('Council not found');
    }

    final updatedCouncil = council.copyWith(
      configuration: configuration,
      updatedAt: DateTime.now(),
    );

    final councilData = updatedCouncil.toJson();
    await _redis.hset(
      'council:${updatedCouncil.id}',
      councilData.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
    return updatedCouncil;
  }
} 