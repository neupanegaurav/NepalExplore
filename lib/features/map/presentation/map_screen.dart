import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:nepal_explore/core/layout/adaptive_layout.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/map/presentation/widgets/category_filter_row.dart';
import 'package:nepal_explore/features/map/presentation/widgets/spots_list_view.dart';
import 'package:nepal_explore/features/spots/presentation/spot_detail_screen.dart';
import 'package:nepal_explore/core/theme/theme.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  static final LatLng _initialPosition = LatLng(28.3949, 84.1240);

  bool _showSearchAreaButton = false;

  IconData getIconForCategory(SpotCategory category) {
    switch (category) {
      case SpotCategory.historicalSites:
        return Icons.history_edu;
      case SpotCategory.religiousPlaces:
        return Icons.temple_hindu;
      case SpotCategory.natureTrails:
        return Icons.terrain;
      case SpotCategory.viewpoints:
        return Icons.visibility;
      case SpotCategory.culturalCenters:
        return Icons.museum;
      case SpotCategory.picnicArea:
        return Icons.park;
      case SpotCategory.sceneries:
        return Icons.landscape;
      case SpotCategory.mountains:
        return Icons.filter_hdr;
      case SpotCategory.offroadRiding:
        return Icons.directions_car;
      case SpotCategory.cyclingSpots:
        return Icons.directions_bike;
      case SpotCategory.touristAgents:
        return Icons.support_agent;
      case SpotCategory.hotels:
        return Icons.hotel;
      case SpotCategory.tickets:
        return Icons.confirmation_number;
      case SpotCategory.guides:
        return Icons.hiking;
      case SpotCategory.dining:
        return Icons.restaurant;
    }
  }

  Color getColorForCategory(SpotCategory category) {
    switch (category) {
      case SpotCategory.historicalSites:
        return const Color(0xFF8D6E63);
      case SpotCategory.religiousPlaces:
        return AppTheme.accentOrange;
      case SpotCategory.natureTrails:
        return AppTheme.secondaryColor;
      case SpotCategory.viewpoints:
        return AppTheme.primaryColor;
      case SpotCategory.culturalCenters:
        return AppTheme.accentPurple;
      case SpotCategory.picnicArea:
        return AppTheme.accentMint;
      case SpotCategory.sceneries:
        return AppTheme.accentTeal;
      case SpotCategory.mountains:
        return const Color(0xFF78909C);
      case SpotCategory.offroadRiding:
        return AppTheme.accentRed;
      case SpotCategory.cyclingSpots:
        return AppTheme.accentIndigo;
      case SpotCategory.touristAgents:
        return AppTheme.accentPink;
      case SpotCategory.hotels:
        return AppTheme.primaryColor;
      case SpotCategory.tickets:
        return AppTheme.accentOrange;
      case SpotCategory.guides:
        return AppTheme.secondaryColor;
      case SpotCategory.dining:
        return AppTheme.accentPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSpots = ref.watch(filteredSpotsProvider);
    final userLocationAsync = ref.watch(userLocationProvider);
    final viewType = ref.watch(viewTypeProvider);
    final theme = Theme.of(context);

    List<Marker> markers = filteredSpots.map((spot) {
      final catColor = getColorForCategory(spot.category);
      return Marker(
        point: spot.location,
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => Navigator.push(context, SpotDetailScreen.route(spot)),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: catColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                getIconForCategory(spot.category),
                size: 18,
                color: catColor,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useTabletLayout = AppAdaptiveLayout.useTabletLayout(
            context,
            width: constraints.maxWidth,
          );
          final searchMaxWidth = useTabletLayout ? 860.0 : double.infinity;
          final horizontalInset = useTabletLayout ? 24.0 : 16.0;

          return Stack(
            children: [
              if (viewType == ViewType.map)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 7.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: () => ref
                        .read(mapControllerProvider.notifier)
                        .set(_mapController),
                    onMapEvent: (event) {
                      if (event is MapEventMove) {
                        if (!_showSearchAreaButton &&
                            event.source != MapEventSource.mapController) {
                          setState(() => _showSearchAreaButton = true);
                        }
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.nepal_explore',
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 30,
                        size: const Size(40, 40),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(50),
                        maxZoom: 15,
                        markers: markers,
                        builder: (context, clusterMarkers) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                clusterMarkers.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (userLocationAsync.hasValue)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              userLocationAsync.value!.latitude,
                              userLocationAsync.value!.longitude,
                            ),
                            width: 22,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              else
                const SpotsListView(),

              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: searchMaxWidth),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalInset,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    onChanged: (value) => ref
                                        .read(searchQueryProvider.notifier)
                                        .set(value),
                                    decoration: InputDecoration(
                                      hintText: 'Search destinations...',
                                      hintStyle: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.4),
                                          ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: theme.colorScheme.primary,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ToggleButtons(
                                  isSelected: [
                                    viewType == ViewType.map,
                                    viewType == ViewType.list,
                                  ],
                                  onPressed: (index) {
                                    ref
                                        .read(viewTypeProvider.notifier)
                                        .set(
                                          index == 0
                                              ? ViewType.map
                                              : ViewType.list,
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(26),
                                  fillColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  selectedColor: theme.colorScheme.primary,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                    minWidth: 48,
                                  ),
                                  borderWidth: 0,
                                  renderBorder: false,
                                  children: const [
                                    Icon(Icons.map),
                                    Icon(Icons.list),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const CategoryFilterRow(),
                      ],
                    ),
                  ),
                ),
              ),

              if (_showSearchAreaButton && viewType == ViewType.map)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(mapBoundsProvider.notifier)
                            .set(_mapController.camera.visibleBounds);
                        setState(() => _showSearchAreaButton = false);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Search this area'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 4,
                      ),
                    ),
                  ),
                ),

              Positioned(
                right: horizontalInset,
                bottom: 28,
                child: FloatingActionButton.small(
                  heroTag: 'my_location',
                  backgroundColor: theme.colorScheme.surface,
                  elevation: 2,
                  onPressed: () {
                    userLocationAsync.whenData((Position position) {
                      _mapController.move(
                        LatLng(position.latitude, position.longitude),
                        14.0,
                      );
                    });
                  },
                  child: Icon(
                    Icons.my_location,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
