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

/// Paired per-sample comparison (baseline vs. grounded, same sample_id, same
/// model) — added because aggregate MAPE is known to be outlier-sensitive
/// under high-variance errors (confirmed on the real run: Bland-Altman SDs
/// of ~150 kcal against a ~105 kcal MAE indicate a heavy-tailed error
/// distribution), so an aggregate MAPE improvement can look real while the
/// underlying per-sample wins are close to a coin flip. A paired t-test is
/// the right tool here specifically because both arms are evaluated on the
/// *same* samples (not independent groups), which is exactly this design.
class _PairedResult {
  _PairedResult(this.n, this.groundedWins, this.baselineWins, this.ties,
      this.meanDiff, this.sdDiff, this.tStat);
  final int n;
  final int groundedWins;
  final int baselineWins;
  final int ties;
  final double meanDiff;
  final double sdDiff;
  final double tStat;
}

_PairedResult? _pairedComparison(
  Map<String, Map<String, _Sample>> byIdThenArm,
) {
  final diffs = <double>[];
  var groundedWins = 0;
  var baselineWins = 0;
  var ties = 0;

  for (final arms in byIdThenArm.values) {
    final baseline = arms['baseline'];
    final grounded = arms['grounded'];
    if (baseline == null || grounded == null) continue;

    final baselineErr = (baseline.predictedKcal - baseline.groundTruthKcal).abs();
    final groundedErr = (grounded.predictedKcal - grounded.groundTruthKcal).abs();
    diffs.add(baselineErr - groundedErr); // positive => grounded closer

    if (groundedErr < baselineErr) {
      groundedWins++;
    } else if (baselineErr < groundedErr) {
      baselineWins++;
    } else {
      ties++;
    }
  }

  if (diffs.length < 2) return null;

  final n = diffs.length;
  final meanDiff = diffs.reduce((a, b) => a + b) / n;
  final variance = diffs.map((d) => pow(d - meanDiff, 2)).reduce((a, b) => a + b) /
      (n - 1);
  final sdDiff = sqrt(variance);
  final standardError = sdDiff / sqrt(n);
  final tStat = standardError == 0 ? 0.0 : meanDiff / standardError;

  return _PairedResult(n, groundedWins, baselineWins, ties, meanDiff, sdDiff, tStat);
}

void main() {
  final lines = File('benchmark_results/raw_results.jsonl').readAsLinesSync();
  final decoded = lines
      .where((l) => l.trim().isNotEmpty)
      .map((l) => jsonDecode(l) as Map<String, dynamic>)
      .toList();

  final groups = <String, List<_Sample>>{};
  final matchRates = <String, List<bool>>{};
  final latencies = <String, List<int>>{};
  // model -> sample_id -> arm -> sample, for the paired comparison below.
  final byModelThenIdThenArm = <String, Map<String, Map<String, _Sample>>>{};

  for (final row in decoded) {
    final arm = row['arm'] as String;
    final model = row['model'] as String;
    final key = '${arm}__$model';
    final latencyMs = row['latency_ms'] as int?;
    if (latencyMs != null) {
      (latencies[key] ??= []).add(latencyMs);
    }

    final predicted = row['predicted'] as Map<String, dynamic>?;
    final groundTruth = row['ground_truth'] as Map<String, dynamic>;
    if (predicted == null || groundTruth['kcal'] == null) continue;

    final components = predicted['components'] as List? ?? [];
    final matched = components.isNotEmpty &&
        components.every((c) => (c as Map)['matched_reference_food'] != null);

    final sample = _Sample(
      (groundTruth['kcal'] as num).toDouble(),
      (predicted['kcal_point'] as num).toDouble(),
      matched,
    );
    (groups[key] ??= []).add(sample);
    (matchRates[key] ??= []).add(matched);

    final sampleId = row['sample_id'] as String;
    ((byModelThenIdThenArm[model] ??= {})[sampleId] ??= {})[arm] = sample;
  }

  final buffer = StringBuffer('# Benchmark report\n\n');
  buffer.writeln('| Arm | Model | N | MAPE kcal | MAE kcal | Bias (mean±sd) | matched_reference_food rate | Latência média |');
  buffer.writeln('|---|---|---|---|---|---|---|---|');

  for (final key in groups.keys.toList()..sort()) {
    final samples = groups[key]!;
    final parts = key.split('__');
    final (mean, sd) = _blandAltmanBias(samples);
    final matchRate = _matchRate(matchRates[key]!);
    final avgLatencyMs = _average(latencies[key] ?? []);
    buffer.writeln(
      '| ${parts[0]} | ${parts[1]} | ${samples.length} | '
      '${_mape(samples).toStringAsFixed(1)}% | '
      '${_mae(samples).toStringAsFixed(1)} kcal | '
      '${mean.toStringAsFixed(1)}±${sd.toStringAsFixed(1)} | '
      '${matchRate.toStringAsFixed(0)}% | '
      '${(avgLatencyMs / 1000).toStringAsFixed(1)}s |',
    );
  }

  buffer.writeln();
  buffer.writeln('## Paired comparison (grounded vs. baseline, same samples)');
  buffer.writeln();
  buffer.writeln(
    'Aggregate MAPE/MAE can look improved even when the underlying '
    'per-sample predictions are not reliably better, if a few outliers '
    'dominate the average — the wide Bland-Altman SDs above are a signal '
    'that may be happening here. This table compares grounded vs. baseline '
    'on the exact same 100 samples per model, which a plain aggregate '
    'MAPE comparison cannot do.',
  );
  buffer.writeln();
  buffer.writeln('| Model | N pairs | Grounded wins | Baseline wins | Ties | Mean paired Δ (kcal) | t-stat |');
  buffer.writeln('|---|---|---|---|---|---|---|');

  for (final model in byModelThenIdThenArm.keys.toList()..sort()) {
    final result = _pairedComparison(byModelThenIdThenArm[model]!);
    if (result == null) continue;
    buffer.writeln(
      '| $model | ${result.n} | ${result.groundedWins} '
      '(${(result.groundedWins / result.n * 100).toStringAsFixed(0)}%) | '
      '${result.baselineWins} '
      '(${(result.baselineWins / result.n * 100).toStringAsFixed(0)}%) | '
      '${result.ties} | ${result.meanDiff.toStringAsFixed(1)} | '
      '${result.tStat.toStringAsFixed(2)} |',
    );
  }
  buffer.writeln();
  buffer.writeln(
    '(|t| ≳ 1.98 is roughly the p<0.05 threshold for n≈100 paired samples; '
    'positive mean Δ means grounded\'s per-sample error was smaller on '
    'average.)',
  );

  File('benchmark_results/report.md').writeAsStringSync(buffer.toString());
  stderr.writeln(buffer.toString());
}

double _matchRate(List<bool> matches) =>
    matches.where((m) => m).length / matches.length * 100;

double _average(List<int> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
