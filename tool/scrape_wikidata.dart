import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final query = '''
SELECT ?place ?placeLabel ?placeDescription ?lat ?lon ?image ?instanceOf
WHERE {
  ?place wdt:P17 wd:Q837.
  { 
    ?place wdt:P31 ?instanceOf. 
    FILTER (?instanceOf IN (wd:Q570116, wd:Q3135272, wd:Q46169, wd:Q1370598, wd:Q81305, wd:Q1197821, wd:Q23397, wd:Q8502))
  } UNION {
    ?place wdt:P279 wd:Q570116.
    BIND(wd:Q570116 AS ?instanceOf)
  }
  
  ?place p:P625 ?coordinate.
  ?coordinate psv:P625 ?coordinate_node.
  ?coordinate_node wikibase:geoLatitude ?lat.
  ?coordinate_node wikibase:geoLongitude ?lon.
  
  OPTIONAL { ?place wdt:P18 ?image. }
  
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
LIMIT 5000
  ''';

  final url = Uri.parse('https://query.wikidata.org/sparql');
  final request = await HttpClient().postUrl(url);
  request.headers.set(HttpHeaders.acceptHeader, 'application/sparql-results+json');
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/sparql-query');
  request.headers.set('User-Agent', 'ExploreNepal/1.0 (Dart/HttpClient)');
  request.write(query);

  final response = await request.close();
  if (response.statusCode != HttpStatus.ok) {
    print('Failed to query Wikidata: \${response.statusCode}');
    return;
  }

  final responseBody = await response.transform(utf8.decoder).join();
  final data = jsonDecode(responseBody);
  
  final results = data['results']['bindings'] as List<dynamic>;
  print('Found \${results.length} places.');
  
  final spots = <Map<String, dynamic>>[];
  
  for (final item in results) {
    final name = item['placeLabel']?['value'] ?? '';
    final description = item['placeDescription']?['value'] ?? '';
    final lat = double.tryParse(item['lat']?['value'] ?? '') ?? 0.0;
    final lon = double.tryParse(item['lon']?['value'] ?? '') ?? 0.0;
    String image = item['image']?['value'] ?? '';
    final instanceOf = item['instanceOf']?['value'] ?? '';
    
    // Transform Wikimedia URL to thumbnail if possible
    if (image.contains('commons.wikimedia.org')) {
      // Use Special:FilePath with width parameter for fast loading
      final fileName = Uri.decodeFull(image.split('/').last);
      image = 'https://commons.wikimedia.org/wiki/Special:FilePath/$fileName?width=1000';
    } else if (image.isEmpty) {
      image = 'https://placehold.co/600x400?text=No+Image';
    }
    
    // Skip if no english name or label is a Q-code
    if (name.isEmpty || (name.startsWith('Q') && RegExp(r'^Q\d+\$').hasMatch(name))) continue;
    
    String category = _refineCategory(name, description, instanceOf);

    spots.add({
      'name': name,
      'description': description,
      'latitude': lat,
      'longitude': lon,
      'image_url': image.isNotEmpty ? image : 'https://placehold.co/600x400?text=No+Image',
      'category': category,
      'status': 'approved',
      'is_featured': false,
    });
  }

  // Deduplicate by name
  final uniqueSpots = <String, Map<String, dynamic>>{};
  for (final spot in spots) {
    if (!uniqueSpots.containsKey(spot['name'])) {
      uniqueSpots[spot['name'] as String] = spot;
    } else {
      // Prefer the one with an actual image
      if ((uniqueSpots[spot['name']]!['image_url'] as String).contains('placehold.co') && !(spot['image_url'] as String).contains('placehold.co')) {
         uniqueSpots[spot['name'] as String] = spot;
      }
      // Prefer the one with a description
      final existingDesc = uniqueSpots[spot['name']]!['description'] as String;
      final newDesc = spot['description'] as String;
      if (existingDesc.isEmpty && newDesc.isNotEmpty) {
          uniqueSpots[spot['name'] as String] = spot;
      }
    }
  }

  final finalText = const JsonEncoder.withIndent('  ').convert(uniqueSpots.values.toList());
  File('server/wikidata_tourist_spots.json').writeAsStringSync(finalText);
  print('Saved ${uniqueSpots.length} unique spots to server/wikidata_tourist_spots.json');
}

String _refineCategory(String name, String description, String instanceOf) {
  final fullText = '$name $description'.toLowerCase();
  
  // Mountains
  if (fullText.contains('peak') || 
      fullText.contains('himal') || 
      fullText.contains('mountain') || 
      fullText.contains('mt.') || 
      fullText.contains('summit') ||
      instanceOf.contains('Q8502')) {
    return 'mountains';
  }
  
  // Sceneries (Lakes/Rivers/Waterfalls)
  if (fullText.contains('lake') || 
      fullText.contains('pokhari') || 
      fullText.contains('tal') || 
      fullText.contains('river') || 
      fullText.contains('waterfall') || 
      fullText.contains('khola') ||
      instanceOf.contains('Q3135272')) {
    return 'sceneries';
  }
  
  // Religious Places
  if (fullText.contains('temple') || 
      fullText.contains('mandir') || 
      fullText.contains('stupa') || 
      fullText.contains('gumba') || 
      fullText.contains('monastery') || 
      fullText.contains('pagoda') || 
      fullText.contains('shrine') || 
      fullText.contains('bihar') ||
      fullText.contains('buddha')) {
    return 'religiousPlaces';
  }
  
  // Nature Trails / Parks
  if (fullText.contains('national park') || 
      fullText.contains('wildlife') || 
      fullText.contains('conservation') || 
      fullText.contains('jungle') || 
      fullText.contains('forest') || 
      fullText.contains('trail') || 
      fullText.contains('hiking') ||
      instanceOf.contains('Q46169') ||
      instanceOf.contains('Q23397')) {
    return 'natureTrails';
  }
  
  // Historical Sites
  if (fullText.contains('durbar') || 
      fullText.contains('square') || 
      fullText.contains('palace') || 
      fullText.contains('fort') || 
      fullText.contains('ancient') || 
      fullText.contains('museum') ||
      instanceOf.contains('Q81305') || 
      instanceOf.contains('Q1197821')) {
    return 'historicalSites';
  }

  // Viewpoints
  if (fullText.contains('view') || 
      fullText.contains('tower') || 
      fullText.contains('nagarkot') || 
      fullText.contains('sarangkot')) {
    return 'viewpoints';
  }
  
  // Cultural Centers
  if (fullText.contains('cultural') || 
      fullText.contains('center') || 
      instanceOf.contains('Q1370598')) {
    return 'culturalCenters';
  }

  return 'historicalSites'; // Default
}

