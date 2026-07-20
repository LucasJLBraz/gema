import 'package:flutter_test/flutter_test.dart';
import 'package:gema/core/gemini/gemini_service.dart';

void main() {
  group('systemPromptGrounded', () {
    test('embeds the reference table block and matching instruction', () {
      final prompt = systemPromptGrounded('Arroz|124|2.6|25.8|1.0\n');
      expect(prompt, contains('TABELA DE REFERÊNCIA'));
      expect(prompt, contains('Arroz|124|2.6|25.8|1.0'));
      expect(prompt, contains('matched_reference_food'));
    });
  });

  group('responseSchemaGrounded', () {
    test('adds matched_reference_food to component properties', () {
      final componentProps =
          ((responseSchemaGrounded['properties']
                      as Map<String, dynamic>)['components']
                  as Map<String, dynamic>)['items']
              as Map<String, dynamic>;
      final props = componentProps['properties'] as Map<String, dynamic>;
      expect(props.containsKey('matched_reference_food'), isTrue);
    });

    test('responseSchemaBaseline has no matched_reference_food', () {
      final componentProps =
          ((responseSchemaBaseline['properties']
                      as Map<String, dynamic>)['components']
                  as Map<String, dynamic>)['items']
              as Map<String, dynamic>;
      final props = componentProps['properties'] as Map<String, dynamic>;
      expect(props.containsKey('matched_reference_food'), isFalse);
    });
  });
}
