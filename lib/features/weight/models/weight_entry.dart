import 'package:isar/isar.dart';

part 'weight_entry.g.dart';

@collection
class WeightEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime measuredOn;

  late double weightKg;
  double? bodyFatPct;
  String? note;
}
