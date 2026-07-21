// tool/benchmark_kcal.dart
import 'dart:convert';
import 'dart:io';

import 'package:gema/core/gemini/gemini_service.dart';
// The TACO reference-table loader/asset were removed as unused dead code
// (never wired into estimateMeal or this benchmark's current arms list).
// If a future run needs 'grounded' or 'combined' again, rebuild a table
// loader that reads the source TACO data directly via dart:io — don't
// resurrect the old rootBundle-based approach, which needs a Flutter
// engine unavailable under plain `dart run`.

// gemini-2.5-flash-lite (productionModel) is deliberately excluded from the
// full run: a smoke test with a freshly-created API key got HTTP 404 "This
// model models/gemini-2.5-flash-lite is no longer available to new users"
// on all 4 attempts (evidence preserved in
// benchmark_results/smoke_test_gemini25_404_evidence.jsonl) — the model is
// already unusable for any new GEMA user's own key today, not just after
// the 2026-10-16 shutdown date. Spending 200 of the 400 planned calls on a
// guaranteed-404 arm would waste time/quota without adding information the
// smoke test didn't already establish.
const _models = ['gemini-3.1-flash-lite'];
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

  // 'baseline', 'grounded', 'no_cot', 'with_scale', 'combined', and
  // 'no_cot_with_scale' already ran in prior invocations of this script
  // (results are in benchmark_results/raw_results.jsonl, appended to below
  // rather than overwritten). 'no_cot_with_scale' shipped to production
  // (t=0.23, not significant on this benchmark's scale=false-only sample,
  // but chosen for its scale-detection capability and no_cot's simpler
  // style). This run tests a domain-expert-suggested refinement:
  // 'no_cot_with_scale_reasoning' adds a raciocinio_volumetrico scratch
  // field (generated before the numeric fields, giving the model real
  // token-generation space to reason under structured JSON output) plus a
  // tightened scale-confirmed uncertainty band and minor wording polish --
  // see the comment above systemPromptNoCotWithScaleReasoning in
  // lib/core/gemini/gemini_service.dart for the full hypothesis.
  final arms = [
    const _Arm(
      'no_cot_with_scale_reasoning',
      systemPromptNoCotWithScaleReasoning,
      responseSchemaWithScaleReasoning,
    ),
  ];

  final rows = _readGroundTruth('benchmark_data/ground_truth.csv');
  Directory('benchmark_results').createSync(recursive: true);
  final out = File(
    'benchmark_results/raw_results.jsonl',
  ).openWrite(mode: FileMode.append);

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
        var latencyMs = 0;

        while (true) {
          final stopwatch = Stopwatch()..start();
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
            latencyMs = stopwatch.elapsedMilliseconds;
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
            await Future<void>.delayed(Duration(seconds: e.retryAfterSeconds));
            retryCount++;
          } on GeminiApiException catch (e) {
            // GeminiApiException doesn't override toString(), so e.toString()
            // alone would only print "Instance of 'GeminiApiException'" —
            // found by inspecting real smoke-test output where every
            // gemini-2.5-flash-lite call failed with no useful detail.
            latencyMs = stopwatch.elapsedMilliseconds;
            error = e.message;
            break;
          } catch (e) {
            latencyMs = stopwatch.elapsedMilliseconds;
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
          'latency_ms': latencyMs,
          'error': error,
        }));

        await Future<void>.delayed(_delayBetweenCalls);
      }
    }
  }

  await out.close();
  stderr.writeln('Done. Wrote benchmark_results/raw_results.jsonl');
}
