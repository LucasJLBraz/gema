import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../models/goal.dart';

part 'goal_provider.g.dart';

@riverpod
Future<Goal?> activeGoal(ActiveGoalRef ref) async {
  return isar.goals.where().sortByEffectiveFromDesc().findFirst();
}

@riverpod
class GoalNotifier extends _$GoalNotifier {
  @override
  Future<Goal?> build() async {
    return isar.goals.where().sortByEffectiveFromDesc().findFirst();
  }

  Future<void> save(Goal goal) async {
    await isar.writeTxn(() async {
      await isar.goals.put(goal);
    });
    ref.invalidateSelf();
    ref.invalidate(activeGoalProvider);
  }
}
