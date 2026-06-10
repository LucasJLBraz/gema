import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/gamification/models/xp_event.dart';
import '../../features/goals/models/goal.dart';
import '../../features/meals/models/meal.dart';
import '../../features/products/models/product.dart';
import '../../features/summary/models/daily_summary.dart';
import '../../features/water/models/water_log.dart';
import '../../features/weight/models/weight_entry.dart';

late Isar isar;

Future<void> initDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([
    MealSchema,
    MealComponentSchema,
    WeightEntrySchema,
    GoalSchema,
    DailySummarySchema,
    XpEventSchema,
    ProductSchema,
    WaterLogSchema,
  ], directory: dir.path);
}
