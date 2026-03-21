import 'dart:convert';
import 'dart:io';

import 'package:nepal_explore/features/spots/data/spots_data.dart';

String _escapeSqlString(String value) => value.replaceAll("'", "''");

String _sqlLiteral(String? value) {
  if (value == null) {
    return 'NULL';
  }
  return "'${_escapeSqlString(value)}'";
}

String _jsonbLiteral(List<String> values) {
  final json = jsonEncode(values);
  return "'${_escapeSqlString(json)}'::jsonb";
}

Future<void> main() async {
  final directory = Directory('supabase');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final file = File('supabase/seed_tourist_spots.sql');
  final buffer = StringBuffer()
    ..writeln('-- Generated from lib/features/spots/data/spots_data.dart')
    ..writeln('-- Run this after schema_tourist_spots.sql')
    ..writeln()
    ..writeln('insert into public.tourist_spots (')
    ..writeln(
      '  id, name, description, latitude, longitude, category, image_url, user_images, status,',
    )
    ..writeln(
      '  price_range, contact_phone, contact_email, promotional_message, is_featured',
    )
    ..writeln(')')
    ..writeln('values');

  for (var i = 0; i < dummyTouristSpots.length; i++) {
    final spot = dummyTouristSpots[i];
    final suffix = i == dummyTouristSpots.length - 1 ? ';' : ',';
    buffer.writeln('(');
    buffer.writeln('  ${_sqlLiteral(spot.id)},');
    buffer.writeln('  ${_sqlLiteral(spot.name)},');
    buffer.writeln('  ${_sqlLiteral(spot.description)},');
    buffer.writeln('  ${spot.location.latitude},');
    buffer.writeln('  ${spot.location.longitude},');
    buffer.writeln('  ${_sqlLiteral(spot.category.name)},');
    buffer.writeln('  ${_sqlLiteral(spot.imageUrl)},');
    buffer.writeln('  ${_jsonbLiteral(spot.userImages)},');
    buffer.writeln('  ${_sqlLiteral(spot.status.name)},');
    buffer.writeln('  ${_sqlLiteral(spot.priceRange)},');
    buffer.writeln('  ${_sqlLiteral(spot.contactPhone)},');
    buffer.writeln('  ${_sqlLiteral(spot.contactEmail)},');
    buffer.writeln('  ${_sqlLiteral(spot.promotionalMessage)},');
    buffer.writeln('  ${spot.isFeatured}');
    buffer.writeln(')$suffix');
  }

  await file.writeAsString(buffer.toString());
  stdout.writeln('Wrote ${dummyTouristSpots.length} rows to ${file.path}');
}
