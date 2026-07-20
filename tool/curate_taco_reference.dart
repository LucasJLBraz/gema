import 'dart:convert';
import 'dart:io';

// Column names as they actually appear in brolesi/taco's processed CSV
// (verified by downloading and inspecting the real header — differs from
// the accented TACO 4th-edition dictionary names originally assumed).
const _colName = 'descricao';
const _colKcal = 'energia_kcal';
const _colProtein = 'proteina_g';
const _colCarb = 'carboidrato_g';
const _colFat = 'lipideos_g';
const _colCategoria = 'categoria';

double? _parseNum(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == 'NA' || trimmed == '*') return null;
  if (trimmed == 'Tr') return 0.0;
  return double.tryParse(trimmed.replaceAll(',', '.'));
}

// The CSV ships its own `categoria` column (verified by inspection: 15
// distinct values) — map those directly to the app's existing
// grupo_alimentar enum (see lib/core/gemini/gemini_service.dart
// _systemPrompt) instead of guessing from food names.
const _categoryMap = <String, String>{
  'Alimentos preparados': 'ultraprocessado',
  'Bebidas (alcoólicas e não alcoólicas)': 'bebida_calorica',
  'Carnes e derivados': 'proteina_animal',
  'Cereais e derivados': 'graos_cereais',
  'Frutas e derivados': 'fruta',
  'Gorduras e óleos': 'gordura_oleo',
  'Leguminosas e derivados': 'leguminosa',
  'Leite e derivados': 'laticinio',
  'Miscelâneas': 'outro',
  'Nozes e sementes': 'proteina_vegetal',
  'Outros alimentos industrializados': 'ultraprocessado',
  'Ovos e derivados': 'proteina_animal',
  'Pescados e frutos do mar': 'proteina_animal',
  'Produtos açucarados': 'doce_acucar',
  'Verduras, hortaliças e derivados': 'vegetal',
};

String _classify(String categoria) => _categoryMap[categoria] ?? 'outro';

List<String> _parseCsvLine(String line) {
  // brolesi/taco's processed CSV is comma-separated with quoted fields
  // containing commas (e.g. "Arroz, integral, cozido").
  final result = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;
  for (final char in line.split('')) {
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  result.add(buffer.toString());
  return result;
}

void main() {
  final lines = File(
    '/tmp/taco_source/taco_composicao.csv',
  ).readAsLinesSync();
  final header = _parseCsvLine(lines.first);

  for (final required in [
    _colName,
    _colKcal,
    _colProtein,
    _colCarb,
    _colFat,
    _colCategoria,
  ]) {
    if (!header.contains(required)) {
      throw StateError(
        'Expected column "$required" not found. Actual header: $header',
      );
    }
  }

  final idxName = header.indexOf(_colName);
  final idxKcal = header.indexOf(_colKcal);
  final idxProtein = header.indexOf(_colProtein);
  final idxCarb = header.indexOf(_colCarb);
  final idxFat = header.indexOf(_colFat);
  final idxCategoria = header.indexOf(_colCategoria);

  final entries = <Map<String, dynamic>>[];
  var skipped = 0;
  final unmappedCategories = <String>{};

  for (final line in lines.skip(1)) {
    if (line.trim().isEmpty) continue;
    final cols = _parseCsvLine(line);
    final name = cols[idxName].trim();
    final kcal = _parseNum(cols[idxKcal]);
    final protein = _parseNum(cols[idxProtein]);
    final carb = _parseNum(cols[idxCarb]);
    final fat = _parseNum(cols[idxFat]);
    final categoria = cols[idxCategoria].trim();

    if (name.isEmpty ||
        kcal == null ||
        protein == null ||
        carb == null ||
        fat == null) {
      skipped++;
      continue;
    }

    if (!_categoryMap.containsKey(categoria)) {
      unmappedCategories.add(categoria);
    }

    entries.add({
      'name': name,
      'grupo_alimentar': _classify(categoria),
      'kcal_100g': kcal,
      'protein_100g': protein,
      'carb_100g': carb,
      'fat_100g': fat,
    });
  }

  final outFile = File('assets/data/taco_reference.json');
  outFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(entries),
  );

  stderr.writeln(
    'Wrote ${entries.length} entries, skipped $skipped incomplete rows.',
  );
  if (unmappedCategories.isNotEmpty) {
    stderr.writeln(
      'WARNING: unmapped categoria values (defaulted to "outro"): $unmappedCategories',
    );
  }
  stderr.writeln('Wrote ${outFile.path}');
}
