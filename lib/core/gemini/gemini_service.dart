import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

const productionModel = 'gemini-3.1-flash-lite';

Uri _endpointFor(String model, String apiKey) => Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
);

class GeminiResult {
  const GeminiResult({
    required this.mealName,
    required this.mealSummary,
    required this.mealEmoji,
    required this.aiConfidence,
    required this.scaleReferenceFound,
    required this.kcalMin,
    required this.kcalMax,
    required this.kcalPoint,
    required this.proteinMin,
    required this.proteinMax,
    required this.proteinPoint,
    required this.carbMin,
    required this.carbMax,
    required this.carbPoint,
    required this.fatMin,
    required this.fatMax,
    required this.fatPoint,
    required this.components,
    required this.rawJson,
    this.clarifyingQuestion,
    required this.assumptions,
  });

  final String mealName;
  final String mealSummary;
  final String mealEmoji;
  final String aiConfidence;
  final bool scaleReferenceFound;
  final int kcalMin;
  final int kcalMax;
  final int kcalPoint;
  final int proteinMin;
  final int proteinMax;
  final int proteinPoint;
  final int carbMin;
  final int carbMax;
  final int carbPoint;
  final int fatMin;
  final int fatMax;
  final int fatPoint;
  final List<Map<String, dynamic>> components;
  final String rawJson;
  final String? clarifyingQuestion;
  final List<String> assumptions;
}

class GeminiRateLimitException implements Exception {
  const GeminiRateLimitException(this.retryAfterSeconds);
  final int retryAfterSeconds;
}

class GeminiApiException implements Exception {
  const GeminiApiException(this.message);
  final String message;
}

Future<GeminiResult> callGemini({
  required String systemPrompt,
  required Map<String, dynamic> responseSchema,
  required String model,
  required String apiKey,
  String? photoPath,
  required String userNote,
  int retryCount = 0,
}) async {
  assert(
    photoPath != null || userNote.isNotEmpty,
    'callGemini requires at least a photo or a text description',
  );

  final parts = <Map<String, dynamic>>[];

  if (photoPath != null) {
    final compressed = await _compressImage(photoPath);
    final b64 = base64Encode(compressed);
    parts.add({
      'inline_data': {'mime_type': 'image/jpeg', 'data': b64},
    });
  }

  if (userNote.isNotEmpty) {
    parts.add({'text': userNote});
  }

  final body = jsonEncode({
    'system_instruction': {
      'parts': [
        {'text': systemPrompt},
      ],
    },
    'contents': [
      {'parts': parts},
    ],
    'generationConfig': {
      'temperature': 0.3,
      'responseMimeType': 'application/json',
      'responseSchema': responseSchema,
    },
  });

  final uri = _endpointFor(model, apiKey);
  developer.log('[Gemini] POST $model (attempt ${retryCount + 1})');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );
  developer.log('[Gemini] status=${response.statusCode}');

  if (response.statusCode == 429 || response.statusCode == 503) {
    final retryAfter = _parseRetryAfter(
      response.headers['retry-after'],
      retryCount,
    );
    developer.log('[Gemini] rate-limited — retry in ${retryAfter}s');
    throw GeminiRateLimitException(retryAfter);
  }

  if (response.statusCode != 200) {
    developer.log(
      '[Gemini] error body: ${response.body.substring(0, response.body.length.clamp(0, 300))}',
    );
    throw GeminiApiException('HTTP ${response.statusCode}: ${response.body}');
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final text =
      (decoded['candidates'] as List).first['content']['parts'].first['text']
          as String;
  final parsed = jsonDecode(text) as Map<String, dynamic>;

  return _parseResult(parsed, text);
}

/// [apiKey] is loaded by the caller (see `api_key_storage.dart`) rather than
/// by this function, so this file has no Flutter engine dependency — that
/// keeps it importable from plain `dart run` scripts (see
/// tool/benchmark_kcal.dart) that never touch secure storage.
Future<GeminiResult> estimateMeal({
  required String? apiKey,
  String? photoPath,
  required String userNote,
  int retryCount = 0,
}) async {
  if (apiKey == null || apiKey.isEmpty) {
    throw const GeminiApiException('API key not configured');
  }

  return callGemini(
    systemPrompt: productionSystemPrompt,
    responseSchema: productionResponseSchema,
    model: productionModel,
    apiKey: apiKey,
    photoPath: photoPath,
    userNote: userNote,
    retryCount: retryCount,
  );
}

