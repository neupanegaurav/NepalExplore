import 'package:latlong2/latlong.dart';

enum SpotCategory {
  historicalSites,
  religiousPlaces,
  natureTrails,
  viewpoints,
  culturalCenters,
  picnicArea,
  sceneries,
  mountains,
  offroadRiding,
  cyclingSpots,
  touristAgents,
  hotels,
  tickets,
  guides,
  dining,
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

class TouristSpot {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final SpotCategory category;
  final String imageUrl;
  final List<String> userImages;
  final ApprovalStatus status;

  final String? priceRange;
  final String? contactPhone;
  final String? contactEmail;
  final String? promotionalMessage;
  final bool isFeatured;

  const TouristSpot({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    required this.imageUrl,
    this.userImages = const [],
    this.status = ApprovalStatus.approved,
    this.priceRange,
    this.contactPhone,
    this.contactEmail,
    this.promotionalMessage,
    this.isFeatured = false,
  });
}
