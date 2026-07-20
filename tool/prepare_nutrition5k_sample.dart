import 'dart:io';

import 'package:http/http.dart' as http;

const _sampleSize = 60;
const _imageBaseUrl =
    'https://storage.googleapis.com/nutrition5k_dataset/nutrition5k_dataset/imagery/realsense_overhead';

List<String> _parseCsvLine(String line) => line.split(',');

void main() async {
  final lines = File(
    'benchmark_data/nutrition5k/dish_metadata_cafe1.csv',
  ).readAsLinesSync();

  final rows = <Map<String, String>>[];
  for (final line in lines) {
    final cols = _parseCsvLine(line);
    if (cols.length < 6) continue;
    rows.add({
      'dish_id': cols[0],
      'total_calories': cols[1],
      'total_mass': cols[2],
      'total_fat': cols[3],
      'total_carb': cols[4],
      'total_protein': cols[5],
    });
  }

  final sample = rows.take(_sampleSize).toList();

  final imagesDir = Directory('benchmark_data/nutrition5k/images');
  imagesDir.createSync(recursive: true);

  for (final row in sample) {
    final dishId = row['dish_id']!;
    final response = await http.get(
      Uri.parse('$_imageBaseUrl/$dishId/rgb.png'),
    );
    if (response.statusCode != 200) {
      stderr.writeln('Skipping $dishId: HTTP ${response.statusCode}');
      continue;
    }
    File(
      '${imagesDir.path}/$dishId.png',
    ).writeAsBytesSync(response.bodyBytes);
  }

  final newRows = <String>[];
  for (final row in sample) {
    final dishId = row['dish_id']!;
    final imagePath = '${imagesDir.path}/$dishId.png';
    if (!File(imagePath).existsSync()) continue;
    newRows.add(
      'n5k_$dishId,nutrition5k,$imagePath,'
      '${row['total_mass']},${row['total_calories']},'
      '${row['total_protein']},${row['total_carb']},${row['total_fat']}',
    );
  }

  // Re-runnable in any order relative to prepare_snapme_sample.dart: drop
  // any previously-written n5k_ rows before appending the fresh ones, and
  // preserve rows from other datasets (e.g. snapme_*) instead of
  // unconditionally overwriting the whole file — an earlier version of this
  // script did a plain writeAsStringSync() here, which would silently
  // destroy SNAPMe's contribution to ground_truth.csv if this script were
  // (re-)run after prepare_snapme_sample.dart.
  const header = 'sample_id,dataset,image_path,weight_g,kcal,protein_g,carb_g,fat_g';
  final groundTruthFile = File('benchmark_data/ground_truth.csv');
  final keptLines = groundTruthFile.existsSync()
      ? groundTruthFile
          .readAsLinesSync()
          .where((l) => l.isNotEmpty && l != header && !l.startsWith('n5k_'))
          .toList()
      : <String>[];

  groundTruthFile.writeAsStringSync(
    '${[header, ...newRows, ...keptLines].join('\n')}\n',
  );
  stderr.writeln(
    'Wrote ${newRows.length} Nutrition5k rows (some of the $_sampleSize candidates may have been skipped on download failure).',
  );
}
