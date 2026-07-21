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

  group('systemPromptNoCot', () {
    test('has no numbered chain-of-thought steps', () {
      expect(systemPromptNoCot, isNot(contains('Raciocine internamente')));
      expect(systemPromptNoCot, isNot(contains('1. Liste os componentes')));
    });

    test('keeps every non-reasoning rule from systemPromptBaseline', () {
      for (final rule in [
        'INCERTEZA',
        'TAGS',
        'FILTRO DE PERGUNTA',
        'EMOJI',
        'NOME',
        'IDIOMA',
        'SAÍDA',
      ]) {
        expect(systemPromptNoCot, contains(rule));
      }
    });
  });

  group('systemPromptWithScale', () {
    test('instructs the model to detect and use a visible scale reading', () {
      expect(systemPromptWithScale, contains('balança'));
      expect(systemPromptWithScale, contains('scale_reading_used'));
      expect(systemPromptWithScale, contains('scale_reading_g'));
    });
  });

  group('responseSchemaWithScale', () {
    test('adds scale_reading_used and scale_reading_g as top-level fields', () {
      final props =
          responseSchemaWithScale['properties'] as Map<String, dynamic>;
      expect(props.containsKey('scale_reading_used'), isTrue);
      expect(props.containsKey('scale_reading_g'), isTrue);
      expect(
        (props['scale_reading_used'] as Map<String, dynamic>)['type'],
        'boolean',
      );
      expect(
        (props['scale_reading_g'] as Map<String, dynamic>)['nullable'],
        isTrue,
      );
    });

    test('responseSchemaBaseline has no scale_reading fields', () {
      final props = responseSchemaBaseline['properties'] as Map<String, dynamic>;
      expect(props.containsKey('scale_reading_used'), isFalse);
      expect(props.containsKey('scale_reading_g'), isFalse);
    });
  });

  group('systemPromptCombined', () {
    test('has no numbered CoT steps but keeps grounding and scale instructions', () {
      final prompt = systemPromptCombined('Arroz|124|2.6|25.8|1.0\n');
      expect(prompt, isNot(contains('1. Liste os componentes')));
      expect(prompt, contains('TABELA DE REFERÊNCIA'));
      expect(prompt, contains('Arroz|124|2.6|25.8|1.0'));
      expect(prompt, contains('matched_reference_food'));
      expect(prompt, contains('balança'));
      expect(prompt, contains('scale_reading_used'));
    });
  });

  group('responseSchemaCombined', () {
    test('has both matched_reference_food and scale_reading fields', () {
      final props = responseSchemaCombined['properties'] as Map<String, dynamic>;
      expect(props.containsKey('scale_reading_used'), isTrue);
      expect(props.containsKey('scale_reading_g'), isTrue);
      final componentProps =
          ((responseSchemaCombined['properties']
                      as Map<String, dynamic>)['components']
                  as Map<String, dynamic>)['items']
              as Map<String, dynamic>;
      expect(
        (componentProps['properties'] as Map<String, dynamic>)
            .containsKey('matched_reference_food'),
        isTrue,
      );
    });
  });

  group('systemPromptNoCotWithScale', () {
    test('has no numbered CoT steps and no TACO reference instruction', () {
      expect(systemPromptNoCotWithScale, isNot(contains('1. Liste os componentes')));
      expect(systemPromptNoCotWithScale, isNot(contains('TABELA DE REFERÊNCIA')));
      expect(systemPromptNoCotWithScale, isNot(contains('matched_reference_food')));
      expect(systemPromptNoCotWithScale, contains('balança'));
      expect(systemPromptNoCotWithScale, contains('scale_reading_used'));
    });
  });

  group('systemPromptNoCotWithScaleReasoning', () {
    test('has no numbered CoT steps and no TACO reference instruction', () {
      expect(
        systemPromptNoCotWithScaleReasoning,
        isNot(contains('1. Liste os componentes')),
      );
      expect(
        systemPromptNoCotWithScaleReasoning,
        isNot(contains('TABELA DE REFERÊNCIA')),
      );
      expect(
        systemPromptNoCotWithScaleReasoning,
        isNot(contains('matched_reference_food')),
      );
      expect(systemPromptNoCotWithScaleReasoning, contains('balança'));
      expect(
        systemPromptNoCotWithScaleReasoning,
        contains('scale_reading_used'),
      );
    });

    test('instructs the model to externalize reasoning before numeric fields', () {
      expect(
        systemPromptNoCotWithScaleReasoning,
        contains('raciocinio_volumetrico'),
      );
    });

    test('tightens the scale-confirmed uncertainty band to its own tier', () {
      expect(
        systemPromptNoCotWithScaleReasoning,
        contains('ponto×0.95, max = ponto×1.05'),
      );
    });
  });

  group('responseSchemaWithScaleReasoning', () {
    test('adds raciocinio_volumetrico as a top-level string field', () {
      final props =
          responseSchemaWithScaleReasoning['properties']
              as Map<String, dynamic>;
      expect(props.containsKey('raciocinio_volumetrico'), isTrue);
      expect(
        (props['raciocinio_volumetrico'] as Map<String, dynamic>)['type'],
        'string',
      );
    });

    test('raciocinio_volumetrico is the FIRST declared property', () {
      final props =
          responseSchemaWithScaleReasoning['properties']
              as Map<String, dynamic>;
      expect(props.keys.first, 'raciocinio_volumetrico');
    });

    test('otherwise matches responseSchemaWithScale field set', () {
      final reasoningProps =
          responseSchemaWithScaleReasoning['properties']
              as Map<String, dynamic>;
      final scaleProps =
          responseSchemaWithScale['properties'] as Map<String, dynamic>;
      final reasoningKeysMinusNew = reasoningProps.keys
          .where((k) => k != 'raciocinio_volumetrico')
          .toSet();
      expect(reasoningKeysMinusNew, scaleProps.keys.toSet());
    });
  });

  group('production cutover', () {
    test(
      'estimateMeal is wired to the benchmark-validated no_cot_with_scale_reasoning arm',
      () {
        expect(productionModel, 'gemini-3.1-flash-lite');
        expect(productionSystemPrompt, systemPromptNoCotWithScaleReasoning);
        expect(productionResponseSchema, responseSchemaWithScaleReasoning);
      },
    );
  });
}
