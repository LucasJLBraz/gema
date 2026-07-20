# KCAL Accuracy Grounding + Gemini Model Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ground the Gemini meal-estimation prompt's massa→kcal conversion in a real Brazilian nutrition table (TACO), build a reproducible accuracy benchmark using public datasets, and use that benchmark to decide — before the 2026-10-16 shutdown of `gemini-2.5-flash-lite` — whether to migrate to `gemini-3.1-flash-lite`.

**Architecture:** `lib/core/gemini/gemini_service.dart` is refactored so the HTTP-calling logic (`callGemini`) is decoupled from the two things currently hardcoded into it: which prompt/schema variant to use, and which model to call. Two prompt/schema pairs coexist — `*Baseline` (today's production behavior, unchanged) and `*Grounded` (new, injects a curated TACO reference table and adds a `matched_reference_food` field) — so a standalone benchmark script can run all 4 combinations (2 prompt arms × 2 models) against public ground-truth datasets without touching the running app. Production only switches to the grounded prompt and/or the new model in a final, explicit cutover task, gated on the benchmark's result.

**Tech Stack:** Dart (Flutter app code + standalone `dart run` tool scripts), `package:http`, `flutter_test`, CSV/JSONL for benchmark data interchange.

## Global Constraints

- Gemini rate limit: serial calls with ≥4–6s between them; on HTTP 429/503 back off 1–120s reading `Retry-After` (reuse existing `_parseRetryAfter`/`GeminiRateLimitException`).
- Always call the API with `responseMimeType: "application/json"` + `responseSchema` — never parse free-form text.
- Photo compression stays at max 800px longest side, JPEG quality 65% (unchanged, reuse `_compressImage`).
- All model-generated text fields stay pt-BR (unchanged prompt rule).
- No feature flag: production prompt/schema/model are swapped via direct constant changes once the benchmark gate passes (spec §5) — not before.
- `gemini-2.5-flash-lite` has a confirmed shutdown date of **2026-10-16**; the model decision (Task 7) must land before then regardless of benchmark outcome timing pressure.
- `flutter analyze` must pass before every commit (project rule, CLAUDE.md).
- No Isar schema changes — the TACO table is a static bundled JSON asset, not a database collection.
- `benchmark_data/` and `benchmark_results/` are local working directories only — third-party dataset files and raw API response dumps must never be committed.

---

## Task 1: Curate the TACO reference table asset

**Files:**
- Create: `tool/curate_taco_reference.dart`
- Create: `assets/data/taco_reference.json` (generated output, committed)
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: `assets/data/taco_reference.json` — a JSON array of objects, each `{"name": String, "grupo_alimentar": String, "kcal_100g": num, "protein_100g": num, "carb_100g": num, "fat_100g": num}`. Task 2 consumes this exact shape.

Source: [`brolesi/taco`](https://github.com/brolesi/taco) — MIT-licensed code, data redistributed from NEPA/UNICAMP (public access), `data/processed/taco/taco_composicao.csv`, ~597 items, all values per 100g of edible portion.

- [ ] **Step 1: Download the source CSV**

```bash
mkdir -p /tmp/taco_source
curl -L -o /tmp/taco_source/taco_composicao.csv \
  https://raw.githubusercontent.com/brolesi/taco/main/data/processed/taco/taco_composicao.csv
head -3 /tmp/taco_source/taco_composicao.csv
```

If this 404s, the repo layout changed since this plan was written — browse `https://github.com/brolesi/taco/tree/main/data/processed/taco` to find the current path and column dictionary before continuing.

- [ ] **Step 2: Write the curation script**

`brolesi/taco` documents columns using standard TACO 4th-edition Portuguese headers, and encodes missing values as `NA` and trace amounts as `Tr`. Write `tool/curate_taco_reference.dart`:

```dart
import 'dart:convert';
import 'dart:io';

// Column names per the TACO 4th-edition dictionary used by brolesi/taco.
// If the downloaded CSV's header row doesn't match, the script throws with
// the actual header so you can fix these constants — don't guess silently.
const _colName = 'Descrição dos alimentos';
const _colKcal = 'Energia (kcal)';
const _colProtein = 'Proteína (g)';
const _colCarb = 'Carboidrato (g)';
const _colFat = 'Lipídeos (g)';

double? _parseNum(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == 'NA' || trimmed == '*') return null;
  if (trimmed == 'Tr') return 0.0;
  return double.tryParse(trimmed.replaceAll(',', '.'));
}

// Coarse keyword classifier into the app's existing grupo_alimentar enum
// (see lib/core/gemini/gemini_service.dart _systemPrompt). Order matters —
// first match wins.
const _keywordGroups = <String, List<String>>{
  'proteina_animal': ['frango', 'carne', 'boi', 'peixe', 'ovo', 'porco', 'suíno', 'peru', 'camarão', 'atum'],
  'laticinio': ['leite', 'queijo', 'iogurte', 'requeijão', 'manteiga'],
  'graos_cereais': ['arroz', 'aveia', 'trigo', 'macarrão', 'pão', 'milho', 'farinha'],
  'tuberculo': ['batata', 'mandioca', 'aipim', 'inhame', 'cará'],
  'leguminosa': ['feijão', 'lentilha', 'grão-de-bico', 'ervilha', 'soja'],
  'fruta': ['banana', 'maçã', 'laranja', 'uva', 'manga', 'abacaxi', 'mamão', 'melancia', 'morango'],
  'gordura_oleo': ['óleo', 'azeite', 'margarina', 'gordura'],
  'doce_acucar': ['açúcar', 'doce', 'chocolate', 'mel', 'bala'],
  'bebida_calorica': ['suco', 'refrigerante', 'cerveja', 'vinho'],
  'vegetal': ['alface', 'tomate', 'cenoura', 'couve', 'brócolis', 'abobrinha', 'pepino', 'cebola', 'repolho'],
};

String _classify(String name) {
  final lower = name.toLowerCase();
  for (final entry in _keywordGroups.entries) {
    if (entry.value.any(lower.contains)) return entry.key;
  }
  return 'outro';
}

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
  final lines = File('/tmp/taco_source/taco_composicao.csv').readAsLinesSync();
  final header = _parseCsvLine(lines.first);

  for (final required in [_colName, _colKcal, _colProtein, _colCarb, _colFat]) {
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

  final entries = <Map<String, dynamic>>[];
  var skipped = 0;

  for (final line in lines.skip(1)) {
    if (line.trim().isEmpty) continue;
    final cols = _parseCsvLine(line);
    final name = cols[idxName].trim();
    final kcal = _parseNum(cols[idxKcal]);
    final protein = _parseNum(cols[idxProtein]);
    final carb = _parseNum(cols[idxCarb]);
    final fat = _parseNum(cols[idxFat]);

    if (name.isEmpty || kcal == null || protein == null || carb == null || fat == null) {
      skipped++;
      continue;
    }

    entries.add({
      'name': name,
      'grupo_alimentar': _classify(name),
      'kcal_100g': kcal,
      'protein_100g': protein,
      'carb_100g': carb,
      'fat_100g': fat,
    });
  }

  final outFile = File('assets/data/taco_reference.json');
  outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(entries));

  stderr.writeln('Wrote ${entries.length} entries, skipped $skipped incomplete rows.');
  stderr.writeln('Wrote ${outFile.path}');
}
```

We deliberately keep the *full* cleaned table (~500+ items) instead of hand-curating a 150–250 item subset as the spec's first draft suggested — hand-picking "common" items is a subjective judgment call with no data to base it on, while including everything with complete macro data is mechanical and reproducible. Token cost scales from the spec's ~3–5k estimate to roughly ~8–12k tokens/call, still under $0.002/call on `gemini-2.5-flash-lite` pricing — negligible against the free-tier budget.

- [ ] **Step 3: Run it and sanity-check the output**

```bash
dart run tool/curate_taco_reference.dart
python3 -c "import json; d = json.load(open('assets/data/taco_reference.json')); print(len(d)); print(d[0])"
```

Expected: a few hundred entries printed, first entry has all 6 fields populated and a non-`outro` `grupo_alimentar` for common items (rice, beans, chicken, etc. should classify correctly — spot check a handful).

- [ ] **Step 4: Register the asset in `pubspec.yaml`**

Change:
```yaml
flutter:
  uses-material-design: true
```
to:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/data/taco_reference.json
```

- [ ] **Step 5: Commit**

```bash
git add tool/curate_taco_reference.dart assets/data/taco_reference.json pubspec.yaml
git commit -m "Add curated TACO nutrition reference table asset"
```

---

## Task 2: Nutrition reference loader

**Files:**
- Create: `lib/core/gemini/nutrition_reference.dart`
- Test: `test/unit/nutrition_reference_test.dart`

**Interfaces:**
- Consumes: `assets/data/taco_reference.json` (Task 1's output), shape `{name, grupo_alimentar, kcal_100g, protein_100g, carb_100g, fat_100g}`.
- Produces: `class TacoReferenceEntry`, `List<TacoReferenceEntry> parseTacoReferenceJson(String raw)`, `String formatReferenceTableBlock(List<TacoReferenceEntry> entries)`, `Future<List<TacoReferenceEntry>> loadTacoReference()`. Task 3 and Task 5 both call `loadTacoReference()` + `formatReferenceTableBlock()`.

- [ ] **Step 1: Write the failing test**

```dart
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
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/unit/nutrition_reference_test.dart
```

Expected: FAIL — `package:gema/core/gemini/nutrition_reference.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

```dart
// lib/core/gemini/nutrition_reference.dart
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
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/unit/nutrition_reference_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/gemini/nutrition_reference.dart test/unit/nutrition_reference_test.dart
git commit -m "Add TACO nutrition reference loader and prompt-block formatter"
```

---

## Task 3: Grounded prompt/schema + decouple model and API key from `estimateMeal`

**Files:**
- Modify: `lib/core/gemini/gemini_service.dart`
- Test: `test/unit/gemini_prompt_test.dart`

**Interfaces:**
- Produces: `const productionModel` (renamed from `_model`), `const systemPromptBaseline` (renamed from `_systemPrompt`, content unchanged), `const responseSchemaBaseline` (renamed from `_responseSchema`, content unchanged), `String systemPromptGrounded(String referenceTableBlock)`, `const responseSchemaGrounded`, `Future<GeminiResult> callGemini({required String systemPrompt, required Map<String, dynamic> responseSchema, required String model, required String apiKey, String? photoPath, required String userNote, int retryCount = 0})`. Task 5 (benchmark runner) imports all of these directly.
- `estimateMeal({String? photoPath, required String userNote, int retryCount = 0})` keeps its exact current signature and, after this task, still produces byte-for-byte the same request as before (baseline prompt, baseline schema, `productionModel`) — this task changes no production behavior, only adds new unused-by-production capability. The grounded path gets wired into `estimateMeal` in Task 7, after the benchmark gate passes.

- [ ] **Step 1: Write the failing tests**

```dart
// test/unit/gemini_prompt_test.dart
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
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/unit/gemini_prompt_test.dart
```

Expected: FAIL — `systemPromptGrounded`, `responseSchemaGrounded`, `responseSchemaBaseline` don't exist yet (file currently only has private `_systemPrompt`/`_responseSchema`).

- [ ] **Step 3: Implement**

In `lib/core/gemini/gemini_service.dart`:

1. Rename `const _model = 'gemini-2.5-flash-lite';` to `const productionModel = 'gemini-2.5-flash-lite';` and delete the old `const _baseUrl = ...` (built from `_model`); replace with:

```dart
Uri _endpointFor(String model, String apiKey) => Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
);
```

2. Rename `const _systemPrompt = '''...''';` to `const systemPromptBaseline = '''...''';` (text unchanged — this is the exact prompt already in production).

3. Add, right after it:

```dart
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
```

4. Rename `const _responseSchema = {...};` to `const responseSchemaBaseline = {...};` (unchanged).

5. Add, right after it, a full copy with the one extra field (mirrors the existing single-literal style in this file rather than programmatic map-merging, which is clearer to read and diff):

```dart
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
```

6. Extract `callGemini` from the body of `estimateMeal` — replace the whole current `estimateMeal` function with:

```dart
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
  debugPrint('[Gemini] POST $model (attempt ${retryCount + 1})');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );
  debugPrint('[Gemini] status=${response.statusCode}');

  if (response.statusCode == 429 || response.statusCode == 503) {
    final retryAfter = _parseRetryAfter(
      response.headers['retry-after'],
      retryCount,
    );
    debugPrint('[Gemini] rate-limited — retry in ${retryAfter}s');
    throw GeminiRateLimitException(retryAfter);
  }

  if (response.statusCode != 200) {
    debugPrint(
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

Future<GeminiResult> estimateMeal({
  String? photoPath,
  required String userNote,
  int retryCount = 0,
}) async {
  final apiKey = await loadApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    throw const GeminiApiException('API key not configured');
  }

  return callGemini(
    systemPrompt: systemPromptBaseline,
    responseSchema: responseSchemaBaseline,
    model: productionModel,
    apiKey: apiKey,
    photoPath: photoPath,
    userNote: userNote,
    retryCount: retryCount,
  );
}
```

`_parseResult` is unchanged — it already copies every key out of each raw component map (`Map<String, dynamic>.from(e as Map)`), so `matched_reference_food` passes through automatically without any typed-model change when the grounded schema is used later.

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/unit/gemini_prompt_test.dart test/unit/
```

Expected: PASS, including all pre-existing tests (this task must not break `algorithms_test.dart`).

- [ ] **Step 5: Static analysis**

```bash
flutter analyze
```

Expected: no new issues (watch for unused-import or renamed-symbol errors from the `_model`/`_systemPrompt`/`_responseSchema` renames — grep the file for any leftover old names).

- [ ] **Step 6: Commit**

```bash
git add lib/core/gemini/gemini_service.dart test/unit/gemini_prompt_test.dart
git commit -m "Decouple Gemini prompt/schema/model from estimateMeal; add grounded variant"
```

---

## Task 4: Benchmark ground-truth data preparation

**Files:**
- Create: `tool/prepare_nutrition5k_sample.dart`
- Create: `tool/prepare_snapme_sample.dart`
- Modify: `.gitignore`

**Interfaces:**
- Produces: `benchmark_data/ground_truth.csv` with columns `sample_id,dataset,image_path,weight_g,kcal,protein_g,carb_g,fat_g`. Task 5 consumes this file.

- [ ] **Step 1: Gitignore the local dataset/results working directories**

```bash
echo "" >> .gitignore
echo "# Local benchmark working data — never commit third-party datasets or raw API dumps." >> .gitignore
echo "benchmark_data/" >> .gitignore
echo "benchmark_results/" >> .gitignore
```

- [ ] **Step 2: Pull a Nutrition5k sample via `gsutil`**

Nutrition5k ([google-research-datasets/Nutrition5k](https://github.com/google-research-datasets/Nutrition5k), CC BY 4.0) is 181GB in full — pull only metadata plus a sample of overhead images:

```bash
mkdir -p benchmark_data/nutrition5k
gsutil cp "gs://nutrition5k_dataset/nutrition5k_dataset/metadata/dish_metadata_cafe1.csv" \
  benchmark_data/nutrition5k/
```

`dish_metadata_cafe1.csv` columns: `dish_id, total_calories, total_mass, total_fat, total_carb, total_protein, num_ingrs, (ingr_1_id, ingr_1_name, ingr_1_grams, ...)` — only the first 7 columns matter here.

Write `tool/prepare_nutrition5k_sample.dart`:

```dart
import 'dart:io';

const _sampleSize = 60;

List<String> _parseCsvLine(String line) => line.split(',');

void main() async {
  final lines = File('benchmark_data/nutrition5k/dish_metadata_cafe1.csv')
      .readAsLinesSync();

  final rows = <Map<String, String>>[];
  for (final line in lines) {
    final cols = _parseCsvLine(line);
    if (cols.length < 6) continue;
    rows.add({
      'dish_id': cols[0],
      'total_calories': cols[1],
      'total_mass': cols[2],
      'total_fat': cols[3],
      'total_carb': cols[4],
      'total_protein': cols[5],
    });
  }

  final sample = rows.take(_sampleSize).toList();

  final imagesDir = Directory('benchmark_data/nutrition5k/images');
  imagesDir.createSync(recursive: true);

  for (final row in sample) {
    final dishId = row['dish_id']!;
    final result = await Process.run('gsutil', [
      'cp',
      'gs://nutrition5k_dataset/nutrition5k_dataset/imagery/realsense_overhead/$dishId/rgb.png',
      '${imagesDir.path}/$dishId.png',
    ]);
    if (result.exitCode != 0) {
      stderr.writeln('Skipping $dishId: ${result.stderr}');
    }
  }

  final csv = StringBuffer('sample_id,dataset,image_path,weight_g,kcal,protein_g,carb_g,fat_g\n');
  for (final row in sample) {
    final dishId = row['dish_id']!;
    final imagePath = '${imagesDir.path}/$dishId.png';
    if (!File(imagePath).existsSync()) continue;
    csv.writeln(
      'n5k_$dishId,nutrition5k,$imagePath,'
      '${row['total_mass']},${row['total_calories']},'
      '${row['total_protein']},${row['total_carb']},${row['total_fat']}',
    );
  }

  File('benchmark_data/ground_truth.csv').writeAsStringSync(csv.toString());
  stderr.writeln('Wrote ${sample.length} candidate rows (some may have been skipped on download failure).');
}
```

Run:

```bash
dart run tool/prepare_nutrition5k_sample.dart
wc -l benchmark_data/ground_truth.csv
```

Expected: `benchmark_data/ground_truth.csv` with a header plus up to 60 data rows (fewer if some `gsutil cp` calls failed — that's fine, note the actual count).

- [ ] **Step 3: Pull the SNAPMe sample (manual download step)**

SNAPMe (USDA Ag Data Commons, CC BY 4.0) doesn't expose a scriptable direct-download URL from this planning session — the Ag Data Commons/Figshare item page blocks automated fetches. Download it manually:

1. Open `https://agdatacommons.nal.usda.gov/articles/dataset/SNAPMe_A_Benchmark_Dataset_of_Food_Photos_with_Food_Records_for_Evaluation_of_Computer_Vision_Algorithms_in_the_Context_of_Dietary_Assessment/24856449` in a browser and download the dataset archive(s) into `benchmark_data/snapme/`.
2. Cross-reference the companion analysis repo [`JulesLarke-USDA/SNAPMe`](https://github.com/JulesLarke-USDA/SNAPMe) for the exact ASA24-linkage file format and FNDDS nutrient lookup — reuse their linkage logic rather than reverse-engineering it.
3. Inspect what you actually downloaded before writing the parser:

```bash
find benchmark_data/snapme -maxdepth 3 | head -50
```

- [ ] **Step 4: Write the SNAPMe normalizer against the real file layout**

Using the layout found in Step 3 (expect a `snapme_nut_db`-style tree keyed by participant/day, "before" photos as the primary image per ASA24 line item, and an ASA24 linkage table carrying `FoodCode` — join that to FNDDS nutrient values for weight/kcal/protein/carb/fat), write `tool/prepare_snapme_sample.dart` that appends rows to `benchmark_data/ground_truth.csv` with `dataset=snapme` and `sample_id` prefixed `snapme_`, same 8-column schema as Step 2's output. Cap at 60 samples to keep the benchmark run (Task 5) within a reasonable wall-clock time.

Run it and confirm:

```bash
dart run tool/prepare_snapme_sample.dart
wc -l benchmark_data/ground_truth.csv
```

Expected: total row count grows by up to 60 (header + Nutrition5k rows + SNAPMe rows).

- [ ] **Step 5: Commit the scripts (not the data)**

```bash
git add tool/prepare_nutrition5k_sample.dart tool/prepare_snapme_sample.dart .gitignore
git commit -m "Add benchmark ground-truth preparation scripts (Nutrition5k + SNAPMe)"
```

---

## Task 5: Benchmark runner

**Files:**
- Create: `tool/benchmark_kcal.dart`

**Interfaces:**
- Consumes: `benchmark_data/ground_truth.csv` (Task 4), `callGemini`/`systemPromptBaseline`/`systemPromptGrounded`/`responseSchemaBaseline`/`responseSchemaGrounded`/`loadTacoReference`/`formatReferenceTableBlock` (Task 2 + Task 3).
- Produces: `benchmark_results/raw_results.jsonl`, one JSON object per line: `{sample_id, dataset, arm, model, ground_truth: {weight_g, kcal, protein_g, carb_g, fat_g}, predicted: {...GeminiResult fields...} | null, error: String | null}`. Task 6 consumes this file.

- [ ] **Step 1: Write the runner**

```dart
// tool/benchmark_kcal.dart
import 'dart:convert';
import 'dart:io';

import 'package:gema/core/gemini/gemini_service.dart';
import 'package:gema/core/gemini/nutrition_reference.dart';

const _models = ['gemini-2.5-flash-lite', 'gemini-3.1-flash-lite'];
const _delayBetweenCalls = Duration(seconds: 6);

class _Arm {
  const _Arm(this.name, this.systemPrompt, this.responseSchema);
  final String name;
  final String systemPrompt;
  final Map<String, dynamic> responseSchema;
}

List<Map<String, String>> _readGroundTruth(String path) {
  final lines = File(path).readAsLinesSync();
  final header = lines.first.split(',');
  return lines.skip(1).where((l) => l.trim().isNotEmpty).map((line) {
    final cols = line.split(',');
    return {for (var i = 0; i < header.length; i++) header[i]: cols[i]};
  }).toList();
}

Future<void> main() async {
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Set GEMINI_API_KEY before running the benchmark.');
    exit(1);
  }

  final reference = await loadTacoReference();
  final referenceBlock = formatReferenceTableBlock(reference);

  final arms = [
    _Arm('baseline', systemPromptBaseline, responseSchemaBaseline),
    _Arm('grounded', systemPromptGrounded(referenceBlock), responseSchemaGrounded),
  ];

  final rows = _readGroundTruth('benchmark_data/ground_truth.csv');
  Directory('benchmark_results').createSync(recursive: true);
  final out = File('benchmark_results/raw_results.jsonl').openWrite();

  var completed = 0;
  final total = rows.length * arms.length * _models.length;

  for (final row in rows) {
    for (final arm in arms) {
      for (final model in _models) {
        completed++;
        stderr.writeln(
          '[$completed/$total] ${row['sample_id']} arm=${arm.name} model=$model',
        );

        Map<String, dynamic>? predicted;
        String? error;
        var retryCount = 0;

        while (true) {
          try {
            final result = await callGemini(
              systemPrompt: arm.systemPrompt,
              responseSchema: arm.responseSchema,
              model: model,
              apiKey: apiKey,
              photoPath: row['image_path'],
              userNote: '',
              retryCount: retryCount,
            );
            predicted = {
              'kcal_point': result.kcalPoint,
              'protein_point': result.proteinPoint,
              'carb_point': result.carbPoint,
              'fat_point': result.fatPoint,
              'components': result.components,
            };
            break;
          } on GeminiRateLimitException catch (e) {
            stderr.writeln('  rate-limited, sleeping ${e.retryAfterSeconds}s');
            await Future.delayed(Duration(seconds: e.retryAfterSeconds));
            retryCount++;
          } catch (e) {
            error = e.toString();
            break;
          }
        }

        out.writeln(jsonEncode({
          'sample_id': row['sample_id'],
          'dataset': row['dataset'],
          'arm': arm.name,
          'model': model,
          'ground_truth': {
            'weight_g': double.tryParse(row['weight_g'] ?? ''),
            'kcal': double.tryParse(row['kcal'] ?? ''),
            'protein_g': double.tryParse(row['protein_g'] ?? ''),
            'carb_g': double.tryParse(row['carb_g'] ?? ''),
            'fat_g': double.tryParse(row['fat_g'] ?? ''),
          },
          'predicted': predicted,
          'error': error,
        }));

        await Future.delayed(_delayBetweenCalls);
      }
    }
  }

  await out.close();
  stderr.writeln('Done. Wrote benchmark_results/raw_results.jsonl');
}
```

- [ ] **Step 2: Dry-run against a 2-row sample first**

Before burning the full free-tier quota, copy the first 2 data rows of `benchmark_data/ground_truth.csv` into a throwaway `benchmark_data/ground_truth_smoke.csv`, point the script at it temporarily (edit the path on the `_readGroundTruth` call), and run:

```bash
export GEMINI_API_KEY=$(security find-generic-password -w -s gema_gemini_key 2>/dev/null || echo "<paste key>")
dart run tool/benchmark_kcal.dart
cat benchmark_results/raw_results.jsonl
```

Expected: 8 lines (2 rows × 2 arms × 2 models), each with either a populated `predicted` object or a non-null `error` — confirms the wiring (imports, API key, rate-limit handling) works before the long run. Revert the path edit once confirmed.

- [ ] **Step 3: Run the full benchmark**

```bash
dart run tool/benchmark_kcal.dart
```

Expected wall-clock time: `rows × 4 combinations × 6s` — e.g. ~110 rows ≈ 44 minutes. Expect occasional rate-limit sleeps on top of that given two models sharing free-tier quota; let it run to completion.

- [ ] **Step 4: Commit the script only**

```bash
git add tool/benchmark_kcal.dart
git commit -m "Add KCAL grounding benchmark runner (prompt arm x model matrix)"
```

---

## Task 6: Benchmark metrics and gate report

**Files:**
- Create: `tool/compute_benchmark_metrics.dart`

**Interfaces:**
- Consumes: `benchmark_results/raw_results.jsonl` (Task 5).
- Produces: `benchmark_results/report.md`.

- [ ] **Step 1: Write the metrics script**

```dart
// tool/compute_benchmark_metrics.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class _Sample {
  _Sample(this.groundTruthKcal, this.predictedKcal, this.matchedReference);
  final double groundTruthKcal;
  final double predictedKcal;
  final bool matchedReference;
}

double _mape(List<_Sample> samples) {
  final errors = samples.map(
    (s) => (s.predictedKcal - s.groundTruthKcal).abs() / s.groundTruthKcal,
  );
  return errors.reduce((a, b) => a + b) / samples.length * 100;
}

double _mae(List<_Sample> samples) {
  final errors = samples.map((s) => (s.predictedKcal - s.groundTruthKcal).abs());
  return errors.reduce((a, b) => a + b) / samples.length;
}

(double mean, double sd) _blandAltmanBias(List<_Sample> samples) {
  final diffs = samples.map((s) => s.predictedKcal - s.groundTruthKcal).toList();
  final mean = diffs.reduce((a, b) => a + b) / diffs.length;
  final variance = diffs.map((d) => pow(d - mean, 2)).reduce((a, b) => a + b) /
      diffs.length;
  return (mean, sqrt(variance));
}

void main() {
  final lines = File('benchmark_results/raw_results.jsonl').readAsLinesSync();
  final decoded = lines
      .where((l) => l.trim().isNotEmpty)
      .map((l) => jsonDecode(l) as Map<String, dynamic>)
      .toList();

  final groups = <String, List<_Sample>>{};
  final matchRates = <String, List<bool>>{};

  for (final row in decoded) {
    final predicted = row['predicted'] as Map<String, dynamic>?;
    final groundTruth = row['ground_truth'] as Map<String, dynamic>;
    if (predicted == null || groundTruth['kcal'] == null) continue;

    final key = '${row['arm']}__${row['model']}';
    final components = predicted['components'] as List? ?? [];
    final matched = components.isNotEmpty &&
        components.every((c) => (c as Map)['matched_reference_food'] != null);

    (groups[key] ??= []).add(_Sample(
      (groundTruth['kcal'] as num).toDouble(),
      (predicted['kcal_point'] as num).toDouble(),
      matched,
    ));
    (matchRates[key] ??= []).add(matched);
  }

  final buffer = StringBuffer('# Benchmark report\n\n');
  buffer.writeln('| Arm | Model | N | MAPE kcal | MAE kcal | Bias (mean±sd) | matched_reference_food rate |');
  buffer.writeln('|---|---|---|---|---|---|---|');

  for (final key in groups.keys.toList()..sort()) {
    final samples = groups[key]!;
    final parts = key.split('__');
    final (mean, sd) = _blandAltmanBias(samples);
    final matchRate = _matchRate(matchRates[key]!);
    buffer.writeln(
      '| ${parts[0]} | ${parts[1]} | ${samples.length} | '
      '${_mape(samples).toStringAsFixed(1)}% | '
      '${_mae(samples).toStringAsFixed(1)} kcal | '
      '${mean.toStringAsFixed(1)}±${sd.toStringAsFixed(1)} | '
      '${matchRate.toStringAsFixed(0)}% |',
    );
  }

  File('benchmark_results/report.md').writeAsStringSync(buffer.toString());
  stderr.writeln(buffer.toString());
}

double _matchRate(List<bool> matches) =>
    matches.where((m) => m).length / matches.length * 100;
```

- [ ] **Step 2: Run it**

```bash
dart run tool/compute_benchmark_metrics.dart
cat benchmark_results/report.md
```

Expected: a 4-row markdown table (baseline/grounded × 2 models), each with MAPE, MAE, Bland-Altman bias, and `matched_reference_food` coverage. Read the `grounded` rows' `matched_reference_food` rate with the Task-4/spec caveat in mind — SNAPMe/Nutrition5k are American-population datasets, so this run's coverage rate likely underestimates real coverage for Brazilian dishes.

- [ ] **Step 3: Write the gate decision as a comment in the report**

Manually append to `benchmark_results/report.md` (this is a judgment call, not scriptable): per spec §5, only recommend promoting the grounded prompt if its MAPE beats baseline's by a practical margin for at least one model, and note which of `gemini-2.5-flash-lite` / `gemini-3.1-flash-lite` had the better grounded-arm MAPE — that's the Task 7 input.

- [ ] **Step 4: Commit the script**

```bash
git add tool/compute_benchmark_metrics.dart
git commit -m "Add benchmark metrics/report script (MAPE, MAE, Bland-Altman, coverage)"
```

---

## Task 7: Production cutover (gated on Task 6's report)

**Files:**
- Modify: `lib/core/gemini/gemini_service.dart`

**Interfaces:**
- Changes only the body of `estimateMeal` (signature unchanged) and, if the model changes, the value of `productionModel`.

This task's exact diff depends on Task 6's result — write it once the report exists, not before. Two sub-cases:

- [ ] **Step 1a: If the grounded arm wins (on either model) — wire it into production**

In `estimateMeal`, change:
```dart
    systemPrompt: systemPromptBaseline,
    responseSchema: responseSchemaBaseline,
```
to:
```dart
    systemPrompt: systemPromptGrounded(formatReferenceTableBlock(await loadTacoReference())),
    responseSchema: responseSchemaGrounded,
```
(add the `nutrition_reference.dart` import).

- [ ] **Step 1b: If the winning model is `gemini-3.1-flash-lite`, update the constant**

```dart
const productionModel = 'gemini-3.1-flash-lite';
```

Also update `CLAUDE.md`'s "AI" stack line and rate-limit note if the free-tier numbers differ (15 RPM / ~1,500 RPD for `gemini-3.1-flash-lite` vs the current ≤15 RPM / 1,000 RPD text).

- [ ] **Step 2: If baseline wins on both models — do nothing to the prompt, but still resolve the model migration**

Regardless of the accuracy result, `gemini-2.5-flash-lite` shuts down 2026-10-16. If Task 6 shows `gemini-3.1-flash-lite` is not worse on the baseline prompt, migrate `productionModel` to it anyway ahead of the deadline; only stay on `gemini-2.5-flash-lite` past this task if there's a plan to re-run this decision closer to the deadline.

- [ ] **Step 3: Run the full test suite and analyzer**

```bash
flutter test
flutter analyze
```

Expected: all green, no new issues.

- [ ] **Step 4: Manual smoke test**

Run the app against the emulator, capture one real meal photo, confirm a `done` status meal appears with plausible kcal/macros and (if grounded shipped) that `aiRawJson` contains non-null `matched_reference_food` for at least one component of a common Brazilian dish (rice, beans, chicken, etc.).

- [ ] **Step 5: Commit**

```bash
git add lib/core/gemini/gemini_service.dart CLAUDE.md
git commit -m "Promote benchmark-validated grounding and/or model to production"
```

---

## Verification

1. `flutter analyze` — must pass after every task, and especially after Task 3 and Task 7 where public symbols are renamed/added.
2. `flutter test` — full suite green after Task 2, Task 3, and Task 7 (new tests plus the pre-existing `algorithms_test.dart`).
3. Task 5's dry-run smoke test (2 rows) is the first point actual API behavior across both prompt arms and both models is exercised end-to-end — treat it as a mandatory checkpoint, not optional.
4. After Task 6, `benchmark_results/report.md` is the artifact that answers both backlog items #1 and #2 with real numbers — read it before writing Task 7's diff, don't assume the spec's hoped-for outcome.
5. Task 7's manual smoke test on the emulator is the only step that touches the real production path end-to-end (`confirm_meal_screen.dart` → `estimateMeal` → Isar persistence) — run it before considering this plan done.
