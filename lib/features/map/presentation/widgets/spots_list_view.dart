import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/spots/presentation/spot_detail_screen.dart';
import 'package:nepal_explore/core/theme/theme.dart';

class SpotsListView extends ConsumerWidget {
  const SpotsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSpots = ref.watch(filteredSpotsProvider);
    final userLocationAsync = ref.watch(userLocationProvider);
    final theme = Theme.of(context);

    return userLocationAsync.when(
      data: (userPos) {
        // Group spots by category
        final Map<SpotCategory, List<TouristSpot>> groupedSpots = {};
        for (final spot in filteredSpots) {
          groupedSpots.putIfAbsent(spot.category, () => []).add(spot);
        }

        // Sort spots within each category by distance
        final userLatLng = LatLng(userPos.latitude, userPos.longitude);
        const distCalc = Distance();
        for (var list in groupedSpots.values) {
          list.sort((a, b) {
            final distA = distCalc.as(LengthUnit.Meter, userLatLng, a.location);
            final distB = distCalc.as(LengthUnit.Meter, userLatLng, b.location);
            return distA.compareTo(distB);
          });
        }

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 140)), // Padding for search bar
            
            if (groupedSpots.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('No places found', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),

            // Dynamic Category Lists
            ...SpotCategory.values.where((c) => groupedSpots.containsKey(c)).map((category) {
              final categorySpots = groupedSpots[category]!;
              final label = category.name.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
              final displayLabel = label[0].toUpperCase() + label.substring(1);

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          Icon(Icons.category, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(displayLabel, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('${categorySpots.length}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final spot = categorySpots[index];
                          final m = distCalc.as(LengthUnit.Meter, userLatLng, spot.location);
                          final distStr = m > 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '${m}m';

                          return Card(
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              onTap: () => Navigator.push(context, SpotDetailScreen.route(spot)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: spot.imageUrl,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) => Container(
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            child: const Icon(Icons.photo, color: Colors.grey),
                                          ),
                                        ),
                                        if (spot.isFeatured)
                                          Positioned(
                                            top: 8, right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(color: AppTheme.accentOrange, shape: BoxShape.circle),
                                              child: const Icon(Icons.star, color: Colors.white, size: 12),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            spot.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, size: 12, color: theme.colorScheme.primary),
                                              const SizedBox(width: 4),
                                              Text(distStr, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: categorySpots.length,
                      ),
                    ),
                  ),
                ],
              );
            }),
            
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Please enable location to see nearby places.\n$e')),
    );
  }
}
