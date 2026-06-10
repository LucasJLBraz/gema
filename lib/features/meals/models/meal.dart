import 'package:isar/isar.dart';

part 'meal.g.dart';

enum MealStatus { provisional, queued, processing, done, error }

enum MealSource { aiPhoto, barcode, quickAdd, manual }

@collection
class Meal {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime capturedAt;

  String? photoPath;
  DateTime? photoDeletedAt;
  String userNote = '';

  @Enumerated(EnumType.name)
  late MealSource source;

  @Enumerated(EnumType.name)
  late MealStatus status;

  int kcalMin = 0;
  int kcalMax = 0;
  int kcalPoint = 0;

  int carbMin = 0;
  int carbMax = 0;
  int carbPoint = 0;

  int proteinMin = 0;
  int proteinMax = 0;
  int proteinPoint = 0;

  int fatMin = 0;
  int fatMax = 0;
  int fatPoint = 0;

  String? aiConfidence;
  String? aiRawJson;
  int retryCount = 0;

  // Tracks if user manually edited kcalPoint (for reconciliation logic in §9.2)
  bool userEditedKcal = false;

  late DateTime createdAt;
  late DateTime updatedAt;

  // Back-link to components
  @Backlink(to: 'meal')
  final components = IsarLinks<MealComponent>();
}

@collection
class MealComponent {
  Id id = Isar.autoIncrement;

  final meal = IsarLink<Meal>();

  late String name;
  late String normalizedTag;
  int kcalPoint = 0;
  late String grupoAlimentar;
  late String metodoPreparo;
  int? estimatedMassG;
}
