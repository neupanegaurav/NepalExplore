import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nepal_explore/core/config/app_config.dart';
import 'package:nepal_explore/features/spots/data/spots_data.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/spots/domain/business.dart';
import 'package:nepal_explore/features/spots/data/spots_remote_source.dart';
import 'package:nepal_explore/features/spots/data/spots_repository.dart';
import 'package:nepal_explore/core/database/app_document_database.dart';

enum ViewType { map, list }

class ViewTypeNotifier extends Notifier<ViewType> {
  @override
  ViewType build() => ViewType.map;
  void set(ViewType value) => state = value;
}

final viewTypeProvider = NotifierProvider<ViewTypeNotifier, ViewType>(
  ViewTypeNotifier.new,
);

// Current search query
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// Current bounds filter
class MapBoundsNotifier extends Notifier<LatLngBounds?> {
  @override
  LatLngBounds? build() => null;
  void set(LatLngBounds? bounds) => state = bounds;
}

final mapBoundsProvider = NotifierProvider<MapBoundsNotifier, LatLngBounds?>(
  MapBoundsNotifier.new,
);

// Current selected category filter
class CategoryFilterNotifier extends Notifier<SpotCategory?> {
  @override
  SpotCategory? build() => null;
  void set(SpotCategory? value) => state = value;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, SpotCategory?>(
      CategoryFilterNotifier.new,
    );

// Current selected tourist spot for the bottom sheet
class SelectedSpotNotifier extends Notifier<TouristSpot?> {
  @override
  TouristSpot? build() => null;
  void set(TouristSpot? value) => state = value;
}

final selectedSpotProvider =
    NotifierProvider<SelectedSpotNotifier, TouristSpot?>(
      SelectedSpotNotifier.new,
    );

// View properties for map
class MapControllerNotifier extends Notifier<MapController?> {
  @override
  MapController? build() => null;
  void set(MapController? value) => state = value;
}

final mapControllerProvider =
    NotifierProvider<MapControllerNotifier, MapController?>(
      MapControllerNotifier.new,
    );

final appDatabaseProvider = Provider<AppDocumentDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden');
});

final spotsRepositoryProvider = Provider<SpotsRepository>(
  (ref) => SpotsRepository.preview(),
);

final remoteSourceProvider = Provider<SpotsRemoteSource>((ref) {
  if (AppConfig.hasSupabaseConfig) {
    return SupabaseRestSpotsRemoteSource();
  }
  return JsonFeedSpotsRemoteSource();
});

final initialSpotsProvider = Provider<List<TouristSpot>>(
  (ref) => dummyTouristSpots,
);

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  final remote = ref.read(businessRemoteSourceProvider);
  return BusinessRepository(database: db, remoteSource: remote);
});

final businessRemoteSourceProvider = Provider<BusinessRemoteSource>((ref) {
  if (AppConfig.hasSupabaseConfig) {
    return SupabaseRestBusinessRemoteSource();
  }
  return JsonFeedBusinessRemoteSource();
});

final businessesProvider = AsyncNotifierProvider<BusinessesNotifier, List<Business>>(
  BusinessesNotifier.new,
);

class BusinessesNotifier extends AsyncNotifier<List<Business>> {
  late final BusinessRepository _repository;

  @override
  Future<List<Business>> build() async {
    _repository = ref.read(businessRepositoryProvider);
    final local = await _repository.loadBusinesses();
    if (local.isEmpty) {
      await _repository.syncFromServer();
      return _repository.loadBusinesses();
    }
    return local;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.syncFromServer();
      return _repository.loadBusinesses();
    });
  }
}

final spotsProvider = NotifierProvider<SpotsNotifier, List<TouristSpot>>(
  SpotsNotifier.new,
);

class SpotsNotifier extends Notifier<List<TouristSpot>> {
  late final SpotsRepository _repository;

  @override
  List<TouristSpot> build() {
    _repository = ref.read(spotsRepositoryProvider);
    return [...ref.read(initialSpotsProvider)];
  }

  Future<TouristSpot> addSpot(TouristSpot spot) {
    return submitSpot(spot);
  }

  Future<TouristSpot> submitSpot(
    TouristSpot spot, {
    List<XFile> images = const [],
  }) async {
    final savedSpot = await _repository.submitSpot(spot, images: images);
    state = [...state, savedSpot];
    return savedSpot;
  }

  Future<TouristSpot> approveSpot(String id) async {
    final updatedSpot = await _repository.updateSpotStatus(
      id,
      ApprovalStatus.approved,
    );
    state = state.map((spot) => spot.id == id ? updatedSpot : spot).toList();
    return updatedSpot;
  }

  Future<TouristSpot> rejectSpot(String id) async {
    final updatedSpot = await _repository.updateSpotStatus(
      id,
      ApprovalStatus.rejected,
    );
    state = state.map((spot) => spot.id == id ? updatedSpot : spot).toList();
    return updatedSpot;
  }

  Future<SpotsSyncReport> syncSpots() async {
    final report = await _repository.syncFromServer();
    state = await _repository.loadSpots();
    return report;
  }
}

// Provider for pending spots (for admin)
final pendingSpotsProvider = Provider<List<TouristSpot>>((ref) {
  final allSpots = ref.watch(spotsProvider);
  return allSpots
      .where((spot) => spot.status == ApprovalStatus.pending)
      .toList();
});

// Provider to get the filtered list of approved tourist spots
final filteredSpotsProvider = Provider<List<TouristSpot>>((ref) {
  final allSpots = ref.watch(spotsProvider);
  final filter = ref.watch(categoryFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final bounds = ref.watch(mapBoundsProvider);

  var approvedSpots = allSpots
      .where((spot) => spot.status == ApprovalStatus.approved)
      .toList();

  if (filter != null) {
    approvedSpots = approvedSpots
        .where((spot) => spot.category == filter)
        .toList();
  }

  if (bounds != null) {
    approvedSpots = approvedSpots
        .where((spot) => bounds.contains(spot.location))
        .toList();
  }

  if (searchQuery.isNotEmpty) {
    approvedSpots = approvedSpots
        .where(
          (spot) =>
              spot.name.toLowerCase().contains(searchQuery) ||
              spot.description.toLowerCase().contains(searchQuery),
        )
        .toList();
  }

  return approvedSpots;
});

// A provider for handling user location
final userLocationProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
});
