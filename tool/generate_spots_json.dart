import 'dart:convert';
import 'dart:io';

import 'package:nepal_explore/features/spots/data/spots_data.dart';

Future<void> main() async {
  final serverDirectory = Directory('server');
  if (!serverDirectory.existsSync()) {
    serverDirectory.createSync(recursive: true);
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final file = File('server/spots.json');
  final payload = dummyTouristSpots.map((spot) => spot.toJson()).toList();

  await file.writeAsString('${encoder.convert(payload)}\n');
  stdout.writeln('Wrote ${payload.length} spots to ${file.path}');
}
