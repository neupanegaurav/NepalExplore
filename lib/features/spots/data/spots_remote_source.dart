import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nepal_explore/core/config/app_config.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/spots/domain/business.dart';

class SpotsRemoteSnapshot {
  const SpotsRemoteSnapshot({
    required this.spots,
    required this.sourceLabel,
    required this.rawRows,
  });

  final List<TouristSpot> spots;
  final String sourceLabel;
  final List<Map<String, dynamic>> rawRows;
}

abstract class SpotsRemoteSource {
  Future<SpotsRemoteSnapshot> fetchSnapshot();
}

class SupabaseRestSpotsRemoteSource implements SpotsRemoteSource {
  SupabaseRestSpotsRemoteSource({
    http.Client? client,
    String? projectUrl,
    String? anonKey,
    String? schema,
    String? table,
  }) : _client = client ?? http.Client(),
       _projectUrl = projectUrl ?? AppConfig.supabaseUrl,
       _anonKey = anonKey ?? AppConfig.supabaseAnonKey,
       schema = schema ?? AppConfig.supabaseSchema,
       table = table ?? AppConfig.supabaseTable;

  final http.Client _client;
  final String _projectUrl;
  final String _anonKey;
  final String schema;
  final String table;

  @override
  Future<SpotsRemoteSnapshot> fetchSnapshot() async {
    if (_projectUrl.isEmpty || _anonKey.isEmpty) {
      throw Exception(
        'Supabase config is missing. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    final projectUri = Uri.parse(_projectUrl);
    final requestUri = projectUri
        .resolve('/rest/v1/$table')
        .replace(
          queryParameters: const {
            'select': '*',
            'deleted_at': 'is.null',
            'status': 'eq.approved',
            'order': 'updated_at.desc',
          },
        );

    final response = await _client.get(
      requestUri,
      headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Accept': 'application/json',
        if (schema != 'public') 'Accept-Profile': schema,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch Supabase rows (${response.statusCode}) from $requestUri: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw Exception('Unexpected Supabase response format.');
    }

    final rawRows = decoded.whereType<Map<String, dynamic>>().toList();
    final spots = rawRows.map(TouristSpot.fromJson).toList();

    return SpotsRemoteSnapshot(
      spots: spots,
      sourceLabel: '$requestUri [schema=$schema]',
      rawRows: rawRows,
    );
  }
}

class JsonFeedSpotsRemoteSource implements SpotsRemoteSource {
  JsonFeedSpotsRemoteSource({http.Client? client, Uri? feedUri})
    : _client = client ?? http.Client(),
      feedUri = feedUri ?? Uri.parse(AppConfig.spotsFeedUrl);

  final http.Client _client;
  final Uri feedUri;

  @override
  Future<SpotsRemoteSnapshot> fetchSnapshot() async {
    final response = await _client.get(feedUri);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch spots feed (${response.statusCode}) from $feedUri',
      );
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> rawSpots;
    if (decoded is List<dynamic>) {
      rawSpots = decoded;
    } else if (decoded is Map<String, dynamic> &&
        decoded['spots'] is List<dynamic>) {
      rawSpots = decoded['spots'] as List<dynamic>;
    } else if (decoded is Map<String, dynamic> &&
        decoded['rows'] is List<dynamic>) {
      rawSpots = decoded['rows'] as List<dynamic>;
    } else {
      throw Exception('Unexpected spots feed format.');
    }

    final rawRows = rawSpots.cast<Map<String, dynamic>>();

    return SpotsRemoteSnapshot(
      spots: rawRows.map(TouristSpot.fromJson).toList(),
      sourceLabel: feedUri.toString(),
      rawRows: rawRows,
    );
  }
}

class BusinessRemoteSnapshot {
  const BusinessRemoteSnapshot({
    required this.businesses,
    required this.sourceLabel,
    required this.rawRows,
  });

  final List<Business> businesses;
  final String sourceLabel;
  final List<Map<String, dynamic>> rawRows;
}

abstract class BusinessRemoteSource {
  Future<BusinessRemoteSnapshot> fetchSnapshot();
}

class SupabaseRestBusinessRemoteSource implements BusinessRemoteSource {
  SupabaseRestBusinessRemoteSource({
    http.Client? client,
    String? projectUrl,
    String? anonKey,
    String? schema,
    String? table,
  }) : _client = client ?? http.Client(),
       _projectUrl = projectUrl ?? AppConfig.supabaseUrl,
       _anonKey = anonKey ?? AppConfig.supabaseAnonKey,
       schema = schema ?? AppConfig.supabaseSchema,
       table = table ?? 'businesses';

  final http.Client _client;
  final String _projectUrl;
  final String _anonKey;
  final String schema;
  final String table;

  @override
  Future<BusinessRemoteSnapshot> fetchSnapshot() async {
    if (_projectUrl.isEmpty || _anonKey.isEmpty) {
      throw Exception('Supabase config is missing.');
    }

    final projectUri = Uri.parse(_projectUrl);
    final requestUri = projectUri.resolve('/rest/v1/$table').replace(
      queryParameters: const {
        'select': '*',
        'status': 'eq.approved',
        'order': 'updated_at.desc',
      },
    );

    final response = await _client.get(
      requestUri,
      headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Accept': 'application/json',
        if (schema != 'public') 'Accept-Profile': schema,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch businesses (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    final rawRows = (decoded as List<dynamic>).cast<Map<String, dynamic>>();
    final businesses = rawRows.map(Business.fromJson).toList();

    return BusinessRemoteSnapshot(
      businesses: businesses,
      sourceLabel: '$requestUri',
      rawRows: rawRows,
    );
  }
}

class JsonFeedBusinessRemoteSource implements BusinessRemoteSource {
  JsonFeedBusinessRemoteSource({http.Client? client, Uri? feedUri})
    : _client = client ?? http.Client(),
      feedUri = feedUri ?? Uri.parse('${AppConfig.spotsFeedUrl}/businesses.json');

  final http.Client _client;
  final Uri feedUri;

  @override
  Future<BusinessRemoteSnapshot> fetchSnapshot() async {
    return const BusinessRemoteSnapshot(
      businesses: [],
      sourceLabel: 'local-fallback',
      rawRows: [],
    );
  }
}
