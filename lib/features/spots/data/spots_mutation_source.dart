import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/core/config/app_config.dart';
import 'package:nepal_explore/features/spots/data/spot_media_service.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';

abstract class SpotsMutationSource {
  Future<TouristSpot> submitSpot(
    TouristSpot spot, {
    List<XFile> images = const [],
  });

  Future<TouristSpot> updateSpotStatus(String id, ApprovalStatus status);
}

class SupabaseSpotsMutationSource implements SpotsMutationSource {
  SupabaseSpotsMutationSource({
    required SupabaseClient client,
    SpotMediaService? mediaService,
    String? table,
  }) : _client = client,
       _mediaService = mediaService ?? SpotMediaService(client: client),
       _table = table ?? AppConfig.supabaseTable;

  final SupabaseClient _client;
  final SpotMediaService _mediaService;
  final String _table;

  @override
  Future<TouristSpot> submitSpot(
    TouristSpot spot, {
    List<XFile> images = const [],
  }) async {
    final now = DateTime.now();
    final uploadedImageUrls = await _mediaService.uploadImages(
      spotId: spot.id,
      images: images,
    );

    final normalizedSpot = spot.copyWith(
      status: ApprovalStatus.pending,
      imageUrl: uploadedImageUrls.isNotEmpty
          ? uploadedImageUrls.first
          : (spot.imageUrl.isNotEmpty
                ? spot.imageUrl
                : AppConfig.fallbackSpotImageUrl(spot.id)),
      userImages: uploadedImageUrls.isNotEmpty
          ? uploadedImageUrls
          : (spot.userImages.isNotEmpty
                ? spot.userImages
                : <String>[if (spot.imageUrl.isNotEmpty) spot.imageUrl]),
      isFeatured: false,
      createdAt: now,
      updatedAt: now,
    );

    final insertPayload = Map<String, dynamic>.from(
      normalizedSpot.toRemoteJson(),
    )..removeWhere((key, value) => value == null);
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId != null) {
      insertPayload['submitted_by'] = currentUserId;
    }

    // Public/mobile clients can insert pending rows, but they cannot read them
    // back through the public select policy. Avoid requesting a returned row here.
    await _client.from(_table).insert(insertPayload);

    return normalizedSpot;
  }

  @override
  Future<TouristSpot> updateSpotStatus(String id, ApprovalStatus status) async {
    final response = await _client
        .from(_table)
        .update({
          'status': status.storageKey,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return TouristSpot.fromJson(response);
  }
}
