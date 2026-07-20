import 'dart:io';

// SNAPMe's master linkfile is a per-food-line-item table (multiple rows can
// share the same `filename` when a photo has more than one food item) —
// verified by extracting and inspecting the real file after manual download
// (Ag Data Commons blocks automated fetches, so this dataset is downloaded
// by hand into benchmark_data/snapme/ and the tarball extracted locally).
// Column indices below are verified against the real header row:
// subject_id,snapme_study_day,filename,packaged_food,FoodCode,
// Food_Description,FoodAmt,Location,FoodNum1,FoodType,Occ_No,Occ_Name,
// CodeNum,ModCode,HowMany,SubCode,PortionCode,FoodAmt.1,KCAL,PROT,TFAT,CARB,...
const _idxFilename = 2;
const _idxPackagedFood = 3;
const _idxFoodAmt = 6;
const _idxKcal = 18;
const _idxProt = 19;
const _idxTfat = 20;
const _idxCarb = 21;

const _sampleSize = 60;
const _linkfilePath = 'benchmark_data/snapme/master_SNAPME_linkfile.csv';
// before_photos/ entries are relative symlinks into snapme_nut_db/ (the
// archive avoids duplicating each photo across its two directory layouts) —
// verified by extraction: selectively extracting only before_photos members
// with --strip-components breaks the symlink targets, so the full tarball
// must be extracted once, preserving the original tree, before these paths
// resolve to real files.
const _beforePhotosDir =
    'benchmark_data/snapme/snapme_db_09Dec2022/snapme_cs_db/before_photos';

/// Minimal CSV parser handling quoted fields (the linkfile quotes every
/// field, including plain numbers).
List<String> _parseCsvLine(String line) {
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

class _MealTotals {
  double weightG = 0;
  double kcal = 0;
  double proteinG = 0;
  double carbG = 0;
  double fatG = 0;
}

void main() async {
  final lines = File(_linkfilePath).readAsLinesSync();

  // Group by photo filename, summing every food line item that shares it —
  // a SNAPMe "before" photo can show a multi-item meal.
  final totals = <String, _MealTotals>{};
  for (final line in lines.skip(1)) {
    if (line.trim().isEmpty) continue;
    final cols = _parseCsvLine(line);
    if (cols[_idxPackagedFood] != '0') continue; // non-packaged only ("before" photos)

    final filename = cols[_idxFilename];
    final t = totals.putIfAbsent(filename, () => _MealTotals());
    t.weightG += double.parse(cols[_idxFoodAmt]);
    t.kcal += double.parse(cols[_idxKcal]);
    t.proteinG += double.parse(cols[_idxProt]);
    t.fatG += double.parse(cols[_idxTfat]);
    t.carbG += double.parse(cols[_idxCarb]);
  }

  final sampleFilenames = totals.keys.take(_sampleSize).toList();

  final imagesDir = Directory('benchmark_data/snapme/images');
  imagesDir.createSync(recursive: true);

  // Copy into a flat images/ directory, matching the layout the other prep
  // script produces. before_photos/ entries are symlinks — File.copySync
  // was found (by testing) to preserve the symlink itself rather than the
  // resolved content, which breaks once relocated, so resolve first and
  // copy real bytes from the resolved path.
  for (final filename in sampleFilenames) {
    final source = File('$_beforePhotosDir/$filename');
    if (!source.existsSync()) continue;
    final resolvedPath = source.resolveSymbolicLinksSync();
    File(resolvedPath).copySync('${imagesDir.path}/$filename');
  }

  final existingCsv = File('benchmark_data/ground_truth.csv');
  final sink = existingCsv.openWrite(mode: FileMode.append);
  var written = 0;

  for (final filename in sampleFilenames) {
    final imagePath = '${imagesDir.path}/$filename';
    if (!File(imagePath).existsSync()) {
      stderr.writeln('Skipping $filename: not found in before_photos/');
      continue;
    }
    final t = totals[filename]!;
    final sampleId = 'snapme_${filename.replaceAll('.jpeg', '')}';
    sink.writeln(
      '$sampleId,snapme,$imagePath,'
      '${t.weightG},${t.kcal},${t.proteinG},${t.carbG},${t.fatG}',
    );
    written++;
  }

  await sink.close();
  stderr.writeln('Wrote $written SNAPMe rows to benchmark_data/ground_truth.csv');
}
