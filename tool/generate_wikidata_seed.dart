import 'dart:convert';
import 'dart:io';

String _escapeSqlString(String? value) {
  if (value == null || value.isEmpty) return 'NULL';
  final escaped = value.replaceAll("'", "''");
  return "'$escaped'";
}

void main() {
  final file = File('server/wikidata_tourist_spots.json');
  if (!file.existsSync()) {
    print('JSON file not found.');
    return;
  }
  
  final jsonString = file.readAsStringSync();
  final list = jsonDecode(jsonString) as List<dynamic>;
  
  final sqlFile = File('supabase/seed_wikidata_spots.sql');
  final buffer = StringBuffer()
    ..writeln('-- Generated from server/wikidata_tourist_spots.json')
    ..writeln('-- Run this to populate the database')
    ..writeln()
    ..writeln('-- Clear existing spots before repopulating')
    ..writeln('DELETE FROM tourist_spots CASCADE;')
    ..writeln()
    ..writeln('INSERT INTO tourist_spots (id, name, description, latitude, longitude, category, image_url, status, is_featured)')
    ..writeln('VALUES');
    
  for (var i = 0; i < list.length; i++) {
    final spot = list[i] as Map<String, dynamic>;
    final suffix = i == list.length - 1 ? ';' : ',';
    
    // Generate UUID
    final id = 'wikidata-$i'; 
    
    // Some Wikidata descriptions are very long or empty
    var desc = spot['description'] as String;
    if (desc.isEmpty) desc = 'A beautiful destination in Nepal.';
    
    buffer.writeln('(');
    buffer.write('  '); buffer.write(_escapeSqlString(id)); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(spot['name']?.toString())); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(desc)); buffer.writeln(',');
    buffer.write('  '); buffer.write(spot['latitude']); buffer.writeln(',');
    buffer.write('  '); buffer.write(spot['longitude']); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(spot['category']?.toString() ?? 'historicalSites')); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(spot['image_url']?.toString())); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString('approved')); buffer.writeln(',');
    buffer.write('  false');
    buffer.writeln(')$suffix');
  }
  
  sqlFile.writeAsStringSync(buffer.toString());
  print('Wrote ${list.length} rows to ${sqlFile.path}');
}
