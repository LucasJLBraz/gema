import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/algorithms/tdee_algorithms.dart';
import '../../../core/db/database.dart';
import '../models/xp_event.dart';

part 'xp_provider.g.dart';

@riverpod
Future<int> totalXp(TotalXpRef ref) async {
  final all = await isar.xpEvents.where().findAll();
  return all.fold<int>(0, (sum, e) => sum + e.xpAmount);
}

@riverpod
Future<int> xpLevel(XpLevelRef ref) async {
  final xp = await ref.watch(totalXpProvider.future);
  return levelFromXp(xp);
}

@riverpod
class XpNotifier extends _$XpNotifier {
  @override
  Future<int> build() => ref.watch(totalXpProvider.future);

  Future<void> award(XpEventType type, DateTime day) async {
    final amounts = {
      XpEventType.allMealsLogged: 100,
      XpEventType.proteinGoal: 50,
      XpEventType.weightLogged: 30,
      XpEventType.cheatPlanned: 10,
      XpEventType.waterGoal: 20,
    };
    final dayOnly = DateTime(day.year, day.month, day.day);
    final existing = await isar.xpEvents
        .filter()
        .dayEqualTo(dayOnly)
        .eventTypeEqualTo(type)
        .findFirst();
    if (existing != null) return;

    final event = XpEvent()
      ..day = dayOnly
      ..eventType = type
      ..xpAmount = amounts[type] ?? 0
      ..createdAt = DateTime.now();
    await isar.writeTxn(() => isar.xpEvents.put(event));
    ref.invalidateSelf();
    ref.invalidate(totalXpProvider);
    ref.invalidate(xpLevelProvider);
  }
}
