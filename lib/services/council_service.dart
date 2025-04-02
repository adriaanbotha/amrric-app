import 'package:upstash_redis/upstash_redis.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/config/upstash_config.dart';

class CouncilService {
  final Redis _redis;

  CouncilService(this._redis);

  // Create a new council
  Future<Council> createCouncil(Council council) async {
    final key = 'councils:${council.id}';
    final nameKey = 'council_names:${council.name.toLowerCase()}';

    // Check if council name already exists
    final existingId = await _redis.get(nameKey);
    if (existingId != null) {
      throw Exception('A council with this name already exists');
    }

    // Store council data
    await _redis.set(key, council.toJson());
    await _redis.set(nameKey, council.id);

    // Add to council list
    await _redis.sadd('councils', [council.id]);

    // Add to state-specific set
    await _redis.sadd('councils:state:${council.state}', [council.id]);

    return council;
  }

  // Get a council by ID
  Future<Council?> getCouncil(String id) async {
    final data = await _redis.get('councils:$id');
    if (data == null) return null;
    return Council.fromJson(data);
  }

  // Get all councils
  Future<List<Council>> getAllCouncils() async {
    final councilIds = await _redis.smembers('councils');
    final councils = <Council>[];

    for (final id in councilIds) {
      final council = await getCouncil(id);
      if (council != null) {
        councils.add(council);
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
    final key = 'councils:${council.id}';
    final existingCouncil = await getCouncil(council.id);
    
    if (existingCouncil == null) {
      throw Exception('Council not found');
    }

    // If name changed, update the name index
    if (existingCouncil.name != council.name) {
      final oldNameKey = 'council_names:${existingCouncil.name.toLowerCase()}';
      final newNameKey = 'council_names:${council.name.toLowerCase()}';
      
      // Check if new name is already taken by another council
      final existingId = await _redis.get(newNameKey);
      if (existingId != null && existingId != council.id) {
        throw Exception('A council with this name already exists');
      }

      await _redis.del([oldNameKey]);
      await _redis.set(newNameKey, council.id);
    }

    // If state changed, update state sets
    if (existingCouncil.state != council.state) {
      await _redis.srem('councils:state:${existingCouncil.state}', [council.id]);
      await _redis.sadd('councils:state:${council.state}', [council.id]);
    }

    // Update council data
    await _redis.set(key, council.toJson());

    return council;
  }

  // Delete a council
  Future<void> deleteCouncil(String id) async {
    final council = await getCouncil(id);
    if (council == null) return;

    final key = 'councils:$id';
    final nameKey = 'council_names:${council.name.toLowerCase()}';

    // Remove from all indexes
    await _redis.del([key]);
    await _redis.del([nameKey]);
    await _redis.srem('councils', [id]);
    await _redis.srem('councils:state:${council.state}', [id]);
  }

  // Search councils by name
  Future<List<Council>> searchCouncils(String query) async {
    final councilIds = await _redis.smembers('councils');
    final councils = <Council>[];
    final queryLower = query.toLowerCase();

    for (final id in councilIds) {
      final council = await getCouncil(id);
      if (council != null && council.name.toLowerCase().contains(queryLower)) {
        councils.add(council);
      }
    }

    return councils;
  }

  // Toggle council status
  Future<Council> toggleCouncilStatus(String id) async {
    final council = await getCouncil(id);
    if (council == null) {
      throw Exception('Council not found');
    }

    final updatedCouncil = council.copyWith(
      isActive: !council.isActive,
      updatedAt: DateTime.now(),
    );

    await _redis.set('councils:$id', updatedCouncil.toJson());
    return updatedCouncil;
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

    await _redis.set('councils:$id', updatedCouncil.toJson());
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

    await _redis.set('councils:$id', updatedCouncil.toJson());
    return updatedCouncil;
  }
} 