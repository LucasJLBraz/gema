import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TacoReferenceEntry {
  const TacoReferenceEntry({
    required this.name,
    required this.grupoAlimentar,
    required this.kcal100g,
    required this.protein100g,
    required this.carb100g,
    required this.fat100g,
  });

  final String name;
  final String grupoAlimentar;
  final double kcal100g;
  final double protein100g;
  final double carb100g;
  final double fat100g;

  factory TacoReferenceEntry.fromJson(Map<String, dynamic> j) =>
      TacoReferenceEntry(
        name: j['name'] as String,
        grupoAlimentar: j['grupo_alimentar'] as String,
        kcal100g: (j['kcal_100g'] as num).toDouble(),
        protein100g: (j['protein_100g'] as num).toDouble(),
        carb100g: (j['carb_100g'] as num).toDouble(),
        fat100g: (j['fat_100g'] as num).toDouble(),
      );
}

List<TacoReferenceEntry> parseTacoReferenceJson(String raw) {
  final decoded = jsonDecode(raw) as List;
  return decoded
      .map((e) => TacoReferenceEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

String formatReferenceTableBlock(List<TacoReferenceEntry> entries) {
  final buffer = StringBuffer();
  for (final e in entries) {
    buffer.writeln(
      '${e.name}|${e.kcal100g.round()}|${e.protein100g.toStringAsFixed(1)}|'
      '${e.carb100g.toStringAsFixed(1)}|${e.fat100g.toStringAsFixed(1)}',
    );
  }
  return buffer.toString();
}

Future<List<TacoReferenceEntry>> loadTacoReference() async {
  final raw = await rootBundle.loadString('assets/data/taco_reference.json');
  return parseTacoReferenceJson(raw);
}
