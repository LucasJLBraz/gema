import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/utils/text_normalization.dart';
import '../models/meal.dart';

part 'recurring_meal_suggestions_provider.g.dart';

class MealSuggestion {
  const MealSuggestion({
    required this.mealId,
    required this.displayText,
    required this.emoji,
    required this.capturedAt,
  });

  final int mealId;
  final String displayText;
  final String? emoji;
  final DateTime capturedAt;
}

const _lookbackWindow = Duration(days: 14);
const _timeOfDayWindowMinutes = 90;
const _maxSuggestions = 3;

@riverpod
Future<List<MealSuggestion>> recurringMealSuggestions(
  RecurringMealSuggestionsRef ref,
) async {
  final now = DateTime.now();
  final windowStart = now.subtract(_lookbackWindow);

  final candidates = await isar.meals
      .filter()
      .statusEqualTo(MealStatus.done)
      .capturedAtGreaterThan(windowStart)
      .findAll();

  final withinTimeOfDay = candidates.where(
    (meal) =>
        _timeOfDayDiffMinutes(meal.capturedAt, now) <= _timeOfDayWindowMinutes,
  );

  final withText = <(Meal, String)>[];
  for (final meal in withinTimeOfDay) {
    final text = await _displayTextFor(meal);
    if (text.isNotEmpty) withText.add((meal, text));
  }

  final representatives = mostRecentPerSimilarityGroup<(Meal, String)>(
    items: withText,
    textOf: (pair) => pair.$2,
    timeOf: (pair) => pair.$1.capturedAt,
  );

  return representatives
      .take(_maxSuggestions)
      .map(
        (pair) => MealSuggestion(
          mealId: pair.$1.id,
          displayText: pair.$2,
          emoji: pair.$1.aiEmoji,
          capturedAt: pair.$1.capturedAt,
        ),
      )
      .toList();
}

int _timeOfDayDiffMinutes(DateTime a, DateTime b) {
  final aMinutes = a.hour * 60 + a.minute;
  final bMinutes = b.hour * 60 + b.minute;
  final diff = (aMinutes - bMinutes).abs();
  return diff > 720 ? 1440 - diff : diff;
}

Future<String> _displayTextFor(Meal meal) async {
  if (meal.userNote.isNotEmpty) return meal.userNote;
  await meal.components.load();
  return meal.components.map((c) => c.name).join(', ');
}
