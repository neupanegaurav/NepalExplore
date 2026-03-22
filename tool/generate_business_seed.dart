import 'dart:convert';
import 'dart:io';

String _escapeSqlString(String? value) {
  if (value == null || value.isEmpty) return 'NULL';
  final escaped = value.replaceAll("'", "''");
  return "'$escaped'";
}

void main() {
  final file = File('server/wikidata_businesses.json');
  if (!file.existsSync()) {
    print('JSON file not found.');
    return;
  }
  
  final jsonString = file.readAsStringSync();
  final list = jsonDecode(jsonString) as List<dynamic>;
  
  final sqlFile = File('supabase/seed_businesses.sql');
  final buffer = StringBuffer()
    ..writeln('-- Generated from server/wikidata_businesses.json')
    ..writeln('-- Run this to populate the businesses table')
    ..writeln()
    ..writeln('-- Clear existing businesses before repopulating')
    ..writeln('DELETE FROM businesses WHERE id LIKE \'wikidata-biz-%\';')
    ..writeln()
    ..writeln('INSERT INTO businesses (id, name, description, latitude, longitude, category, image_url, contact_phone, contact_email, website, status, is_featured)')
    ..writeln('VALUES');
    
  for (var i = 0; i < list.length; i++) {
    final biz = list[i] as Map<String, dynamic>;
    final suffix = i == list.length - 1 ? ';' : ',';
    
    final id = 'wikidata-biz-$i'; 
    
    var desc = biz['description'] as String;
    if (desc.isEmpty) desc = 'Local business in Nepal.';
    
    buffer.writeln('(');
    buffer.write('  '); buffer.write(_escapeSqlString(id)); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(biz['name']?.toString())); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(desc)); buffer.writeln(',');
    buffer.write('  '); buffer.write(biz['latitude']); buffer.writeln(',');
    buffer.write('  '); buffer.write(biz['longitude']); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(biz['category']?.toString() ?? 'dining')); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(biz['image_url']?.toString())); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(biz['phone']?.toString())); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(biz['email']?.toString())); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString(biz['website']?.toString())); buffer.writeln(',');
    buffer.write('  '); buffer.write(_escapeSqlString('approved')); buffer.writeln(',');
    buffer.write('  false');
    buffer.writeln(')$suffix');
  }
  
  sqlFile.writeAsStringSync(buffer.toString());
  print('Wrote ${list.length} rows to ${sqlFile.path}');
}
