import 'package:nepal_explore/core/database/app_document_database.dart';
import 'package:nepal_explore/features/spots/data/spots_data.dart';
import 'package:nepal_explore/features/spots/data/spots_mutation_source.dart';
import 'package:nepal_explore/features/spots/data/spots_remote_source.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:image_picker/image_picker.dart';

class SpotsSyncReport {
  const SpotsSyncReport({
    required this.itemCount,
    required this.syncedAt,
    required this.source,
  });

  final int itemCount;
  final DateTime syncedAt;
  final String source;
}

class SpotsRepository {
  SpotsRepository({
    required AppDocumentDatabase database,
    required SpotsRemoteSource remoteSource,
    SpotsMutationSource? mutationSource,
  }) : _database = database,
       _remoteSource = remoteSource,
       _mutationSource = mutationSource,
       _memorySpots = <TouristSpot>[];

  SpotsRepository.preview({List<TouristSpot>? seedSpots})
    : _database = null,
      _remoteSource = null,
      _mutationSource = null,
      _memorySpots = List<TouristSpot>.from(seedSpots ?? dummyTouristSpots);

  static const String collectionName = 'tourist_spots';

  final AppDocumentDatabase? _database;
  final SpotsRemoteSource? _remoteSource;
  final SpotsMutationSource? _mutationSource;
  final List<TouristSpot> _memorySpots;

  Future<List<TouristSpot>> loadSpots() async {
    final database = _database;
    if (database == null) {
      return List<TouristSpot>.from(_memorySpots);
    }

    final existing = await _loadFromDatabase();
    if (existing.isNotEmpty) {
      return existing;
    }

    await database.replaceCollection(
      collectionName,
      dummyTouristSpots.map(
        (spot) => DatabaseDocument(id: spot.id, payload: spot.toJson()),
      ),
    );

    return _loadFromDatabase();
  }

  Future<TouristSpot> saveSpot(TouristSpot spot) async {
    final database = _database;
    if (database == null) {
      final index = _memorySpots.indexWhere(
        (existing) => existing.id == spot.id,
      );
      if (index == -1) {
        _memorySpots.add(spot);
      } else {
        _memorySpots[index] = spot;
      }
      return spot;
    }

    await database.upsert(
      collectionName,
      DatabaseDocument(id: spot.id, payload: spot.toJson()),
    );
    return spot;
  }

  Future<TouristSpot> submitSpot(
    TouristSpot spot, {
    List<XFile> images = const [],
  }) async {
    final mutationSource = _mutationSource;
    final submittedSpot = mutationSource == null
        ? spot
        : await mutationSource.submitSpot(spot, images: images);
    await saveSpot(submittedSpot);
    return submittedSpot;
  }

  Future<TouristSpot?> getSpotById(String id) async {
    if (_database == null) {
      for (final spot in _memorySpots) {
        if (spot.id == id) {
          return spot;
        }
      }
      return null;
    }

    final spots = await _loadFromDatabase();
    for (final spot in spots) {
      if (spot.id == id) {
        return spot;
      }
    }
    return null;
  }

  Future<TouristSpot> updateSpotStatus(String id, ApprovalStatus status) async {
    final mutationSource = _mutationSource;
    if (mutationSource != null) {
      final updated = await mutationSource.updateSpotStatus(id, status);
      await saveSpot(updated);
      return updated;
    }

    final existing = await getSpotById(id);
    if (existing == null) {
      throw Exception('Spot $id not found.');
    }

    final updated = existing.copyWith(status: status);
    await saveSpot(updated);
    return updated;
  }

  Future<SpotsSyncReport> syncFromServer() async {
    final remoteSource = _remoteSource;
    final database = _database;
    if (remoteSource == null || database == null) {
      throw UnsupportedError('Remote sync is not available in preview mode.');
    }

    final snapshot = await remoteSource.fetchSnapshot();
    final remoteSpots = snapshot.spots;
    final localSpots = await _loadFromDatabase();
    final pendingLocalSpots = localSpots
        .where((spot) => spot.status != ApprovalStatus.approved)
        .toList();
    final remoteSpotIds = remoteSpots.map((spot) => spot.id).toSet();
    final mergedSpots = [
      ...remoteSpots,
      ...pendingLocalSpots.where((spot) => !remoteSpotIds.contains(spot.id)),
    ];
    final syncedAt = DateTime.now();

    await database.replaceCollection(
      collectionName,
      mergedSpots.map(
        (spot) => DatabaseDocument(id: spot.id, payload: spot.toJson()),
      ),
    );

    await database.markCollectionSynced(
      collection: collectionName,
      syncedAt: syncedAt,
      source: snapshot.sourceLabel,
    );

    return SpotsSyncReport(
      itemCount: remoteSpots.length,
      syncedAt: syncedAt,
      source: snapshot.sourceLabel,
    );
  }

  Future<DateTime?> getLastSyncedAt() {
    final database = _database;
    if (database == null) {
      return Future<DateTime?>.value(null);
    }
    return database.getLastSyncedAt(collectionName);
  }

  Future<List<TouristSpot>> _loadFromDatabase() async {
    final database = _database;
    if (database == null) {
      return List<TouristSpot>.from(_memorySpots);
    }

    final rawDocuments = await database.getAll(collectionName);
    return rawDocuments.map(TouristSpot.fromJson).toList();
  }
}