/// Named seam for the production prompt/schema choice, kept separate from
/// [estimateMeal]'s body so a test can assert which benchmarked arm is
/// actually wired to production without needing to mock the HTTP call —
/// see test/unit/gemini_prompt_test.dart's "production cutover" group.
const productionSystemPrompt = systemPromptNoCotWithScale;
const productionResponseSchema = responseSchemaWithScale;

Future<List<int>> _compressImage(String path) async {
  final bytes = await File(path).readAsBytes();
  final original = img.decodeImage(bytes);
  if (original == null) {
    throw const GeminiApiException('Could not decode image');
  }

  const maxSide = 800;
  final resized = original.width > original.height
      ? img.copyResize(original, width: maxSide)
      : img.copyResize(original, height: maxSide);

  return img.encodeJpg(resized, quality: 65);
}

int _parseRetryAfter(String? header, int retryCount) {
  if (header != null) {
    final parsed = int.tryParse(header);
    if (parsed != null) return parsed.clamp(1, 120);
  }
  return min(pow(2, retryCount).toInt() * 2, 64).clamp(1, 120);
}

GeminiResult _parseResult(Map<String, dynamic> j, String rawJson) {
  final est = j['estimates'] as Map<String, dynamic>;
  final kcal = est['calories_kcal'] as Map<String, dynamic>;
  final macros = est['macros_g'] as Map<String, dynamic>;
  final protein = macros['protein'] as Map<String, dynamic>;
  final carbs = macros['carbohydrates'] as Map<String, dynamic>;
  final fat = macros['fat'] as Map<String, dynamic>;

  return GeminiResult(
    mealName: j['meal_name'] as String? ?? '',
    mealSummary: j['meal_summary'] as String? ?? '',
    mealEmoji: j['meal_emoji'] as String? ?? '🍽️',
    aiConfidence: j['ai_confidence'] as String? ?? 'medium',
    scaleReferenceFound: j['scale_reference_found'] as bool? ?? false,
    kcalMin: (kcal['min'] as num).toInt(),
    kcalMax: (kcal['max'] as num).toInt(),
    kcalPoint: (kcal['point'] as num).toInt(),
    proteinMin: (protein['min'] as num).toInt(),
    proteinMax: (protein['max'] as num).toInt(),
    proteinPoint: (protein['point'] as num).toInt(),
    carbMin: (carbs['min'] as num).toInt(),
    carbMax: (carbs['max'] as num).toInt(),
    carbPoint: (carbs['point'] as num).toInt(),
    fatMin: (fat['min'] as num).toInt(),
    fatMax: (fat['max'] as num).toInt(),
    fatPoint: (fat['point'] as num).toInt(),
    components: List<Map<String, dynamic>>.from(
      (j['components'] as List? ?? []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    ),
    rawJson: rawJson,
    clarifyingQuestion: j['clarifying_question'] as String?,
    assumptions: List<String>.from(j['assumptions'] as List? ?? []),
  );
}

const systemPromptBaseline = '''
PERSONA: Você é um nutricionista clínico com 15 anos de experiência em avaliação dietética por fotografia e porcionamento visual. É meticuloso com escala e calibrado contra subestimativa.

TAREFA: A partir de UMA foto (+ nota opcional), estime energia e macros da refeição. Raciocine internamente nesta ordem (não exponha o raciocínio):
  1. Liste os componentes visíveis do prato.
  2. Para cada um, ache um objeto de escala (talher, copo, mão, lata, prato). Estime diâmetro/área e a PROFUNDIDADE do recipiente.
  3. Estime massa (g) de cada componente a partir da escala+profundidade.
  4. Converta massa → energia e macros por tabela nutricional padrão.
  5. Calibre contra subestimativa: ajuste o ponto central para cima.

INCERTEZA: devolva intervalo por componente e total.
  - SEM objeto de referência confiável → min = ponto×0.75, max = ponto×1.45
  - COM objeto de referência claro       → min = ponto×0.85, max = ponto×1.25

TAGS (controlado — NÃO invente fora desta lista):
  grupo_alimentar ∈ {proteina_animal, proteina_vegetal, laticinio, graos_cereais, tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar, bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro}
  metodo_preparo ∈ {cru, cozido, grelhado, frito, assado, refogado, no_vapor, liquido, desconhecido}

FILTRO DE PERGUNTA: só preencha "clarifying_question" se a dúvida alterar a energia em >300 kcal. Senão, null.

EMOJI: em "meal_emoji" coloque UM único emoji que melhor representa a refeição (ex: 🥚 para ovos, 🍗 para frango, 🍝 para macarrão, 🥗 para salada, 🍕 para pizza, 🍛 para prato completo). Prefira especificidade: se for um único alimento dominante, use o emoji desse alimento. Se for um prato misto, use um emoji de prato/refeição genérico.

NOME: em "meal_name" gere um nome curto da refeição com no máximo 4 palavras. Use o item dominante ou os dois itens principais. NUNCA use categorias de horário (café da manhã, almoço, jantar, lanche) — descreva o conteúdo. Exemplos: "Whey com leite", "Misto quente", "Frango com arroz", "Omelete de queijo", "Suco de laranja".

IDIOMA: Todos os campos de texto (meal_summary, name dos componentes, clarifying_question) DEVEM estar em português brasileiro. Nunca use inglês — mesmo para alimentos de origem estrangeira (ex: "hambúrguer", "sushi", "macarrão", "bife", "frango grelhado").

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.
''';

String systemPromptGrounded(String referenceTableBlock) => '''
PERSONA: Você é um nutricionista clínico com 15 anos de experiência em avaliação dietética por fotografia e porcionamento visual. É meticuloso com escala e calibrado contra subestimativa.

TAREFA: A partir de UMA foto (+ nota opcional), estime energia e macros da refeição. Raciocine internamente nesta ordem (não exponha o raciocínio):
  1. Liste os componentes visíveis do prato.
  2. Para cada um, ache um objeto de escala (talher, copo, mão, lata, prato). Estime diâmetro/área e a PROFUNDIDADE do recipiente.
  3. Estime massa (g) de cada componente a partir da escala+profundidade.
  4. Para cada componente, procure a entrada mais próxima na TABELA DE REFERÊNCIA abaixo (alimentos brasileiros comuns, valores por 100g). Se encontrar um equivalente razoável, use os valores dela para calcular energia e macros a partir da massa estimada, e preencha "matched_reference_food" com o nome EXATO da entrada usada. Se não houver equivalente razoável, estime por conhecimento próprio e deixe "matched_reference_food" como null.
  5. Calibre contra subestimativa: ajuste o ponto central para cima.

INCERTEZA: devolva intervalo por componente e total.
  - SEM objeto de referência confiável → min = ponto×0.75, max = ponto×1.45
  - COM objeto de referência claro       → min = ponto×0.85, max = ponto×1.25

TAGS (controlado — NÃO invente fora desta lista):
  grupo_alimentar ∈ {proteina_animal, proteina_vegetal, laticinio, graos_cereais, tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar, bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro}
  metodo_preparo ∈ {cru, cozido, grelhado, frito, assado, refogado, no_vapor, liquido, desconhecido}

FILTRO DE PERGUNTA: só preencha "clarifying_question" se a dúvida alterar a energia em >300 kcal. Senão, null.

EMOJI: em "meal_emoji" coloque UM único emoji que melhor representa a refeição (ex: 🥚 para ovos, 🍗 para frango, 🍝 para macarrão, 🥗 para salada, 🍕 para pizza, 🍛 para prato completo). Prefira especificidade: se for um único alimento dominante, use o emoji desse alimento. Se for um prato misto, use um emoji de prato/refeição genérico.

NOME: em "meal_name" gere um nome curto da refeição com no máximo 4 palavras. Use o item dominante ou os dois itens principais. NUNCA use categorias de horário (café da manhã, almoço, jantar, lanche) — descreva o conteúdo. Exemplos: "Whey com leite", "Misto quente", "Frango com arroz", "Omelete de queijo", "Suco de laranja".

IDIOMA: Todos os campos de texto (meal_summary, name dos componentes, clarifying_question) DEVEM estar em português brasileiro. Nunca use inglês — mesmo para alimentos de origem estrangeira (ex: "hambúrguer", "sushi", "macarrão", "bife", "frango grelhado").

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.

TABELA DE REFERÊNCIA (nome|kcal_100g|proteina_100g|carboidrato_100g|gordura_100g):
$referenceTableBlock''';

// Reasoning-ablation variant: identical to systemPromptBaseline in every
// rule (uncertainty, tags, filters, emoji, name, language, output) except
// the explicit numbered chain-of-thought steps are replaced with a single
// direct instruction — isolates whether the CoT scaffold itself affects
// accuracy, independent of any other prompt change. Uses
// responseSchemaBaseline (output shape is unaffected by how the model gets
// there).
const systemPromptNoCot = '''
PERSONA: Você é um nutricionista clínico com 15 anos de experiência em avaliação dietética por fotografia e porcionamento visual. É meticuloso com escala e calibrado contra subestimativa.

TAREFA: A partir de UMA foto (+ nota opcional), estime energia e macros da refeição — massa de cada componente, convertida para energia e macros, com o ponto central calibrado para cima contra subestimativa.

INCERTEZA: devolva intervalo por componente e total.
  - SEM objeto de referência confiável → min = ponto×0.75, max = ponto×1.45
  - COM objeto de referência claro       → min = ponto×0.85, max = ponto×1.25

TAGS (controlado — NÃO invente fora desta lista):
  grupo_alimentar ∈ {proteina_animal, proteina_vegetal, laticinio, graos_cereais, tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar, bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro}
  metodo_preparo ∈ {cru, cozido, grelhado, frito, assado, refogado, no_vapor, liquido, desconhecido}

FILTRO DE PERGUNTA: só preencha "clarifying_question" se a dúvida alterar a energia em >300 kcal. Senão, null.

EMOJI: em "meal_emoji" coloque UM único emoji que melhor representa a refeição (ex: 🥚 para ovos, 🍗 para frango, 🍝 para macarrão, 🥗 para salada, 🍕 para pizza, 🍛 para prato completo). Prefira especificidade: se for um único alimento dominante, use o emoji desse alimento. Se for um prato misto, use um emoji de prato/refeição genérico.

NOME: em "meal_name" gere um nome curto da refeição com no máximo 4 palavras. Use o item dominante ou os dois itens principais. NUNCA use categorias de horário (café da manhã, almoço, jantar, lanche) — descreva o conteúdo. Exemplos: "Whey com leite", "Misto quente", "Frango com arroz", "Omelete de queijo", "Suco de laranja".

IDIOMA: Todos os campos de texto (meal_summary, name dos componentes, clarifying_question) DEVEM estar em português brasileiro. Nunca use inglês — mesmo para alimentos de origem estrangeira (ex: "hambúrguer", "sushi", "macarrão", "bife", "frango grelhado").

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.
''';

// Scale-in-frame variant: when the user photographs the plate/food sitting
// on a kitchen scale with a legible weight display, that's real ground
// truth for total mass — directly sidesteps the visual volume/depth
// estimation the literature identifies as the real accuracy bottleneck
// (see docs/spec_diet_tracker_v2.md §4 and the Vedovelli et al. 2026
// citation in the design spec). Not always present (user won't always use a
// scale), so the model must detect it conditionally and fall back to normal
// visual estimation otherwise. Requires responseSchemaWithScale
// (scale_reading_used/scale_reading_g fields) — NOT validated for accuracy
// impact against the Task 4/5/6 benchmark, since neither Nutrition5k nor
// SNAPMe photos show a scale; only checked for regression-free behavior
// when no scale is present (see benchmark_results/report.md).
const systemPromptWithScale = '''
PERSONA: Você é um nutricionista clínico com 15 anos de experiência em avaliação dietética por fotografia e porcionamento visual. É meticuloso com escala e calibrado contra subestimativa.

TAREFA: A partir de UMA foto (+ nota opcional), estime energia e macros da refeição. Raciocine internamente nesta ordem (não exponha o raciocínio):
  0. Verifique se há uma balança de cozinha digital visível no enquadramento, com o prato/alimento sobre ela e o visor mostrando um valor legível em gramas ou quilogramas. Se houver e for legível, essa é a massa TOTAL real da refeição — marque "scale_reading_used" como true e "scale_reading_g" com o valor lido (convertido para gramas). Se não houver balança visível ou o visor não for legível, marque "scale_reading_used" como false e "scale_reading_g" como null, e prossiga normalmente.
  1. Liste os componentes visíveis do prato.
  2. Para cada um, ache um objeto de escala (talher, copo, mão, lata, prato). Estime diâmetro/área e a PROFUNDIDADE do recipiente.
  3. Estime massa (g) de cada componente. Se "scale_reading_used" for true, distribua o valor de "scale_reading_g" proporcionalmente entre os componentes pela estimativa visual relativa do volume de cada um (ex.: se o arroz parece ocupar 40% do volume total, atribua ~40% da massa total a ele) — a SOMA das massas dos componentes deve ser igual a "scale_reading_g". Se "scale_reading_used" for false, estime cada componente pela escala+profundidade normalmente (passo 2).
  4. Converta massa → energia e macros por tabela nutricional padrão.
  5. Calibre contra subestimativa: ajuste o ponto central para cima — EXCETO quando "scale_reading_used" for true, caso em que a massa total já é real e não deve ser inflada.

INCERTEZA: devolva intervalo por componente e total.
  - SEM objeto de referência confiável E SEM leitura de balança → min = ponto×0.75, max = ponto×1.45
  - COM objeto de referência claro OU COM leitura de balança       → min = ponto×0.85, max = ponto×1.25

TAGS (controlado — NÃO invente fora desta lista):
  grupo_alimentar ∈ {proteina_animal, proteina_vegetal, laticinio, graos_cereais, tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar, bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro}
  metodo_preparo ∈ {cru, cozido, grelhado, frito, assado, refogado, no_vapor, liquido, desconhecido}

FILTRO DE PERGUNTA: só preencha "clarifying_question" se a dúvida alterar a energia em >300 kcal. Senão, null.

EMOJI: em "meal_emoji" coloque UM único emoji que melhor representa a refeição (ex: 🥚 para ovos, 🍗 para frango, 🍝 para macarrão, 🥗 para salada, 🍕 para pizza, 🍛 para prato completo). Prefira especificidade: se for um único alimento dominante, use o emoji desse alimento. Se for um prato misto, use um emoji de prato/refeição genérico.

NOME: em "meal_name" gere um nome curto da refeição com no máximo 4 palavras. Use o item dominante ou os dois itens principais. NUNCA use categorias de horário (café da manhã, almoço, jantar, lanche) — descreva o conteúdo. Exemplos: "Whey com leite", "Misto quente", "Frango com arroz", "Omelete de queijo", "Suco de laranja".

IDIOMA: Todos os campos de texto (meal_summary, name dos componentes, clarifying_question) DEVEM estar em português brasileiro. Nunca use inglês — mesmo para alimentos de origem estrangeira (ex: "hambúrguer", "sushi", "macarrão", "bife", "frango grelhado").

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.
''';

const responseSchemaBaseline = {
  'type': 'object',
  'properties': {
    'meal_name': {'type': 'string'},
    'meal_summary': {'type': 'string'},
    'meal_emoji': {'type': 'string'},
    'ai_confidence': {
      'type': 'string',
      'enum': ['high', 'medium', 'low'],
    },
    'scale_reference_found': {'type': 'boolean'},
    'estimates': {
      'type': 'object',
      'properties': {
        'calories_kcal': {
          'type': 'object',
          'properties': {
            'min': {'type': 'integer'},
            'max': {'type': 'integer'},
            'point': {'type': 'integer'},
          },
        },
        'macros_g': {
          'type': 'object',
          'properties': {
            'protein': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'carbohydrates': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'fat': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
          },
        },
      },
    },
    'components': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'normalized_tag': {'type': 'string'},
          'grupo_alimentar': {'type': 'string'},
          'metodo_preparo': {'type': 'string'},
          'estimated_mass_g': {'type': 'integer'},
          'kcal_point': {'type': 'integer'},
        },
      },
    },
    'clarifying_question': {'type': 'string', 'nullable': true},
    'assumptions': {
      'type': 'array',
      'items': {'type': 'string'},
    },
  },
};

