import 'package:latlong2/latlong.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';

class Business {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final SpotCategory category;
  final String imageUrl;
  final List<String> userImages;
  final ApprovalStatus status;

  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  final String? promotionTier;
  final bool isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Business({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    required this.imageUrl,
    this.userImages = const [],
    this.status = ApprovalStatus.approved,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.promotionTier,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      category: SpotCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SpotCategory.dining,
      ),
      imageUrl: json['image_url'] as String? ?? '',
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      website: json['website'] as String?,
      status: ApprovalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApprovalStatus.approved,
      ),
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'category': category.name,
      'image_url': imageUrl,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'website': website,
      'status': status.name,
      'is_featured': isFeatured,
    };
  }
}
