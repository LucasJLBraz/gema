import 'package:isar/isar.dart';

part 'daily_summary.g.dart';

@collection
class DailySummary {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime day;

  int totalKcal = 0;
  int totalProtein = 0;
  int totalCarb = 0;
  int totalFat = 0;
  int totalWaterMl = 0;
  int kcalTarget = 0;
  int deficit = 0;
  int mealsLogged = 0;
  int xpEarned = 0;
  bool isCheat = false;
}
