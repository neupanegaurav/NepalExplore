import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/spots/data/spots_data.dart';

enum ViewType { map, list }

class ViewTypeNotifier extends Notifier<ViewType> {
  @override
  ViewType build() => ViewType.map;
  void set(ViewType value) => state = value;
}

final viewTypeProvider = NotifierProvider<ViewTypeNotifier, ViewType>(ViewTypeNotifier.new);

// Current search query
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// Current bounds filter
class MapBoundsNotifier extends Notifier<LatLngBounds?> {
  @override
  LatLngBounds? build() => null;
  void set(LatLngBounds? bounds) => state = bounds;
}

final mapBoundsProvider = NotifierProvider<MapBoundsNotifier, LatLngBounds?>(MapBoundsNotifier.new);

// Current selected category filter
class CategoryFilterNotifier extends Notifier<SpotCategory?> {
  @override
  SpotCategory? build() => null;
  void set(SpotCategory? value) => state = value;
}

final categoryFilterProvider = NotifierProvider<CategoryFilterNotifier, SpotCategory?>(CategoryFilterNotifier.new);

// Current selected tourist spot for the bottom sheet
class SelectedSpotNotifier extends Notifier<TouristSpot?> {
  @override
  TouristSpot? build() => null;
  void set(TouristSpot? value) => state = value;
}

final selectedSpotProvider = NotifierProvider<SelectedSpotNotifier, TouristSpot?>(SelectedSpotNotifier.new);

// View properties for map
class MapControllerNotifier extends Notifier<MapController?> {
  @override
  MapController? build() => null;
  void set(MapController? value) => state = value;
}

final mapControllerProvider = NotifierProvider<MapControllerNotifier, MapController?>(MapControllerNotifier.new);

final spotsProvider = NotifierProvider<SpotsNotifier, List<TouristSpot>>(SpotsNotifier.new);

class SpotsNotifier extends Notifier<List<TouristSpot>> {
  @override
  List<TouristSpot> build() => dummyTouristSpots;

  void addSpot(TouristSpot spot) {
    state = [...state, spot];
  }

  void approveSpot(String id) {
    state = state.map((spot) {
      if (spot.id == id) {
        return TouristSpot(
          id: spot.id,
          name: spot.name,
          description: spot.description,
          location: spot.location,
          category: spot.category,
          imageUrl: spot.imageUrl,
          userImages: spot.userImages,
          status: ApprovalStatus.approved,
        );
      }
      return spot;
    }).toList();
  }

  void rejectSpot(String id) {
    state = state.map((spot) {
      if (spot.id == id) {
        return TouristSpot(
          id: spot.id,
          name: spot.name,
          description: spot.description,
          location: spot.location,
          category: spot.category,
          imageUrl: spot.imageUrl,
          userImages: spot.userImages,
          status: ApprovalStatus.rejected,
        );
      }
      return spot;
    }).toList();
  }

  Future<void> syncSpots(BuildContext context) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    final bool hasNewData = DateTime.now().second % 2 == 0;
    if (!context.mounted) return;
    
    if (hasNewData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New data are added to the system!'), backgroundColor: Colors.green, duration: Duration(seconds: 3)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No new data available. Everything is up to date.'), duration: Duration(seconds: 3)),
      );
    }
  }
}

// Provider for pending spots (for admin)
final pendingSpotsProvider = Provider<List<TouristSpot>>((ref) {
  final allSpots = ref.watch(spotsProvider);
  return allSpots.where((spot) => spot.status == ApprovalStatus.pending).toList();
});

// Provider to get the filtered list of approved tourist spots
final filteredSpotsProvider = Provider<List<TouristSpot>>((ref) {
  final allSpots = ref.watch(spotsProvider);
  final filter = ref.watch(categoryFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final bounds = ref.watch(mapBoundsProvider);
  
  var approvedSpots = allSpots.where((spot) => spot.status == ApprovalStatus.approved).toList();
  
  if (filter != null) {
    approvedSpots = approvedSpots.where((spot) => spot.category == filter).toList();
  }
  
  if (bounds != null) {
    approvedSpots = approvedSpots.where((spot) => bounds.contains(spot.location)).toList();
  }
  
  if (searchQuery.isNotEmpty) {
    approvedSpots = approvedSpots.where((spot) => 
      spot.name.toLowerCase().contains(searchQuery) ||
      spot.description.toLowerCase().contains(searchQuery)
    ).toList();
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
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
});
