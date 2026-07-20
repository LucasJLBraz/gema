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

  final csv = StringBuffer(
    'sample_id,dataset,image_path,weight_g,kcal,protein_g,carb_g,fat_g\n',
  );
  for (final row in sample) {
    final dishId = row['dish_id']!;
    final imagePath = '${imagesDir.path}/$dishId.png';
    if (!File(imagePath).existsSync()) continue;
    csv.writeln(
      'n5k_$dishId,nutrition5k,$imagePath,'
      '${row['total_mass']},${row['total_calories']},'
      '${row['total_protein']},${row['total_carb']},${row['total_fat']}',
    );
  }

  File('benchmark_data/ground_truth.csv').writeAsStringSync(csv.toString());
  stderr.writeln(
    'Wrote ${sample.length} candidate rows (some may have been skipped on download failure).',
  );
}
