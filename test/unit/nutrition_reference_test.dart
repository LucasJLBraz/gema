// test/unit/nutrition_reference_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gema/core/gemini/nutrition_reference.dart';

void main() {
  group('parseTacoReferenceJson', () {
    test('parses a well-formed entry list', () {
      const raw = '''
      [
        {"name": "Arroz, integral, cozido", "grupo_alimentar": "graos_cereais",
         "kcal_100g": 124, "protein_100g": 2.6, "carb_100g": 25.8, "fat_100g": 1.0}
      ]
      ''';
      final entries = parseTacoReferenceJson(raw);
      expect(entries, hasLength(1));
      expect(entries.first.name, 'Arroz, integral, cozido');
      expect(entries.first.kcal100g, 124.0);
    });
  });

  group('formatReferenceTableBlock', () {
    test('formats entries as pipe-delimited lines', () {
      final entries = [
        const TacoReferenceEntry(
          name: 'Feijão, carioca, cozido',
          grupoAlimentar: 'leguminosa',
          kcal100g: 76,
          protein100g: 4.8,
          carb100g: 13.6,
          fat100g: 0.5,
        ),
      ];
      final block = formatReferenceTableBlock(entries);
      expect(block, 'Feijão, carioca, cozido|76|4.8|13.6|0.5\n');
    });
  });
}
