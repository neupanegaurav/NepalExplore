import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/core/config/app_config.dart';

class SpotMediaService {
  SpotMediaService({required SupabaseClient client, String? bucketName})
    : _client = client,
      _bucketName = bucketName ?? AppConfig.spotImagesBucket;

  final SupabaseClient _client;
  final String _bucketName;

  Future<List<String>> uploadImages({
    required String spotId,
    required List<XFile> images,
  }) async {
    if (images.isEmpty) {
      return const [];
    }

    final uploadedUrls = <String>[];
    for (var index = 0; index < images.length; index++) {
      final image = images[index];
      final extension = p.extension(image.name).toLowerCase();
      final objectPath =
          'spots/$spotId/${DateTime.now().millisecondsSinceEpoch}_$index$extension';
      final bytes = await image.readAsBytes();

      await _client.storage
          .from(_bucketName)
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              contentType: _contentTypeFor(extension),
              upsert: false,
            ),
          );

      uploadedUrls.add(
        _client.storage.from(_bucketName).getPublicUrl(objectPath),
      );
    }

    return uploadedUrls;
  }

  String _contentTypeFor(String extension) {
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.heic':
        return 'image/heic';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
