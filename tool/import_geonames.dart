import 'dart:convert';
import 'dart:io';

const String _downloadBaseUrl = 'https://download.geonames.org/export/dump';

const Set<String> _defaultFeatureCodes = <String>{
  'ADM1',
  'ADM2',
  'ADM3',
  'ADM4',
  'PPLC',
  'PPLA',
  'PPLA2',
  'PPLA3',
  'PPLA4',
  'PPL',
};

const Map<String, String> _featureKinds = <String, String>{
  'ADM1': 'province',
  'ADM2': 'district',
  'ADM3': 'local_admin',
  'ADM4': 'local_admin',
  'PPLC': 'national_capital',
  'PPLA': 'province_capital',
  'PPLA2': 'admin_seat',
  'PPLA3': 'admin_seat',
  'PPLA4': 'admin_seat',
  'PPL': 'populated_place',
  'PPLL': 'abandoned_place',
};

const Map<String, String> _featureLabels = <String, String>{
  'ADM1': 'Province',
  'ADM2': 'District',
  'ADM3': 'Local administrative area',
  'ADM4': 'Sub-local administrative area',
  'PPLC': 'National capital',
  'PPLA': 'Province capital',
  'PPLA2': 'Administrative seat',
  'PPLA3': 'Administrative seat',
  'PPLA4': 'Administrative seat',
  'PPL': 'Populated place',
  'PPLL': 'Abandoned populated place',
};

Future<void> main(List<String> args) async {
  final options = ImportOptions.parse(args);
  if (options.showHelp) {
    stdout.writeln(ImportOptions.usage);
    return;
  }

  final downloadDir = Directory(options.downloadDir);
  if (!downloadDir.existsSync()) {
    downloadDir.createSync(recursive: true);
  }

  final countryCode = options.countryCode.toUpperCase();
  final zipFile = File('${downloadDir.path}/$countryCode.zip');
  final admin1File = File('${downloadDir.path}/admin1CodesASCII.txt');
  final admin2File = File('${downloadDir.path}/admin2Codes.txt');

  if (!options.skipDownload || !zipFile.existsSync()) {
    await _downloadFile('$_downloadBaseUrl/$countryCode.zip', zipFile);
  }
  if (!options.skipDownload || !admin1File.existsSync()) {
    await _downloadFile('$_downloadBaseUrl/admin1CodesASCII.txt', admin1File);
  }
  if (!options.skipDownload || !admin2File.existsSync()) {
    await _downloadFile('$_downloadBaseUrl/admin2Codes.txt', admin2File);
  }

  final countryDump = await _readZipEntry(zipFile.path, '$countryCode.txt');
  final admin1Names = _loadAdminNames(
    admin1File.readAsLinesSync(),
    countryCode: countryCode,
    expectedParts: 4,
  );
  final admin2Names = _loadAdminNames(
    admin2File.readAsLinesSync(),
    countryCode: countryCode,
    expectedParts: 4,
  );

  final acceptedFeatureCodes = <String>{
    ..._defaultFeatureCodes,
    if (options.includePpll) 'PPLL',
  };
  final places = <Map<String, dynamic>>[];
  final featureCounts = <String, int>{};

  for (final line in const LineSplitter().convert(countryDump)) {
    final fields = line.split('\t');
    if (fields.length < 19) {
      continue;
    }

    final featureCode = fields[7].trim();
    if (!acceptedFeatureCodes.contains(featureCode)) {
      continue;
    }

    final population = _parseInt(fields[14]);
    if (_isPopulationFiltered(featureCode, population, options.minPopulation)) {
      continue;
    }

    final name = fields[1].trim();
    final asciiName = fields[2].trim();
    final admin1Code = fields[10].trim();
    final admin2Code = fields[11].trim();

    places.add(<String, dynamic>{
      'geonameId': _parseInt(fields[0]),
      'name': name,
      'asciiName': asciiName,
      'alternateNames': _parseAlternateNames(
        raw: fields[3],
        primaryName: name,
        asciiName: asciiName,
        maxCount: options.maxAlternateNames,
      ),
      'latitude': _parseDouble(fields[4]),
      'longitude': _parseDouble(fields[5]),
      'featureClass': fields[6].trim(),
      'featureCode': featureCode,
      'featureLabel': _featureLabels[featureCode] ?? featureCode,
      'kind': _featureKinds[featureCode] ?? 'place',
      'countryCode': fields[8].trim(),
      'admin1Code': admin1Code,
      'admin1Name': admin1Names['$countryCode.$admin1Code'],
      'admin2Code': admin2Code,
      'admin2Name': admin2Names['$countryCode.$admin1Code.$admin2Code'],
      'admin3Code': fields[12].trim().isEmpty ? null : fields[12].trim(),
      'admin4Code': fields[13].trim().isEmpty ? null : fields[13].trim(),
      'population': population,
      'elevation': _parseNullableInt(fields[15]),
      'dem': _parseNullableInt(fields[16]),
      'timezone': fields[17].trim(),
      'modificationDate': fields[18].trim(),
    });

    featureCounts.update(featureCode, (value) => value + 1, ifAbsent: () => 1);
  }

  places.sort(_comparePlaces);

  final output = <String, dynamic>{
    'source': <String, dynamic>{
      'provider': 'GeoNames',
      'providerUrl': 'https://www.geonames.org/',
      'downloadUrl': '$_downloadBaseUrl/$countryCode.zip',
      'license': 'CC BY 4.0',
      'licenseUrl': 'https://creativecommons.org/licenses/by/4.0/',
      'countryCode': countryCode,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
    },
    'filters': <String, dynamic>{
      'minPopulation': options.minPopulation,
      'includePpll': options.includePpll,
      'featureCodes': acceptedFeatureCodes.toList()..sort(),
      'maxAlternateNames': options.maxAlternateNames,
    },
    'summary': <String, dynamic>{
      'placeCount': places.length,
      'featureCounts': _orderedFeatureCounts(featureCounts),
    },
    'places': places,
  };

  final outputFile = File(options.outputPath);
  outputFile.parent.createSync(recursive: true);
  final encoder = const JsonEncoder.withIndent('  ');
  await outputFile.writeAsString('${encoder.convert(output)}\n');

  stdout.writeln(
    'Imported ${places.length} GeoNames places for $countryCode to '
    '${outputFile.path}',
  );
  stdout.writeln(
    'Feature counts: ${jsonEncode(_orderedFeatureCounts(featureCounts))}',
  );
}

