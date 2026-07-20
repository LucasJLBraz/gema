import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:gema/core/db/database.dart' as db;
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gema_meal_provider_test_');
    db.isar = await Isar.open(
      [MealSchema, MealComponentSchema],
      directory: tempDir.path,
    );
  });

  tearDown(() async {
    await db.isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('deleteMeal removes the Isar record and the associated photo file', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final photoFile = File('${tempDir.path}/meal_test.jpg')
      ..writeAsStringSync('fake-jpeg-bytes');

    final mealId = await notifier.createMeal(
      source: MealSource.aiPhoto,
      photoPath: photoFile.path,
    );

    expect(await db.isar.meals.get(mealId), isNotNull);
    expect(await photoFile.exists(), isTrue);

    await notifier.deleteMeal(mealId);

    expect(await db.isar.meals.get(mealId), isNull);
    expect(await photoFile.exists(), isFalse);
  });

  test('deleteMeal does not throw when photoPath is null', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final mealId = await notifier.createMeal(
      source: MealSource.manual,
      photoPath: null,
    );

    await notifier.deleteMeal(mealId);

    expect(await db.isar.meals.get(mealId), isNull);
  });
}
