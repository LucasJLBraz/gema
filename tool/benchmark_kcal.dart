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
    const _Arm('baseline', systemPromptBaseline, responseSchemaBaseline),
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
