import 'package:isar/isar.dart';

part 'xp_event.g.dart';

enum XpEventType {
  allMealsLogged,
  proteinGoal,
  weightLogged,
  cheatPlanned,
  waterGoal,
}

@collection
class XpEvent {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime day;

  @Enumerated(EnumType.name)
  late XpEventType eventType;

  late int xpAmount;
  late DateTime createdAt;
}