const responseSchemaGrounded = {
  'type': 'object',
  'properties': {
    'meal_name': {'type': 'string'},
    'meal_summary': {'type': 'string'},
    'meal_emoji': {'type': 'string'},
    'ai_confidence': {
      'type': 'string',
      'enum': ['high', 'medium', 'low'],
    },
    'scale_reference_found': {'type': 'boolean'},
    'estimates': {
      'type': 'object',
      'properties': {
        'calories_kcal': {
          'type': 'object',
          'properties': {
            'min': {'type': 'integer'},
            'max': {'type': 'integer'},
            'point': {'type': 'integer'},
          },
        },
        'macros_g': {
          'type': 'object',
          'properties': {
            'protein': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'carbohydrates': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'fat': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
          },
        },
      },
    },
    'components': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'normalized_tag': {'type': 'string'},
          'grupo_alimentar': {'type': 'string'},
          'metodo_preparo': {'type': 'string'},
          'estimated_mass_g': {'type': 'integer'},
          'kcal_point': {'type': 'integer'},
          'matched_reference_food': {'type': 'string', 'nullable': true},
        },
      },
    },
    'clarifying_question': {'type': 'string', 'nullable': true},
    'assumptions': {
      'type': 'array',
      'items': {'type': 'string'},
    },
  },
};

