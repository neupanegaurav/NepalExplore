import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final query = '''
SELECT ?place ?placeLabel ?placeDescription ?lat ?lon ?image ?instanceOf ?phone ?email ?website
WHERE {
  ?place wdt:P17 wd:Q837.
  { 
    ?place wdt:P31 ?instanceOf. 
    FILTER (?instanceOf IN (wd:Q8701, wd:Q11707, wd:Q18701, wd:Q12262, wd:Q1197821, wd:Q301385, wd:Q16917, wd:Q1507421))
  }
  
  ?place p:P625 ?coordinate.
  ?coordinate psv:P625 ?coordinate_node.
  ?coordinate_node wikibase:geoLatitude ?lat.
  ?coordinate_node wikibase:geoLongitude ?lon.
  
  OPTIONAL { ?place wdt:P18 ?image. }
  OPTIONAL { ?place wdt:P1329 ?phone. }
  OPTIONAL { ?place wdt:P968 ?email. }
  OPTIONAL { ?place wdt:P856 ?website. }
  
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
    print('Failed to query Wikidata: ${response.statusCode}');
    return;
  }

  final responseBody = await response.transform(utf8.decoder).join();
  final data = jsonDecode(responseBody);
  
  final results = data['results']['bindings'] as List<dynamic>;
  print('Found ${results.length} businesses.');
  
  final businesses = <Map<String, dynamic>>[];
  
  for (final item in results) {
    final name = item['placeLabel']?['value'] ?? '';
    final description = item['placeDescription']?['value'] ?? '';
    final lat = double.tryParse(item['lat']?['value'] ?? '') ?? 0.0;
    final lon = double.tryParse(item['lon']?['value'] ?? '') ?? 0.0;
    String image = item['image']?['value'] ?? '';
    final instanceOf = item['instanceOf']?['value'] ?? '';
    final phone = item['phone']?['value'] ?? '';
    final email = item['email']?['value'] ?? '';
    final website = item['website']?['value'] ?? '';
    
    // Transform Wikimedia URL to thumbnail if possible
    if (image.contains('commons.wikimedia.org')) {
      final fileName = Uri.decodeFull(image.split('/').last);
      image = 'https://commons.wikimedia.org/wiki/Special:FilePath/$fileName?width=1000';
    } else if (image.isEmpty) {
      image = 'https://placehold.co/600x400?text=No+Image';
    }
    
    if (name.isEmpty || (name.startsWith('Q') && RegExp(r'^Q\d+\$').hasMatch(name))) continue;
    
    String category = _mapCategory(instanceOf, name, description);

    businesses.add({
      'name': name,
      'description': description,
      'latitude': lat,
      'longitude': lon,
      'image_url': image,
      'category': category,
      'phone': phone,
      'email': email,
      'website': website,
      'status': 'approved',
      'is_featured': false,
    });
  }

  // Deduplicate by name
  final uniqueBusinesses = <String, Map<String, dynamic>>{};
  for (final biz in businesses) {
    uniqueBusinesses[biz['name'] as String] = biz;
  }

  final finalText = const JsonEncoder.withIndent('  ').convert(uniqueBusinesses.values.toList());
  File('server/wikidata_businesses.json').writeAsStringSync(finalText);
  print('Saved ${uniqueBusinesses.length} unique businesses to server/wikidata_businesses.json');
}

String _mapCategory(String instanceOf, String name, String description) {
  final fullText = '$name $description'.toLowerCase();
  
  if (instanceOf.contains('Q8701') || fullText.contains('hotel') || fullText.contains('resort') || fullText.contains('guest house') || fullText.contains('inn')) {
    return 'hotels';
  }
  if (instanceOf.contains('Q11707') || fullText.contains('restaurant') || fullText.contains('cafe') || fullText.contains('dining') || fullText.contains('food')) {
    return 'dining';
  }
  if (instanceOf.contains('Q18701') || instanceOf.contains('Q12262')) {
    return 'dining'; // Group bars/clubs under dining for now
  }
  if (fullText.contains('travel') || fullText.contains('agent') || fullText.contains('trekking') || fullText.contains('expedition')) {
    return 'touristAgents';
  }
  if (fullText.contains('ticket')) {
    return 'tickets';
  }
  if (fullText.contains('guide')) {
    return 'guides';
  }
  
  return 'dining'; // Default to dining or we can add 'other' later
}
