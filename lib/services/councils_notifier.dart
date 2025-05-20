import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/services/council_service.dart';

class CouncilsNotifier extends StateNotifier<AsyncValue<List<Council>>> {
  final CouncilService _councilService;

  CouncilsNotifier(this._councilService) : super(const AsyncValue.loading()) {
    _loadCouncils();
  }

  Future<void> _loadCouncils() async {
    try {
      final councils = await _councilService.getCouncils();
      state = AsyncValue.data(councils);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCouncil(Council council) async {
    try {
      await _councilService.saveCouncil(council);
      await _loadCouncils();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCouncil(Council council) async {
    try {
      await _councilService.saveCouncil(council);
      await _loadCouncils();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCouncil(String id) async {
    try {
      await _councilService.deleteCouncil(id);
      await _loadCouncils();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final councilsProvider = StateNotifierProvider<CouncilsNotifier, AsyncValue<List<Council>>>((ref) {
  final councilService = ref.watch(councilServiceProvider);
  return CouncilsNotifier(councilService);
}); 