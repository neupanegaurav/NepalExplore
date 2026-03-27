import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/admin/presentation/business_promotion_form.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/spots/domain/business.dart';
import 'package:nepal_explore/features/spots/presentation/spot_detail_screen.dart';
import 'package:nepal_explore/features/businesses/presentation/business_detail_screen.dart';
import 'package:nepal_explore/core/theme/theme.dart';

enum SortOption { featured, priceLow, distance }

class FeaturedDestinationsScreen extends ConsumerStatefulWidget {
  const FeaturedDestinationsScreen({super.key});

  @override
  ConsumerState<FeaturedDestinationsScreen> createState() =>
      _FeaturedDestinationsScreenState();
}

class _FeaturedDestinationsScreenState
    extends ConsumerState<FeaturedDestinationsScreen> {
  SortOption _selectedSort = SortOption.featured;
  bool _isGridView = false;

  int _priceValue(String? priceRange) {
    if (priceRange == null) return 0;
    return priceRange.length; // $, $$, $$$, etc.
  }

  @override
  Widget build(BuildContext context) {
    final spots = ref.watch(spotsProvider);
    final businessesAsync = ref.watch(businessesProvider);
    final businesses = businessesAsync.value ?? [];
    final theme = Theme.of(context);
    final userLocAsync = ref.watch(userLocationProvider);
    final userPos = userLocAsync.value;
    final Distance distCalc = const Distance();

    // Filter and combine data
    var combinedItems = <dynamic>[
      ...spots.where(
        (s) => s.status == ApprovalStatus.approved && s.isFeatured,
      ),
      ...businesses.where((b) => b.status == ApprovalStatus.approved),
    ];

    // Apply Sorting
    if (_selectedSort == SortOption.distance && userPos != null) {
      final userLatLng = LatLng(userPos.latitude, userPos.longitude);
      combinedItems.sort((a, b) {
        final locA = a is TouristSpot ? a.location : (a as Business).location;
        final locB = b is TouristSpot ? b.location : (b as Business).location;
        final distA = distCalc.as(LengthUnit.Meter, userLatLng, locA);
        final distB = distCalc.as(LengthUnit.Meter, userLatLng, locB);
        return distA.compareTo(distB);
      });
    } else if (_selectedSort == SortOption.priceLow) {
      combinedItems.sort((a, b) {
        final priceA = a is TouristSpot ? _priceValue(a.priceRange) : 0;
        final priceB = b is TouristSpot ? _priceValue(b.priceRange) : 0;
        return priceA.compareTo(priceB);
      });
    } else {
      // Featured
      combinedItems.sort((a, b) {
        final featA = a is TouristSpot
            ? a.isFeatured
            : (a as Business).isFeatured;
        final featB = b is TouristSpot
            ? b.isFeatured
            : (b as Business).isFeatured;
        return (featB ? 1 : 0).compareTo(featA ? 1 : 0);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Local Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(spotsProvider.notifier).syncSpots();
          await ref.read(businessesProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            // Marketing Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Own a Local Business?',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get listed on our map and reach tourists instantly.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessPromotionFormScreen(),
                          ),
                        );
                      },
                      child: const Text('Post Business'),
                    ),
                  ],
                ),
              ),
            ),

            // Filters Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explore Services',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        DropdownButton<SortOption>(
                          value: _selectedSort,
                          icon: const Icon(Icons.sort, size: 18),
                          underline: const SizedBox(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedSort = val);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: SortOption.featured,
                              child: Text('Sort: Featured'),
                            ),
                            DropdownMenuItem(
                              value: SortOption.distance,
                              child: Text('Sort: Nearest'),
                            ),
                            DropdownMenuItem(
                              value: SortOption.priceLow,
                              child: Text('Sort: Price (Low)'),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        ToggleButtons(
                          isSelected: [
                            _isGridView == false,
                            _isGridView == true,
                          ],
                          onPressed: (index) {
                            setState(() => _isGridView = index == 1);
                          },
                          borderRadius: BorderRadius.circular(8),
                          constraints: const BoxConstraints(
                            minHeight: 32,
                            minWidth: 32,
                          ),
                          children: const [
                            Icon(Icons.view_list, size: 18),
                            Icon(Icons.grid_view, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Business List OR Grid
            if (_isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = combinedItems[index];
                    final name = item is TouristSpot
                        ? item.name
                        : (item as Business).name;
                    final imageUrl = item is TouristSpot
                        ? item.imageUrl
                        : (item as Business).imageUrl;
                    final isFeatured = item is TouristSpot
                        ? item.isFeatured
                        : (item as Business).isFeatured;
                    final location = item is TouristSpot
                        ? item.location
                        : (item as Business).location;
                    final priceRange = item is TouristSpot
                        ? item.priceRange
                        : null;

                    String distStr = '';
                    if (userPos != null) {
                      final m = distCalc.as(
                        LengthUnit.Meter,
                        LatLng(userPos.latitude, userPos.longitude),
                        location,
                      );
                      distStr = m > 1000
                          ? '${(m / 1000).toStringAsFixed(1)} km'
                          : '${m}m';
                    }

                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          if (item is TouristSpot) {
                            Navigator.push(
                              context,
                              SpotDetailScreen.route(item),
                            );
                          } else if (item is Business) {
                            Navigator.push(
                              context,
                              BusinessDetailScreen.route(item),
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 600,
                                  ),
                                  if (isFeatured)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentOrange,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          '★ Promoted',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (priceRange != null)
                                      Text(
                                        priceRange,
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (distStr.isNotEmpty)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            distStr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
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
                  }, childCount: combinedItems.length),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = combinedItems[index];
                  final name = item is TouristSpot
                      ? item.name
                      : (item as Business).name;
                  final imageUrl = item is TouristSpot
                      ? item.imageUrl
                      : (item as Business).imageUrl;
                  final isFeatured = item is TouristSpot
                      ? item.isFeatured
                      : (item as Business).isFeatured;
                  final location = item is TouristSpot
                      ? item.location
                      : (item as Business).location;
                  final category = item is TouristSpot
                      ? item.category
                      : (item as Business).category;
                  final priceRange = item is TouristSpot
                      ? item.priceRange
                      : null;
                  final promotionalMessage = item is TouristSpot
                      ? item.promotionalMessage
                      : null;
                  final contactPhone = item is TouristSpot
                      ? item.contactPhone
                      : (item as Business).contactPhone;

                  String distStr = '';
                  if (userPos != null) {
                    final m = distCalc.as(
                      LengthUnit.Meter,
                      LatLng(userPos.latitude, userPos.longitude),
                      location,
                    );
                    distStr = m > 1000
                        ? '${(m / 1000).toStringAsFixed(1)} km'
                        : '${m}m';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        if (item is TouristSpot) {
                          Navigator.push(context, SpotDetailScreen.route(item));
                        } else if (item is Business) {
                          Navigator.push(
                            context,
                            BusinessDetailScreen.route(item),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Header
                          SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 600,
                                ),
                                if (isFeatured)
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentOrange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '★ Promoted',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    if (priceRange != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          priceRange,
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (promotionalMessage != null)
                                  Text(
                                    '"$promotionalMessage"',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      distStr.isNotEmpty
                                          ? '$distStr from you'
                                          : 'Location available',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.category,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      category.name.toUpperCase(),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                // Actions
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          if (contactPhone != null) {
                                            launchUrl(
                                              Uri.parse('tel:$contactPhone'),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'No contact info provided',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.call, size: 18),
                                        label: const Text('Contact'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          launchUrl(
                                            Uri.parse(
                                              'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.directions,
                                          size: 18,
                                        ),
                                        label: const Text('Navigate'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: combinedItems.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
