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

enum ApprovalStatus { pending, approved, rejected }

enum SubmissionKind { spot, business }

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
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final String? promotionalMessage;
  final String? promotionTier;
  final bool isFeatured;
  final SubmissionKind submissionKind;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.promotionalMessage,
    this.promotionTier,
    this.isFeatured = false,
    this.submissionKind = SubmissionKind.spot,
    this.createdAt,
    this.updatedAt,
  });

  TouristSpot copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? location,
    SpotCategory? category,
    String? imageUrl,
    List<String>? userImages,
    ApprovalStatus? status,
    String? priceRange,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? promotionalMessage,
    String? promotionTier,
    bool? isFeatured,
    SubmissionKind? submissionKind,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TouristSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      userImages: userImages ?? this.userImages,
      status: status ?? this.status,
      priceRange: priceRange ?? this.priceRange,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      promotionalMessage: promotionalMessage ?? this.promotionalMessage,
      promotionTier: promotionTier ?? this.promotionTier,
      isFeatured: isFeatured ?? this.isFeatured,
      submissionKind: submissionKind ?? this.submissionKind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'category': category.storageKey,
      'imageUrl': imageUrl,
      'userImages': userImages,
      'status': status.storageKey,
      'priceRange': priceRange,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'promotionalMessage': promotionalMessage,
      'promotionTier': promotionTier,
      'isFeatured': isFeatured,
      'submissionKind': submissionKind.storageKey,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'category': category.storageKey,
      'image_url': imageUrl,
      'user_images': userImages,
      'status': status.storageKey,
      'price_range': priceRange,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'promotional_message': promotionalMessage,
      'promotion_tier': promotionTier,
      'is_featured': isFeatured,
      'submission_kind': submissionKind.storageKey,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TouristSpot.fromJson(Map<String, dynamic> json) {
    return TouristSpot(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown Spot',
      description: json['description'] as String? ?? '',
      location: LatLng(
        _asDouble(json['latitude'] ?? json['lat']),
        _asDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      ),
      category: SpotCategoryX.fromStorageKey(
        (json['category'] ?? json['category_key']) as String?,
      ),
      imageUrl:
          (json['imageUrl'] ?? json['image_url'] ?? json['hero_image_url'])
              as String? ??
          '',
      userImages:
          ((json['userImages'] ?? json['user_images'] ?? json['gallery_images'])
                      as List<dynamic>? ??
                  const <dynamic>[])
              .map((image) => image.toString())
              .toList(),
      status: ApprovalStatusX.fromStorageKey(
        (json['status'] ?? json['approval_status']) as String?,
      ),
      priceRange: (json['priceRange'] ?? json['price_range']) as String?,
      contactName: (json['contactName'] ?? json['contact_name']) as String?,
      contactPhone: (json['contactPhone'] ?? json['contact_phone']) as String?,
      contactEmail: (json['contactEmail'] ?? json['contact_email']) as String?,
      promotionalMessage:
          (json['promotionalMessage'] ?? json['promotional_message'])
              as String?,
      promotionTier:
          (json['promotionTier'] ?? json['promotion_tier']) as String?,
      isFeatured:
          (json['isFeatured'] ?? json['is_featured'] ?? false) as bool? ??
          false,
      submissionKind: SubmissionKindX.fromStorageKey(
        (json['submissionKind'] ?? json['submission_kind']) as String?,
      ),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _asDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value?.toString() ?? '');
  }
}

extension SpotCategoryX on SpotCategory {
  String get storageKey => name;

  static SpotCategory fromStorageKey(String? value) {
    return SpotCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => SpotCategory.historicalSites,
    );
  }
}

extension ApprovalStatusX on ApprovalStatus {
  String get storageKey => name;

  static ApprovalStatus fromStorageKey(String? value) {
    return ApprovalStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ApprovalStatus.approved,
    );
  }
}

extension SubmissionKindX on SubmissionKind {
  String get storageKey => name;

  static SubmissionKind fromStorageKey(String? value) {
    return SubmissionKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => SubmissionKind.spot,
    );
  }
}
