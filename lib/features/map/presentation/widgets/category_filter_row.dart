import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';

class CategoryFilterRow extends ConsumerWidget {
  const CategoryFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(categoryFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: SpotCategory.values.map((category) {
          final isSelected = currentFilter == category;
          final colorScheme = Theme.of(context).colorScheme;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_getCategoryName(category)),
              selected: isSelected,
              onSelected: (selected) {
                ref
                    .read(categoryFilterProvider.notifier)
                    .set(selected ? category : null);
              },
              backgroundColor: Colors.white,
              selectedColor: colorScheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              shadowColor: Colors.black12,
              elevation: isSelected ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryName(SpotCategory category) {
    switch (category) {
      case SpotCategory.historicalSites:
        return 'Historical';
      case SpotCategory.religiousPlaces:
        return 'Religious';
      case SpotCategory.natureTrails:
        return 'Nature Trails';
      case SpotCategory.viewpoints:
        return 'Viewpoints';
      case SpotCategory.culturalCenters:
        return 'Cultural Centers';
      case SpotCategory.picnicArea:
        return 'Picnic Areas';
      case SpotCategory.sceneries:
        return 'Sceneries';
      case SpotCategory.mountains:
        return 'Mountains';
      case SpotCategory.offroadRiding:
        return 'Offroad Riding';
      case SpotCategory.cyclingSpots:
        return 'Cycling Spots';
      case SpotCategory.touristAgents:
        return 'Tourist Agents';
      case SpotCategory.hotels:
        return 'Hotels';
      case SpotCategory.tickets:
        return 'Tickets';
      case SpotCategory.guides:
        return 'Guides';
      case SpotCategory.dining:
        return 'Dining';
    }
  }
}
