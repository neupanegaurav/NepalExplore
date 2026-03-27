import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:nepal_explore/core/layout/adaptive_layout.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTabletLayout = AppAdaptiveLayout.useTabletLayout(
          context,
          width: constraints.maxWidth,
        );
        final crossAxisCount = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 760
            ? 3
            : 2;
        final horizontalPadding = useTabletLayout ? 24.0 : 16.0;

        return userLocationAsync.when(
          data: (userPos) {
            final Map<SpotCategory, List<TouristSpot>> groupedSpots = {};
            for (final spot in filteredSpots) {
              groupedSpots.putIfAbsent(spot.category, () => []).add(spot);
            }

            final userLatLng = LatLng(userPos.latitude, userPos.longitude);
            const distCalc = Distance();
            for (var list in groupedSpots.values) {
              list.sort((a, b) {
                final distA = distCalc.as(
                  LengthUnit.Meter,
                  userLatLng,
                  a.location,
                );
                final distB = distCalc.as(
                  LengthUnit.Meter,
                  userLatLng,
                  b.location,
                );
                return distA.compareTo(distB);
              });
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(spotsProvider.notifier).syncSpots();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: useTabletLayout ? 152 : 140),
                  ),
                  if (groupedSpots.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No places found',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ...SpotCategory.values
                      .where((category) => groupedSpots.containsKey(category))
                      .map((category) {
                        final categorySpots = groupedSpots[category]!;
                        final label = category.name.replaceAll(
                          RegExp(r'(?<!^)(?=[A-Z])'),
                          ' ',
                        );
                        final displayLabel =
                            label[0].toUpperCase() + label.substring(1);

                        return SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  24,
                                  horizontalPadding,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      displayLabel,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${categorySpots.length}',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: 0.8,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final spot = categorySpots[index];
                                  final meters = distCalc.as(
                                    LengthUnit.Meter,
                                    userLatLng,
                                    spot.location,
                                  );
                                  final distanceLabel = meters > 1000
                                      ? '${(meters / 1000).toStringAsFixed(1)} km'
                                      : '${meters}m';

                                  return Card(
                                    elevation: 2,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        SpotDetailScreen.route(spot),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: spot.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, url, error) {
                                                        return Container(
                                                          color: theme
                                                              .colorScheme
                                                              .surfaceContainerHighest,
                                                          child: const Icon(
                                                            Icons.photo,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      },
                                                ),
                                                if (spot.isFeatured)
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: AppTheme
                                                                .accentOrange,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    spot.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 12,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        distanceLabel,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                        ),
                                                      ),
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
                                }, childCount: categorySpots.length),
                              ),
                            ),
                          ],
                        );
                      }),
                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Please enable location to see nearby places.\n$error'),
          ),
        );
      },
    );
  }
}