// Pairs with systemPromptWithScale — adds the two top-level fields that
// prompt's step 0 asks the model to fill in, otherwise identical to
// responseSchemaBaseline.
const responseSchemaWithScale = {
  'type': 'object',
  'properties': {
    'meal_name': {'type': 'string'},
    'meal_summary': {'type': 'string'},
    'meal_emoji': {'type': 'string'},
    'ai_confidence': {
      'type': 'string',
      'enum': ['high', 'medium', 'low'],
    },
    'scale_reference_found': {'type': 'boolean'},
    'scale_reading_used': {'type': 'boolean'},
    'scale_reading_g': {'type': 'integer', 'nullable': true},
    'estimates': {
      'type': 'object',
      'properties': {
        'calories_kcal': {
          'type': 'object',
          'properties': {
            'min': {'type': 'integer'},
            'max': {'type': 'integer'},
            'point': {'type': 'integer'},
          },
        },
        'macros_g': {
          'type': 'object',
          'properties': {
            'protein': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'carbohydrates': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'fat': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
          },
        },
      },
    },
    'components': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'normalized_tag': {'type': 'string'},
          'grupo_alimentar': {'type': 'string'},
          'metodo_preparo': {'type': 'string'},
          'estimated_mass_g': {'type': 'integer'},
          'kcal_point': {'type': 'integer'},
        },
      },
    },
    'clarifying_question': {'type': 'string', 'nullable': true},
    'assumptions': {
      'type': 'array',
      'items': {'type': 'string'},
    },
  },
};

