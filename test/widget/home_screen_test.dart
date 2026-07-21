import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gema/features/gamification/providers/xp_provider.dart';
import 'package:gema/features/goals/providers/goal_provider.dart';
import 'package:gema/features/home/home_screen.dart';
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';
import 'package:gema/features/meals/providers/recurring_meal_suggestions_provider.dart';
import 'package:gema/features/meals/widgets/recurring_meal_suggestions.dart';
import 'package:gema/features/water/providers/water_provider.dart';

class _FakeMealQueueNotifier extends MealQueueNotifier {
  @override
  Future<List<Meal>> build() async => [];
}

class _FakeTodayWaterMl extends TodayWaterMl {
  @override
  Future<int> build() async => 0;
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required List<MealSuggestion> suggestions,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activeGoalProvider.overrideWith((ref) async => null),
        todayMealsProvider.overrideWith((ref) => Stream.value(<Meal>[])),
        todayWaterMlProvider.overrideWith(() => _FakeTodayWaterMl()),
        xpLevelProvider.overrideWith((ref) async => 0),
        mealQueueNotifierProvider.overrideWith(() => _FakeMealQueueNotifier()),
        recurringMealSuggestionsProvider.overrideWith(
          (ref) async => suggestions,
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Quick Add sheet shows recurring meal suggestions', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      suggestions: [
        MealSuggestion(
          mealId: 1,
          displayText: 'café com leite e pão',
          emoji: '☕',
          capturedAt: DateTime.now(),
        ),
      ],
    );

    await tester.tap(find.text('⚡ Quick Add'));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringMealSuggestions), findsOneWidget);
    expect(find.textContaining('café com leite e pão'), findsOneWidget);
  });

  testWidgets('Quick Add sheet shows nothing extra when there are no suggestions', (
    tester,
  ) async {
    await _pumpHome(tester, suggestions: const []);

    await tester.tap(find.text('⚡ Quick Add'));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringMealSuggestions), findsOneWidget);
    expect(find.text('Refeições recentes parecidas'), findsNothing);
  });
}
