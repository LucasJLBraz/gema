import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

const _apiKeyStorageKey = 'gemini_api_key';
const _model = 'gemini-2.5-flash-lite-preview-06-17';
const _baseUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

final _storage = FlutterSecureStorage();

Future<String?> loadApiKey() => _storage.read(key: _apiKeyStorageKey);

Future<void> saveApiKey(String key) =>
    _storage.write(key: _apiKeyStorageKey, value: key);

Future<void> deleteApiKey() => _storage.delete(key: _apiKeyStorageKey);

class GeminiResult {
  const GeminiResult({
    required this.mealSummary,
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

  final String mealSummary;
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

Future<GeminiResult> estimateMeal({
  required String photoPath,
  required String userNote,
  int retryCount = 0,
}) async {
  final apiKey = await loadApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    throw const GeminiApiException('API key not configured');
  }

  final compressed = await _compressImage(photoPath);
  final b64 = base64Encode(compressed);

  final body = jsonEncode({
    'system_instruction': {
      'parts': [
        {'text': _systemPrompt},
      ],
    },
    'contents': [
      {
        'parts': [
          {
            'inline_data': {'mime_type': 'image/jpeg', 'data': b64},
          },
          if (userNote.isNotEmpty) {'text': userNote},
        ],
      },
    ],
    'generationConfig': {
      'temperature': 0.3,
      'responseMimeType': 'application/json',
      'responseSchema': _responseSchema,
    },
  });

  final uri = Uri.parse('$_baseUrl?key=$apiKey');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 429) {
    final retryAfter = _parseRetryAfter(
      response.headers['retry-after'],
      retryCount,
    );
    throw GeminiRateLimitException(retryAfter);
  }

  if (response.statusCode != 200) {
    throw GeminiApiException('HTTP ${response.statusCode}: ${response.body}');
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final text =
      (decoded['candidates'] as List).first['content']['parts'].first['text']
          as String;
  final parsed = jsonDecode(text) as Map<String, dynamic>;

  return _parseResult(parsed, text);
}

Future<List<int>> _compressImage(String path) async {
  final bytes = await File(path).readAsBytes();
  final original = img.decodeImage(bytes);
  if (original == null)
    throw const GeminiApiException('Could not decode image');

  final maxSide = 800;
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
    mealSummary: j['meal_summary'] as String? ?? '',
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

const _systemPrompt = '''
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

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.
''';

const _responseSchema = {
  'type': 'object',
  'properties': {
    'meal_summary': {'type': 'string'},
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
