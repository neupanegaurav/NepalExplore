import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/core/config/app_config.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';

class AdminSpotsService {
  AdminSpotsService({required SupabaseClient client, String? table})
    : _client = client,
      _table = table ?? AppConfig.supabaseTable;

  final SupabaseClient _client;
  final String _table;

  Future<List<TouristSpot>> fetchSpots() async {
    final rows = await _client
        .from(_table)
        .select()
        .order('updated_at', ascending: false);

    return rows
        .whereType<Map<String, dynamic>>()
        .where((row) => row['deleted_at'] == null)
        .map(TouristSpot.fromJson)
        .toList();
  }

  Future<TouristSpot> updateStatus(String id, ApprovalStatus status) async {
    final row = await _client
        .from(_table)
        .update({
          'status': status.storageKey,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return TouristSpot.fromJson(row);
  }

  Future<TouristSpot> updateFeatured(String id, bool isFeatured) async {
    final row = await _client
        .from(_table)
        .update({
          'is_featured': isFeatured,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return TouristSpot.fromJson(row);
  }

  Future<TouristSpot> updateSpot(TouristSpot spot) async {
    final payload = Map<String, dynamic>.from(spot.toRemoteJson())
      ..remove('id')
      ..['updated_at'] = DateTime.now().toIso8601String();

    final row = await _client
        .from(_table)
        .update(payload)
        .eq('id', spot.id)
        .select()
        .single();

    return TouristSpot.fromJson(row);
  }

  Future<void> softDeleteSpot(String id) async {
    await _client
        .from(_table)
        .update({
          'deleted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}
