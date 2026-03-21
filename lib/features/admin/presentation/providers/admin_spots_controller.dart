import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nepal_explore/core/providers/supabase_provider.dart';
import 'package:nepal_explore/features/admin/data/admin_spots_service.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';

final adminSpotsServiceProvider = Provider<AdminSpotsService>((ref) {
  return AdminSpotsService(client: ref.watch(supabaseClientProvider));
});

final adminSpotsControllerProvider =
    AsyncNotifierProvider<AdminSpotsController, List<TouristSpot>>(
      AdminSpotsController.new,
    );

class AdminSpotsController extends AsyncNotifier<List<TouristSpot>> {
  late final AdminSpotsService _service;

  @override
  Future<List<TouristSpot>> build() async {
    _service = ref.read(adminSpotsServiceProvider);
    return _service.fetchSpots();
  }

  Future<List<TouristSpot>> refresh({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    final nextState = await AsyncValue.guard(_service.fetchSpots);
    state = nextState;
    return nextState.value ?? const <TouristSpot>[];
  }

  Future<void> approveSpot(String id) async {
    await _runAndRefresh(
      () => _service.updateStatus(id, ApprovalStatus.approved),
    );
  }

  Future<void> rejectSpot(String id) async {
    await _runAndRefresh(
      () => _service.updateStatus(id, ApprovalStatus.rejected),
    );
  }

  Future<void> toggleFeatured(String id, bool isFeatured) async {
    await _runAndRefresh(() => _service.updateFeatured(id, isFeatured));
  }

  Future<void> saveSpot(TouristSpot spot) async {
    await _runAndRefresh(() => _service.updateSpot(spot));
  }

  Future<void> deleteSpot(String id) async {
    await _runAndRefresh(() => _service.softDeleteSpot(id));
  }

  Future<void> _runAndRefresh(Future<dynamic> Function() action) async {
    await action();
    await refresh(showLoading: false);
  }
}
