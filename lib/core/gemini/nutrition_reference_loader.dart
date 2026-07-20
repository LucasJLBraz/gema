import 'package:flutter/services.dart' show rootBundle;

import 'nutrition_reference.dart';

// Split out from nutrition_reference.dart so that file stays pure Dart
// (no Flutter engine dependency) — rootBundle transitively requires
// dart:ui, which plain `dart run` scripts (see tool/benchmark_kcal.dart)
// cannot provide. Those scripts read assets/data/taco_reference.json via
// dart:io instead and call parseTacoReferenceJson directly.

Future<List<TacoReferenceEntry>> loadTacoReference() async {
  final raw = await rootBundle.loadString('assets/data/taco_reference.json');
  return parseTacoReferenceJson(raw);
}
