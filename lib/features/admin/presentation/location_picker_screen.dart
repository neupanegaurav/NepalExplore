import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final userLocAsync = ref.watch(userLocationProvider);
    final theme = Theme.of(context);

    // Default to Kathmandu if location fails
    final LatLng initialCenter = userLocAsync.when(
      data: (pos) => LatLng(pos.latitude, pos.longitude),
      loading: () => const LatLng(27.7172, 85.3240),
      error: (_, __) => const LatLng(27.7172, 85.3240),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: _selectedLocation == null 
              ? null 
              : () => Navigator.pop(context, _selectedLocation),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 14,
              onTap: (tapPosition, point) {
                setState(() => _selectedLocation = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nepal_explore',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: Icon(Icons.location_on, color: theme.colorScheme.primary, size: 50),
                    ),
                  ],
                ),
            ],
          ),
          // Helper overlay
          Positioned(
            top: 20, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Tap anywhere on the map to drop a pin for your business location.', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
          // My Location FAB
          Positioned(
            bottom: 24, right: 16,
            child: FloatingActionButton(
              heroTag: 'picker_my_loc',
              backgroundColor: theme.colorScheme.surface,
              onPressed: () {
                userLocAsync.whenData((pos) {
                  _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
                });
              },
              child: Icon(Icons.my_location, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
