import 'package:isar/isar.dart';

part 'water_log.g.dart';

@collection
class WaterLog {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime day;

  late int ml;
  late DateTime loggedAt;
}
