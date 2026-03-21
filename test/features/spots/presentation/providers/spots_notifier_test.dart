import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('SpotsNotifier', () {
    test('initial state has data', () {
      final container = ProviderContainer();
      final spots = container.read(spotsProvider);

      expect(spots, isNotEmpty);
      container.dispose();
    });

    test('addSpot adds a new spot', () async {
      final container = ProviderContainer();
      final previousCount = container.read(spotsProvider).length;

      final newSpot = TouristSpot(
        id: '999',
        name: 'Test Spot',
        description: 'A test description',
        location: LatLng(28.0, 84.0),
        category: SpotCategory.historicalSites,
        imageUrl: '',
        status: ApprovalStatus.pending,
      );

      await container.read(spotsProvider.notifier).addSpot(newSpot);
      final spots = container.read(spotsProvider);

      expect(spots.length, previousCount + 1);
      expect(spots.last.id, '999');
      container.dispose();
    });
  });
}
