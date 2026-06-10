import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/algorithms/weight_algorithms.dart';
import '../../../core/db/database.dart';
import '../../gamification/models/xp_event.dart';
import '../../gamification/providers/xp_provider.dart';
import '../models/weight_entry.dart';

part 'weight_provider.g.dart';

@riverpod
Future<List<WeightEntry>> weightHistory(WeightHistoryRef ref) async {
  return isar.weightEntrys.where().sortByMeasuredOn().findAll();
}

@riverpod
Future<List<(DateTime, double)>> smoothedWeights(SmoothedWeightsRef ref) async {
  final entries = await ref.watch(weightHistoryProvider.future);
  if (entries.isEmpty) return [];

  final result = <(DateTime, double)>[];
  var smoothed = entries.first.weightKg;
  result.add((entries.first.measuredOn, smoothed));

  for (var i = 1; i < entries.length; i++) {
    final prev = entries[i - 1].measuredOn;
    final curr = entries[i].measuredOn;
    final delta = curr.difference(prev).inHours / 24.0;
    smoothed = timeAwareEma(
      previous: smoothed,
      observed: entries[i].weightKg,
      deltaDays: delta,
    );
    result.add((entries[i].measuredOn, smoothed));
  }
  return result;
}

@riverpod
class WeightNotifier extends _$WeightNotifier {
  @override
  Future<List<WeightEntry>> build() => ref.watch(weightHistoryProvider.future);

  Future<void> log(double weightKg, {double? bodyFatPct, String? note}) async {
    final today = DateTime.now();
    final dayOnly = DateTime(today.year, today.month, today.day);

    final existing = await isar.weightEntrys
        .filter()
        .measuredOnEqualTo(dayOnly)
        .findFirst();

    final entry = (existing ?? WeightEntry())
      ..measuredOn = dayOnly
      ..weightKg = weightKg
      ..bodyFatPct = bodyFatPct
      ..note = note;

    await isar.writeTxn(() => isar.weightEntrys.put(entry));
    ref.invalidateSelf();
    ref.invalidate(weightHistoryProvider);
    ref.invalidate(smoothedWeightsProvider);

    await ref
        .read(xpNotifierProvider.notifier)
        .award(XpEventType.weightLogged, today);
  }
}
