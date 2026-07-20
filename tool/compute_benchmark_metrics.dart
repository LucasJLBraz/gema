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
  final latencies = <String, List<int>>{};

  for (final row in decoded) {
    final key = '${row['arm']}__${row['model']}';
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

    (groups[key] ??= []).add(_Sample(
      (groundTruth['kcal'] as num).toDouble(),
      (predicted['kcal_point'] as num).toDouble(),
      matched,
    ));
    (matchRates[key] ??= []).add(matched);
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

  File('benchmark_results/report.md').writeAsStringSync(buffer.toString());
  stderr.writeln(buffer.toString());
}

double _matchRate(List<bool> matches) =>
    matches.where((m) => m).length / matches.length * 100;

double _average(List<int> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
