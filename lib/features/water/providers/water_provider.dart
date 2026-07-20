import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../models/water_log.dart';

part 'water_provider.g.dart';

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

@riverpod
class TodayWaterMl extends _$TodayWaterMl {
  @override
  Future<int> build() async {
    final today = _today();
    final logs = await isar.waterLogs.filter().dayEqualTo(today).findAll();
    return logs.fold<int>(0, (sum, l) => sum + l.ml);
  }

  Future<void> add(int ml) async {
    final entry = WaterLog()
      ..day = _today()
      ..ml = ml
      ..loggedAt = DateTime.now();
    await isar.writeTxn(() => isar.waterLogs.put(entry));
    ref.invalidateSelf();
  }

  Future<void> remove(int ml) async {
    final today = _today();
    // Find the most recent log entry and reduce or delete it
    final logs = await isar.waterLogs
        .filter()
        .dayEqualTo(today)
        .sortByLoggedAtDesc()
        .findAll();
    if (logs.isEmpty) return;

    var toRemove = ml;
    await isar.writeTxn(() async {
      for (final log in logs) {
        if (toRemove <= 0) break;
        if (log.ml <= toRemove) {
          toRemove -= log.ml;
          await isar.waterLogs.delete(log.id);
        } else {
          log.ml -= toRemove;
          toRemove = 0;
          await isar.waterLogs.put(log);
        }
      }
    });
    ref.invalidateSelf();
  }
}
