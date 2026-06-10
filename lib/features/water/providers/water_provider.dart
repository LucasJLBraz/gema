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
    await isar.writeTxn(() async {
      await isar.waterLogs.put(entry);
    });
    ref.invalidateSelf();
  }
}
