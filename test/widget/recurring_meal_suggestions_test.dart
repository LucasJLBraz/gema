import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';
import 'package:gema/features/meals/providers/recurring_meal_suggestions_provider.dart';
import 'package:gema/features/meals/widgets/recurring_meal_suggestions.dart';

class _FakeMealQueueNotifier extends MealQueueNotifier {
  int? duplicatedMealId;
  int? deletedMealId;
  final int nextDuplicateId;

  _FakeMealQueueNotifier({this.nextDuplicateId = 999});

  @override
  Future<List<Meal>> build() async => [];

  @override
  Future<int> duplicateMeal(int originalMealId) async {
    duplicatedMealId = originalMealId;
    return nextDuplicateId;
  }

  @override
  Future<void> deleteMeal(int mealId) async {
    deletedMealId = mealId;
  }
}

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required List<MealSuggestion> suggestions,
    required _FakeMealQueueNotifier fakeNotifier,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recurringMealSuggestionsProvider.overrideWith((ref) async => suggestions),
          mealQueueNotifierProvider.overrideWith(() => fakeNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(body: RecurringMealSuggestions()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders nothing when there are no suggestions', (tester) async {
    await pumpWidget(
      tester,
      suggestions: const [],
      fakeNotifier: _FakeMealQueueNotifier(),
    );

    expect(find.byType(RecurringMealSuggestions), findsOneWidget);
    expect(find.text('Refeições recentes parecidas'), findsNothing);
  });

  testWidgets('renders up to 3 suggestion cards', (tester) async {
    final now = DateTime.now();
    await pumpWidget(
      tester,
      suggestions: [
        MealSuggestion(
          mealId: 1,
          displayText: 'café com leite e pão',
          emoji: '☕',
          capturedAt: now,
        ),
        MealSuggestion(
          mealId: 2,
          displayText: 'salada de frutas',
          emoji: null,
          capturedAt: now,
        ),
      ],
      fakeNotifier: _FakeMealQueueNotifier(),
    );

    expect(find.text('Refeições recentes parecidas'), findsOneWidget);
    expect(find.textContaining('café com leite e pão'), findsOneWidget);
    expect(find.textContaining('salada de frutas'), findsOneWidget);
  });

  testWidgets('tapping a card duplicates the meal and shows undo snackbar', (
    tester,
  ) async {
    final fakeNotifier = _FakeMealQueueNotifier(nextDuplicateId: 42);
    await pumpWidget(
      tester,
      suggestions: [
        MealSuggestion(
          mealId: 7,
          displayText: 'café com leite e pão',
          emoji: '☕',
          capturedAt: DateTime.now(),
        ),
      ],
      fakeNotifier: fakeNotifier,
    );

    await tester.tap(find.textContaining('café com leite e pão'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(fakeNotifier.duplicatedMealId, 7);
    expect(find.text('Refeição duplicada'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pump();

    expect(fakeNotifier.deletedMealId, 42);
  });
}