class ImportOptions {
  const ImportOptions({
    required this.countryCode,
    required this.outputPath,
    required this.downloadDir,
    required this.minPopulation,
    required this.includePpll,
    required this.skipDownload,
    required this.maxAlternateNames,
    required this.showHelp,
  });

  final String countryCode;
  final String outputPath;
  final String downloadDir;
  final int minPopulation;
  final bool includePpll;
  final bool skipDownload;
  final int maxAlternateNames;
  final bool showHelp;

  static const String usage = '''
Usage: dart run tool/import_geonames.dart [options]

Options:
  --country=NP                 ISO country code to import. Defaults to NP.
  --output=PATH                Output JSON path. Defaults to server/geonames_places_<country>.json
  --download-dir=PATH          Cache directory for downloaded GeoNames files.
                               Defaults to .dart_tool/geonames
  --min-population=NUMBER      Minimum population for populated places (PPL/PPLA/PPLC...).
                               Administrative rows are always kept. Defaults to 0.
  --include-ppll               Include abandoned populated places (PPLL).
  --skip-download              Reuse existing downloaded files in --download-dir.
  --max-alternate-names=NUM    Limit alternate names per place. Defaults to 12.
  --help                       Show this help text.
''';

  static ImportOptions parse(List<String> args) {
    var countryCode = 'NP';
    var outputPath = '';
    var downloadDir = '.dart_tool/geonames';
    var minPopulation = 0;
    var includePpll = false;
    var skipDownload = false;
    var maxAlternateNames = 12;
    var showHelp = false;

    for (final arg in args) {
      if (arg == '--help' || arg == '-h') {
        showHelp = true;
        continue;
      }
      if (arg == '--include-ppll') {
        includePpll = true;
        continue;
      }
      if (arg == '--skip-download') {
        skipDownload = true;
        continue;
      }
      if (arg.startsWith('--country=')) {
        countryCode = arg.substring('--country='.length).trim();
        continue;
      }
      if (arg.startsWith('--output=')) {
        outputPath = arg.substring('--output='.length).trim();
        continue;
      }
      if (arg.startsWith('--download-dir=')) {
        downloadDir = arg.substring('--download-dir='.length).trim();
        continue;
      }
      if (arg.startsWith('--min-population=')) {
        minPopulation = int.parse(
          arg.substring('--min-population='.length).trim(),
        );
        continue;
      }
      if (arg.startsWith('--max-alternate-names=')) {
        maxAlternateNames = int.parse(
          arg.substring('--max-alternate-names='.length).trim(),
        );
        continue;
      }
      throw FormatException('Unsupported argument: $arg');
    }

    if (countryCode.length != 2) {
      throw FormatException(
        'Expected a 2-letter ISO country code, got "$countryCode".',
      );
    }
    if (minPopulation < 0) {
      throw FormatException('--min-population must be >= 0.');
    }
    if (maxAlternateNames < 0) {
      throw FormatException('--max-alternate-names must be >= 0.');
    }

    final normalizedCountry = countryCode.toUpperCase();
    final normalizedOutput = outputPath.isEmpty
        ? 'server/geonames_places_${normalizedCountry.toLowerCase()}.json'
        : outputPath;

    return ImportOptions(
      countryCode: normalizedCountry,
      outputPath: normalizedOutput,
      downloadDir: downloadDir,
      minPopulation: minPopulation,
      includePpll: includePpll,
      skipDownload: skipDownload,
      maxAlternateNames: maxAlternateNames,
      showHelp: showHelp,
    );
  }
}

