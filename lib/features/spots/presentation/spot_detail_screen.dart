import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/core/providers/ai_provider.dart';
import 'package:nepal_explore/core/theme/theme.dart';

class SpotDetailScreen extends ConsumerWidget {
  final TouristSpot spot;
  const SpotDetailScreen({super.key, required this.spot});

  static Route route(TouristSpot spot) {
    return MaterialPageRoute(builder: (_) => SpotDetailScreen(spot: spot));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiInsights = ref.watch(aiInsightsProvider(spot));
    final theme = Theme.of(context);
    final allImages = [spot.imageUrl, ...spot.userImages];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              title: Text(
                spot.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'spot_image_${spot.id}',
                    child: CachedNetworkImage(
                      imageUrl: spot.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Simple dimming overlay
                  Container(color: Colors.black.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          spot.category.name
                              .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppTheme.accentOrange,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Overview
                  Text('Overview', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(
                    spot.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.7,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // AI Insights (flat card)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentPurple.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: AppTheme.accentPurple,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI Insights',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.accentPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        aiInsights.when(
                          data: (text) => Text(
                            text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (e, s) => const Text('Insights unavailable.'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gallery Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gallery', style: theme.textTheme.headlineSmall),
                      TextButton.icon(
                        onPressed: () => _pickImages(context),
                        icon: const Icon(Icons.add_a_photo, size: 16),
                        label: const Text('Upload'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accentPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Gallery
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: allImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _openFullScreenGallery(context, allImages, index),
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 10),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: allImages[index],
                              fit: BoxFit.cover,
                              memCacheWidth: 400,
                              errorWidget: (context, url, error) => Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Map Routing
                  Text(
                    'Location & Routing',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 240,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final userLocAsync = ref.watch(userLocationProvider);
                        final destLatLng = spot.location;

                        return userLocAsync.when(
                          data: (userPos) {
                            final userLatLng = LatLng(
                              userPos.latitude,
                              userPos.longitude,
                            );
                            return FlutterMap(
                              options: MapOptions(
                                initialCameraFit: CameraFit.bounds(
                                  bounds: LatLngBounds.fromPoints([
                                    userLatLng,
                                    destLatLng,
                                  ]),
                                  padding: const EdgeInsets.all(40),
                                ),
                                interactionOptions: const InteractionOptions(
                                  flags:
                                      InteractiveFlag.drag |
                                      InteractiveFlag.pinchZoom,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.nepal_explore',
                                ),
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: [userLatLng, destLatLng],
                                      color: AppTheme.primaryColor,
                                      strokeWidth: 4,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: userLatLng,
                                      width: 24,
                                      height: 24,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                          border: Border.fromBorderSide(
                                            BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Marker(
                                      point: destLatLng,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppTheme.accentRed,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, s) =>
                              const Center(child: Text('Location unavailable')),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // Navigate button (flat, no gradient)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _launchNavigation(spot),
          icon: const Icon(Icons.navigation),
          label: const Text(
            'Navigate Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchNavigation(TouristSpot spot) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${spot.location.latitude},${spot.location.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _pickImages(BuildContext context) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 5);
    if (images.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${images.length} photo(s) submitted for review!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  void _openFullScreenGallery(
    BuildContext context,
    List<String> images,
    int startIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _FullScreenGallery(images: images, initialIndex: startIndex),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (_, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                memCacheWidth: 1200,
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 80,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