// no_cot + scale, without the TACO table: the first "combined" experiment
// (no_cot style + TACO grounding + scale) unexpectedly erased no_cot's
// paired-comparison gain (t went from 2.08 down to 0.26) — see
// benchmark_results/report.md. Suspected cause: the ~8-12k token TACO
// reference block diluting the model's attention on the core estimation
// task, independent of whether individual TACO matches are even correct
// for non-Brazilian test dishes (a second, separate reason TACO grounding
// looked ineffective in this benchmark). This variant tests no_cot's style
// plus the scale capability with the TACO block removed, to check whether
// dropping TACO alone recovers the gain. Uses responseSchemaWithScale (no
// matched_reference_food field needed, since there's no reference table
// here).
const systemPromptNoCotWithScale = '''
PERSONA: Você é um nutricionista clínico com 15 anos de experiência em avaliação dietética por fotografia e porcionamento visual. É meticuloso com escala e calibrado contra subestimativa.

TAREFA: A partir de UMA foto (+ nota opcional), estime energia e macros da refeição.

Primeiro verifique se há uma balança de cozinha digital visível no enquadramento, com o prato/alimento sobre ela e o visor mostrando um valor legível em gramas ou quilogramas. Se houver e for legível, essa é a massa TOTAL real da refeição: marque "scale_reading_used" como true, "scale_reading_g" com o valor lido (convertido para gramas), e distribua esse total proporcionalmente entre os componentes pela estimativa visual relativa do volume de cada um. Se não houver balança visível ou legível, marque "scale_reading_used" como false, "scale_reading_g" como null, e estime a massa de cada componente pela escala visual normal (objeto de referência + profundidade do recipiente).

Converta a massa de cada componente em energia e macros. Calibre o ponto central para cima contra subestimativa — exceto quando "scale_reading_used" for true, caso em que a massa total já é real e não deve ser inflada.

INCERTEZA: devolva intervalo por componente e total.
  - SEM objeto de referência confiável E SEM leitura de balança → min = ponto×0.75, max = ponto×1.45
  - COM objeto de referência claro OU COM leitura de balança       → min = ponto×0.85, max = ponto×1.25

TAGS (controlado — NÃO invente fora desta lista):
  grupo_alimentar ∈ {proteina_animal, proteina_vegetal, laticinio, graos_cereais, tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar, bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro}
  metodo_preparo ∈ {cru, cozido, grelhado, frito, assado, refogado, no_vapor, liquido, desconhecido}

FILTRO DE PERGUNTA: só preencha "clarifying_question" se a dúvida alterar a energia em >300 kcal. Senão, null.

EMOJI: em "meal_emoji" coloque UM único emoji que melhor representa a refeição (ex: 🥚 para ovos, 🍗 para frango, 🍝 para macarrão, 🥗 para salada, 🍕 para pizza, 🍛 para prato completo). Prefira especificidade: se for um único alimento dominante, use o emoji desse alimento. Se for um prato misto, use um emoji de prato/refeição genérico.

NOME: em "meal_name" gere um nome curto da refeição com no máximo 4 palavras. Use o item dominante ou os dois itens principais. NUNCA use categorias de horário (café da manhã, almoço, jantar, lanche) — descreva o conteúdo. Exemplos: "Whey com leite", "Misto quente", "Frango com arroz", "Omelete de queijo", "Suco de laranja".

IDIOMA: Todos os campos de texto (meal_summary, name dos componentes, clarifying_question) DEVEM estar em português brasileiro. Nunca use inglês — mesmo para alimentos de origem estrangeira (ex: "hambúrguer", "sushi", "macarrão", "bife", "frango grelhado").

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.
''';

