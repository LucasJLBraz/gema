import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:gema/core/db/database.dart' as db;
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // CI runners don't have libisar.so at the repo root; download the core
    // binary there. Locally the repo-root copy is found first, no download.
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gema_meal_provider_test_');
    db.isar = await Isar.open([
      MealSchema,
      MealComponentSchema,
    ], directory: tempDir.path);
  });

  tearDown(() async {
    await db.isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test(
    'deleteMeal removes the Isar record and the associated photo file',
    () async {
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
    },
  );

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

  test('duplicateMeal copies fields, resets state, and creates new components', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final photoFile = File('${tempDir.path}/original_meal.jpg')
      ..writeAsStringSync('fake-jpeg-bytes');

    final originalId = await notifier.createMeal(
      source: MealSource.aiPhoto,
      photoPath: photoFile.path,
      userNote: 'café com leite e pão',
      kcalPoint: 400,
      proteinPoint: 15,
      carbPoint: 50,
      fatPoint: 10,
    );

    final original = (await db.isar.meals.get(originalId))!;
    await db.isar.writeTxn(() async {
      original
        ..status = MealStatus.done
        ..retryCount = 2
        ..userEditedKcal = true
        ..aiConfidence = 'alta'
        ..aiEmoji = '☕';
      await db.isar.meals.put(original);

      final component = MealComponent()
        ..name = 'Pão'
        ..normalizedTag = 'pao'
        ..kcalPoint = 150
        ..grupoAlimentar = 'carboidrato'
        ..metodoPreparo = 'assado'
        ..estimatedMassG = 60;
      await db.isar.mealComponents.put(component);
      await original.components.load();
      original.components.add(component);
      await original.components.save();
    });

    final newMealId = await notifier.duplicateMeal(originalId);
    final duplicated = (await db.isar.meals.get(newMealId))!;

    expect(duplicated.id, isNot(originalId));
    expect(duplicated.userNote, 'café com leite e pão');
    expect(duplicated.kcalPoint, 400);
    expect(duplicated.proteinPoint, 15);
    expect(duplicated.carbPoint, 50);
    expect(duplicated.fatPoint, 10);
    expect(duplicated.status, MealStatus.done);
    expect(duplicated.source, MealSource.quickAdd);
    expect(duplicated.retryCount, 0);
    expect(duplicated.userEditedKcal, isFalse);
    expect(duplicated.photoPath, isNull);
    expect(duplicated.photoDeletedAt, isNull);

    await duplicated.components.load();
    expect(duplicated.components.length, 1);
    expect(duplicated.components.first.name, 'Pão');
    expect(duplicated.components.first.grupoAlimentar, 'carboidrato');

    await original.components.load();
    expect(
      duplicated.components.first.id,
      isNot(original.components.first.id),
    );

    // Original photo must survive untouched.
    expect(await photoFile.exists(), isTrue);
  });

  test('duplicateMeal never copies a photo even when the original has one', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final originalId = await notifier.createMeal(
      source: MealSource.manual,
      userNote: 'refeição sem foto',
      kcalPoint: 200,
    );

    final newMealId = await notifier.duplicateMeal(originalId);
    final duplicated = (await db.isar.meals.get(newMealId))!;

    expect(duplicated.photoPath, isNull);
  });
}
