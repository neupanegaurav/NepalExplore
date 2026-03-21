import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/core/providers/ai_provider.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/spots/presentation/spot_detail_screen.dart';

class SpotDetailsSheet extends ConsumerWidget {
  const SpotDetailsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSpot = ref.watch(selectedSpotProvider);

    if (selectedSpot == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, top: 16.0, bottom: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedSpot.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.read(selectedSpotProvider.notifier).set(null);
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Hero(
                    tag: 'spot_image_${selectedSpot.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        selectedSpot.imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 220,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(child: Icon(Icons.broken_image, size: 48)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'About this place',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    selectedSpot.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8.0),
                      Text(
                        'AI Cultural Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Consumer(
                    builder: (context, ref, child) {
                      final aiInsights = ref.watch(aiInsightsProvider(selectedSpot));

                      return aiInsights.when(
                        data: (insightText) => Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            insightText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                ),
                          ),
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Text(
                          'Could not load insights.',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  if (selectedSpot.userImages.isNotEmpty) ...[
                    Text(
                      'User Pictures',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12.0),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedSpot.userImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                selectedSpot.userImages[index],
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SpotDetailScreen.route(selectedSpot),
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('View Full Details'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _launchNavigation(selectedSpot),
                        icon: const Icon(Icons.navigation),
                        padding: const EdgeInsets.all(16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchNavigation(TouristSpot spot) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${spot.location.latitude},${spot.location.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