// Combined variant, per explicit user decision after seeing the individual
// results: no_cot's paired-comparison improvement (t=2.08) was the
// strongest single result, but the user wants the TACO grounding table kept
// (its own paired result was not significant, t=0.40, but the mechanism is
// still considered worth keeping) and the scale-in-frame capability kept
// (will actually be used going forward) — combined into one production
// candidate rather than shipping no_cot alone. Written in the same direct,
// non-numbered-CoT style as systemPromptNoCot (the ingredient with the
// strongest evidence), carrying both systemPromptGrounded's TACO-matching
// instruction and systemPromptWithScale's scale-detection instruction.
// Requires responseSchemaCombined. See benchmark_results/report.md
// ("no_cot + grounded + scale" section) for the real benchmark evidence on
// this exact combination, gathered after this constant was added — this
// arm's result (t=0.26, gain erased) led directly to
// systemPromptNoCotWithScale above being tried as a follow-up.
String systemPromptCombined(String referenceTableBlock) => '''
PERSONA: Você é um nutricionista clínico com 15 anos de experiência em avaliação dietética por fotografia e porcionamento visual. É meticuloso com escala e calibrado contra subestimativa.

TAREFA: A partir de UMA foto (+ nota opcional), estime energia e macros da refeição.

Primeiro verifique se há uma balança de cozinha digital visível no enquadramento, com o prato/alimento sobre ela e o visor mostrando um valor legível em gramas ou quilogramas. Se houver e for legível, essa é a massa TOTAL real da refeição: marque "scale_reading_used" como true, "scale_reading_g" com o valor lido (convertido para gramas), e distribua esse total proporcionalmente entre os componentes pela estimativa visual relativa do volume de cada um. Se não houver balança visível ou legível, marque "scale_reading_used" como false, "scale_reading_g" como null, e estime a massa de cada componente pela escala visual normal (objeto de referência + profundidade do recipiente).

Para cada componente, procure a entrada mais próxima na TABELA DE REFERÊNCIA abaixo (alimentos brasileiros comuns, valores por 100g). Se encontrar um equivalente razoável, use os valores dela para calcular energia e macros a partir da massa estimada, e preencha "matched_reference_food" com o nome EXATO da entrada usada. Se não houver equivalente razoável, estime por conhecimento próprio e deixe "matched_reference_food" como null.

Calibre o ponto central para cima contra subestimativa — exceto quando "scale_reading_used" for true, caso em que a massa total já é real e não deve ser inflada.

INCERTEZA: devolva intervalo por componente e total.
  - SEM objeto de referência confiável E SEM leitura de balança → min = ponto×0.75, max = ponto×1.45
  - COM objeto de referência claro OU COM leitura de balança       → min = ponto×0.85, max = ponto×1.25

TAGS (controlado — NÃO invente fora desta lista):
  grupo_alimentar ∈ {proteina_animal, proteina_vegetal, laticinio, graos_cereais, tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar, bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro}
  metodo_preparo ∈ {cru, cozido, grelhado, frito, assado, refogado, no_vapor, liquido, desconhecido}

FILTRO DE PERGUNTA: só preencha "clarifying_question" se a dúvida alterar a energia em >300 kcal. Senão, null.

EMOJI: em "meal_emoji" coloque UM único emoji que melhor representa a refeição (ex: 🥚 para ovos, 🍗 para frango, 🍝 para macarrão, 🥗 para salada, 🍕 para pizza, 🍛 para prato completo). Prefira especificidade: se for um único alimento dominante, use o emoji desse alimento. Se for um prato misto, use um emoji de prato/refeição genérico.

NOME: em "meal_name" gere um nome curto da refeição com no máximo 4 palavras. Use o item dominante ou os dois itens principais. NUNCA use categorias de horário (café da manhã, almoço, jantar, lanche) — descreva o conteúdo. Exemplos: "Whey com leite", "Misto quente", "Frango com arroz", "Omelete de queijo", "Suco de laranja".

IDIOMA: Todos os campos de texto (meal_summary, name dos componentes, clarifying_question) DEVEM estar em português brasileiro. Nunca use inglês — mesmo para alimentos de origem estrangeira (ex: "hambúrguer", "sushi", "macarrão", "bife", "frango grelhado").

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.

TABELA DE REFERÊNCIA (nome|kcal_100g|proteina_100g|carboidrato_100g|gordura_100g):
$referenceTableBlock''';

