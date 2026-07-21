import 'package:flutter_test/flutter_test.dart';
import 'package:gema/core/utils/text_normalization.dart';

void main() {
  group('normalizeText', () {
    test('lowercases and strips accents', () {
      expect(normalizeText('Café com Leite'), 'cafe com leite');
      expect(normalizeText('PÃO FRANCÊS'), 'pao frances');
      expect(normalizeText('  Açaí  '), 'acai');
    });
  });

  group('jaccardSimilarity', () {
    test('identical strings score 1.0', () {
      expect(jaccardSimilarity('ovo mexido', 'ovo mexido'), 1.0);
    });

    test('partial token overlap scores between 0 and 1', () {
      final score = jaccardSimilarity(
        'ovo mexido com manteiga',
        'ovo mexido com queijo',
      );
      // tokens: {ovo,mexido,com,manteiga} vs {ovo,mexido,com,queijo}
      // intersection=3, union=5 -> 0.6
      expect(score, closeTo(0.6, 0.0001));
    });

    test('completely different strings score 0.0', () {
      expect(jaccardSimilarity('arroz com feijao', 'salada de frutas'), 0.0);
    });

    test('empty strings score 0.0', () {
      expect(jaccardSimilarity('', 'algo'), 0.0);
      expect(jaccardSimilarity('', ''), 0.0);
    });
  });

  group('mostRecentPerSimilarityGroup', () {
    test('keeps only the most recent item per similarity group', () {
      final items = [
        ('café com leite', DateTime(2026, 7, 10, 8, 0)),
        ('café com leite e pão', DateTime(2026, 7, 18, 8, 5)),
        ('salada de frutas', DateTime(2026, 7, 15, 12, 0)),
      ];

      final result = mostRecentPerSimilarityGroup<(String, DateTime)>(
        items: items,
        textOf: (i) => i.$1,
        timeOf: (i) => i.$2,
        threshold: 0.6,
      );

      expect(result.length, 2);
      expect(result[0].$1, 'café com leite e pão');
      expect(result[1].$1, 'salada de frutas');
    });

    test('returns items sorted by recency, most recent first', () {
      final items = [
        ('a', DateTime(2026, 1, 1)),
        ('b', DateTime(2026, 7, 1)),
        ('c', DateTime(2026, 3, 1)),
      ];

      final result = mostRecentPerSimilarityGroup<(String, DateTime)>(
        items: items,
        textOf: (i) => i.$1,
        timeOf: (i) => i.$2,
      );

      expect(result.map((i) => i.$1).toList(), ['b', 'c', 'a']);
    });
  });
}
