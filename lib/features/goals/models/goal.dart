import 'package:isar/isar.dart';

part 'goal.g.dart';

enum GoalType { cut, maintain, bulk }

@collection
class Goal {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime effectiveFrom;

  @Enumerated(EnumType.name)
  late GoalType goalType;

  double? targetWeight;
  DateTime? targetDate;

  // Only meaningful during bootstrap (days 0–20); null after empirical TDEE kicks in
  double? priorActivityFactor;

  late double bmr;
  late double tdee;
  late int kcalTarget;

  int proteinTargetG = 0;
  int carbTargetG = 0;
  int fatTargetG = 0;

  // Physical data (from onboarding)
  late double heightCm;
  late double weightKg;
  late int ageYears;
  late bool isMale;
  double? bodyFatPct;
}