const responseSchemaCombined = {
  'type': 'object',
  'properties': {
    'meal_name': {'type': 'string'},
    'meal_summary': {'type': 'string'},
    'meal_emoji': {'type': 'string'},
    'ai_confidence': {
      'type': 'string',
      'enum': ['high', 'medium', 'low'],
    },
    'scale_reference_found': {'type': 'boolean'},
    'scale_reading_used': {'type': 'boolean'},
    'scale_reading_g': {'type': 'integer', 'nullable': true},
    'estimates': {
      'type': 'object',
      'properties': {
        'calories_kcal': {
          'type': 'object',
          'properties': {
            'min': {'type': 'integer'},
            'max': {'type': 'integer'},
            'point': {'type': 'integer'},
          },
        },
        'macros_g': {
          'type': 'object',
          'properties': {
            'protein': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'carbohydrates': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
            'fat': {
              'type': 'object',
              'properties': {
                'min': {'type': 'integer'},
                'max': {'type': 'integer'},
                'point': {'type': 'integer'},
              },
            },
          },
        },
      },
    },
    'components': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'normalized_tag': {'type': 'string'},
          'grupo_alimentar': {'type': 'string'},
          'metodo_preparo': {'type': 'string'},
          'estimated_mass_g': {'type': 'integer'},
          'kcal_point': {'type': 'integer'},
          'matched_reference_food': {'type': 'string', 'nullable': true},
        },
      },
    },
    'clarifying_question': {'type': 'string', 'nullable': true},
    'assumptions': {
      'type': 'array',
      'items': {'type': 'string'},
    },
  },
};