Future<void> _downloadFile(String url, File destination) async {
  stdout.writeln('Downloading $url');

  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Failed to download $url (HTTP ${response.statusCode})',
        uri: Uri.parse(url),
      );
    }

    destination.parent.createSync(recursive: true);
    final sink = destination.openWrite();
    await response.pipe(sink);
    await sink.flush();
    await sink.close();
  } finally {
    client.close(force: true);
  }
}

Future<String> _readZipEntry(String zipPath, String entryName) async {
  late final ProcessResult result;
  try {
    result = await Process.run('unzip', <String>['-p', zipPath, entryName]);
  } on ProcessException catch (error) {
    throw ProcessException(
      error.executable,
      error.arguments,
      'GeoNames import requires the "unzip" command to be available on the '
      'system PATH. Original error: ${error.message}',
      error.errorCode,
    );
  }
  if (result.exitCode != 0) {
    final error = (result.stderr as String).trim();
    throw ProcessException(
      'unzip',
      <String>['-p', zipPath, entryName],
      error.isEmpty ? 'Failed to read $entryName from $zipPath' : error,
      result.exitCode,
    );
  }
  return result.stdout as String;
}

Map<String, String> _loadAdminNames(
  List<String> lines, {
  required String countryCode,
  required int expectedParts,
}) {
  final names = <String, String>{};

  for (final line in lines) {
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    final parts = line.split('\t');
    if (parts.length < expectedParts) {
      continue;
    }
    final code = parts[0].trim();
    if (!code.startsWith('$countryCode.')) {
      continue;
    }
    names[code] = parts[1].trim();
  }

  return names;
}

List<String> _parseAlternateNames({
  required String raw,
  required String primaryName,
  required String asciiName,
  required int maxCount,
}) {
  if (raw.trim().isEmpty || maxCount == 0) {
    return const <String>[];
  }

  final results = <String>[];
  final seen = <String>{
    primaryName.trim().toLowerCase(),
    asciiName.trim().toLowerCase(),
  };

  for (final candidate in raw.split(',')) {
    final trimmed = candidate.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final key = trimmed.toLowerCase();
    if (seen.contains(key)) {
      continue;
    }
    seen.add(key);
    results.add(trimmed);
    if (results.length >= maxCount) {
      break;
    }
  }

  return results;
}

bool _isPopulationFiltered(
  String featureCode,
  int population,
  int minPopulation,
) {
  if (minPopulation == 0) {
    return false;
  }
  if (featureCode.startsWith('ADM')) {
    return false;
  }
  return population < minPopulation;
}

int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

int? _parseNullableInt(String value) => int.tryParse(value.trim());

double _parseDouble(String value) => double.tryParse(value.trim()) ?? 0;

Map<String, int> _orderedFeatureCounts(Map<String, int> counts) {
  final keys = counts.keys.toList()
    ..sort((left, right) => _featureRank(left).compareTo(_featureRank(right)));
  return <String, int>{for (final key in keys) key: counts[key]!};
}

int _comparePlaces(Map<String, dynamic> left, Map<String, dynamic> right) {
  final featureRankCompare = _featureRank(
    left['featureCode'] as String,
  ).compareTo(_featureRank(right['featureCode'] as String));
  if (featureRankCompare != 0) {
    return featureRankCompare;
  }

  final admin1Compare = ((left['admin1Name'] ?? '') as String).compareTo(
    (right['admin1Name'] ?? '') as String,
  );
  if (admin1Compare != 0) {
    return admin1Compare;
  }

  final admin2Compare = ((left['admin2Name'] ?? '') as String).compareTo(
    (right['admin2Name'] ?? '') as String,
  );
  if (admin2Compare != 0) {
    return admin2Compare;
  }

  final populationCompare = (right['population'] as int).compareTo(
    left['population'] as int,
  );
  if (populationCompare != 0) {
    return populationCompare;
  }

  return (left['name'] as String).compareTo(right['name'] as String);
}

int _featureRank(String featureCode) {
  switch (featureCode) {
    case 'ADM1':
      return 0;
    case 'ADM2':
      return 1;
    case 'ADM3':
      return 2;
    case 'ADM4':
      return 3;
    case 'PPLC':
      return 4;
    case 'PPLA':
      return 5;
    case 'PPLA2':
      return 6;
    case 'PPLA3':
      return 7;
    case 'PPLA4':
      return 8;
    case 'PPL':
      return 9;
    case 'PPLL':
      return 10;
    default:
      return 99;
  }
}
