import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:gema/core/db/database.dart' as db;
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/recurring_meal_suggestions_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'gema_recurring_suggestions_test_',
    );
    db.isar = await Isar.open([
      MealSchema,
      MealComponentSchema,
    ], directory: tempDir.path);
  });

  tearDown(() async {
    await db.isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<int> insertDoneMeal({
    required DateTime capturedAt,
    String userNote = '',
    String? aiEmoji,
    List<String> componentNames = const [],
  }) async {
    final meal = Meal()
      ..capturedAt = capturedAt
      ..userNote = userNote
      ..source = MealSource.aiPhoto
      ..status = MealStatus.done
      ..aiEmoji = aiEmoji
      ..createdAt = capturedAt
      ..updatedAt = capturedAt;

    await db.isar.writeTxn(() async {
      await db.isar.meals.put(meal);
      if (componentNames.isNotEmpty) {
        final components = componentNames
            .map(
              (name) => MealComponent()
                ..name = name
                ..normalizedTag = name.toLowerCase()
                ..grupoAlimentar = 'outro'
                ..metodoPreparo = 'desconhecido',
            )
            .toList();
        await db.isar.mealComponents.putAll(components);
        await meal.components.load();
        meal.components.addAll(components);
        await meal.components.save();
      }
    });
    return meal.id;
  }

  test(
    'returns candidates within the 14-day / ±90min window, grouped by similarity',
    () async {
      final now = DateTime.now();

      // Same breakfast, 3 different days, within the time window -> one group.
      await insertDoneMeal(
        capturedAt: now.subtract(const Duration(days: 5)),
        userNote: 'café com leite e pão',
      );
      await insertDoneMeal(
        capturedAt: now.subtract(const Duration(days: 2)),
        userNote: 'café com leite e pão',
      );
      final mostRecentId = await insertDoneMeal(
        capturedAt: now.subtract(const Duration(minutes: 30)),
        userNote: 'café com leite e pão',
      );

      // Unrelated meal, also within the time window -> separate group.
      final saladId = await insertDoneMeal(
        capturedAt: now.subtract(const Duration(days: 1)),
        userNote: 'salada de frutas',
      );

      // Outside the 14-day window -> excluded.
      await insertDoneMeal(
        capturedAt: now.subtract(const Duration(days: 20)),
        userNote: 'café com leite e pão',
      );

      // Outside the ±90min time-of-day window -> excluded. A 6-hour offset
      // from `now`'s time-of-day is always >90min away in either direction,
      // regardless of what time the suite happens to run.
      final outsideWindowTimeOfDay = now.add(const Duration(hours: 6));
      await insertDoneMeal(
        capturedAt: DateTime(
          now.year,
          now.month,
          now.day,
          outsideWindowTimeOfDay.hour,
          outsideWindowTimeOfDay.minute,
        ),
        userNote: 'jantar tardio',
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        recurringMealSuggestionsProvider.future,
      );

      expect(result.length, 2);
      expect(result[0].mealId, mostRecentId);
      expect(result[0].displayText, 'café com leite e pão');
      expect(result[1].mealId, saladId);
    },
  );

  test('falls back to component names when userNote is empty', () async {
    final now = DateTime.now();
    final mealId = await insertDoneMeal(
      capturedAt: now.subtract(const Duration(hours: 1)),
      componentNames: ['Ovo mexido', 'Torrada'],
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      recurringMealSuggestionsProvider.future,
    );

    expect(result.single.mealId, mealId);
    expect(result.single.displayText, 'Ovo mexido, Torrada');
  });

  test('returns at most 3 candidates', () async {
    final now = DateTime.now();
    // Deliberately unrelated dishes (near-zero Jaccard overlap) so each
    // forms its own similarity group instead of collapsing into one.
    const distinctNotes = [
      'pizza de calabresa com azeitona',
      'sopa de legumes com frango',
      'macarrão ao alho e óleo',
      'salada caesar com frango grelhado',
      'tapioca com queijo coalho',
    ];
    for (var i = 0; i < distinctNotes.length; i++) {
      await insertDoneMeal(
        capturedAt: now.subtract(Duration(days: i + 1)),
        userNote: distinctNotes[i],
      );
    }

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      recurringMealSuggestionsProvider.future,
    );

    expect(result.length, 3);
  });
}
