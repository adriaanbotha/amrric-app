import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/house.dart';
import '../services/house_service.dart';

final houseServiceProvider = Provider<HouseService>((ref) => HouseService());

final housesProvider = StateNotifierProvider<HousesNotifier, AsyncValue<List<House>>>((ref) {
  return HousesNotifier(ref.read(houseServiceProvider));
});

final housesByLocationProvider = FutureProvider.family<List<House>, String>((ref, locationId) async {
  final houseService = ref.read(houseServiceProvider);
  return houseService.getHousesByLocation(locationId);
});

final housesByCouncilProvider = FutureProvider.family<List<House>, String>((ref, councilId) async {
  final houseService = ref.read(houseServiceProvider);
  return houseService.getHousesByCouncil(councilId);
});

final houseProvider = FutureProvider.family<House?, String>((ref, houseId) async {
  final houseService = ref.read(houseServiceProvider);
  return houseService.getHouse(houseId);
});

final houseStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final houseService = ref.read(houseServiceProvider);
  return houseService.getHouseStatistics();
});

class HousesNotifier extends StateNotifier<AsyncValue<List<House>>> {
  final HouseService _houseService;

  HousesNotifier(this._houseService) : super(const AsyncValue.loading()) {
    loadHouses();
  }

  Future<void> loadHouses() async {
    try {
      state = const AsyncValue.loading();
      final houses = await _houseService.getHouses();
      state = AsyncValue.data(houses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createHouse(House house) async {
    try {
      await _houseService.createHouse(house);
      await loadHouses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateHouse(House house) async {
    try {
      await _houseService.updateHouse(house);
      await loadHouses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteHouse(String houseId) async {
    try {
      await _houseService.deleteHouse(houseId);
      await loadHouses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<List<House>> searchHouses(String query) async {
    try {
      return await _houseService.searchHouses(query);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadHouses();
  }
} 