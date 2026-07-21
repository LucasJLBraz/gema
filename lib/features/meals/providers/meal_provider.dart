import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/utils/text_normalization.dart';
import '../models/meal.dart';

part 'meal_provider.g.dart';

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _tomorrow() {
  final t = _today();
  return DateTime(t.year, t.month, t.day + 1);
}

@riverpod
Stream<List<Meal>> todayMeals(TodayMealsRef ref) {
  final today = _today();
  final tomorrow = _tomorrow();
  return isar.meals
      .filter()
      .capturedAtBetween(today, tomorrow)
      .not()
      .statusEqualTo(MealStatus.error)
      .sortByCapturedAt()
      .watch(fireImmediately: true);
}

@riverpod
Stream<List<Meal>> mealsForDay(MealsForDayRef ref, DateTime day) {
  final start = DateTime(day.year, day.month, day.day);
  final end = DateTime(day.year, day.month, day.day + 1);
  return isar.meals
      .filter()
      .capturedAtBetween(start, end)
      .not()
      .statusEqualTo(MealStatus.error)
      .sortByCapturedAt()
      .watch(fireImmediately: true);
}

@riverpod
Future<Meal?> mealById(MealByIdRef ref, int id) async {
  return isar.meals.get(id);
}

@riverpod
class MealQueueNotifier extends _$MealQueueNotifier {
  @override
  Future<List<Meal>> build() async {
    return isar.meals.filter().statusEqualTo(MealStatus.queued).findAll();
  }

  Future<int> createMeal({
    required MealSource source,
    String? photoPath,
    String userNote = '',
    int kcalPoint = 0,
    int proteinPoint = 0,
    int carbPoint = 0,
    int fatPoint = 0,
  }) async {
    final now = DateTime.now();
    final status = source == MealSource.quickAdd || source == MealSource.manual
        ? MealStatus.provisional
        : MealStatus.queued;

    final meal = Meal()
      ..capturedAt = now
      ..photoPath = photoPath
      ..userNote = userNote
      ..source = source
      ..status = status
      ..kcalPoint = kcalPoint
      ..kcalMin = (kcalPoint * 0.8).round()
      ..kcalMax = (kcalPoint * 1.4).round()
      ..proteinPoint = proteinPoint
      ..proteinMin = (proteinPoint * 0.8).round()
      ..proteinMax = (proteinPoint * 1.4).round()
      ..carbPoint = carbPoint
      ..carbMin = (carbPoint * 0.8).round()
      ..carbMax = (carbPoint * 1.4).round()
      ..fatPoint = fatPoint
      ..fatMin = (fatPoint * 0.8).round()
      ..fatMax = (fatPoint * 1.4).round()
      ..createdAt = now
      ..updatedAt = now;

    await isar.writeTxn(() async {
      await isar.meals.put(meal);
    });
    ref.invalidateSelf();
    return meal.id;
  }

  Future<void> applyGeminiResult(
    int mealId, {
    required int kcalMin,
    required int kcalMax,
    required int kcalPoint,
    required int proteinMin,
    required int proteinMax,
    required int proteinPoint,
    required int carbMin,
    required int carbMax,
    required int carbPoint,
    required int fatMin,
    required int fatMax,
    required int fatPoint,
    required String aiConfidence,
    required String aiRawJson,
    required String aiEmoji,
    required String mealName,
    required String mealSummary,
    required List<Map<String, dynamic>> components,
  }) async {
    final meal = await isar.meals.get(mealId);
    if (meal == null) return;

    await isar.writeTxn(() async {
      meal
        ..kcalMin = kcalMin
        ..kcalMax = kcalMax
        ..kcalPoint = kcalPoint
        ..proteinMin = proteinMin
        ..proteinMax = proteinMax
        ..proteinPoint = proteinPoint
        ..carbMin = carbMin
        ..carbMax = carbMax
        ..carbPoint = carbPoint
        ..fatMin = fatMin
        ..fatMax = fatMax
        ..fatPoint = fatPoint
        ..aiConfidence = aiConfidence
        ..aiRawJson = aiRawJson
        ..aiEmoji = aiEmoji
        // AI-generated short name takes priority over the user's freeform context note
        ..userNote = mealName.isNotEmpty
            ? mealName
            : meal.userNote.isNotEmpty
            ? meal.userNote
            : mealSummary
        ..status = MealStatus.done
        ..updatedAt = DateTime.now();
      await isar.meals.put(meal);

      final compObjects = components.map((c) {
        return MealComponent()
          ..name = c['name'] as String? ?? ''
          ..normalizedTag = normalizeText(c['normalized_tag'] as String? ?? '')
          ..kcalPoint = (c['kcal_point'] as num?)?.toInt() ?? 0
          ..grupoAlimentar = c['grupo_alimentar'] as String? ?? 'outro'
          ..metodoPreparo = c['metodo_preparo'] as String? ?? 'desconhecido'
          ..estimatedMassG = (c['estimated_mass_g'] as num?)?.toInt();
      }).toList();

      await isar.mealComponents.putAll(compObjects);
      await meal.components.load();
      meal.components.addAll(compObjects);
      await meal.components.save();
    });
    ref.invalidateSelf();
  }

  Future<void> updateKcalPoint(int mealId, int newKcal) async {
    final meal = await isar.meals.get(mealId);
    if (meal == null) return;

    final ratio = meal.kcalPoint > 0 ? newKcal / meal.kcalPoint : 1.0;
    await isar.writeTxn(() async {
      meal
        ..kcalPoint = newKcal
        ..kcalMin = (newKcal * 0.82).round()
        ..kcalMax = (newKcal * 1.38).round()
        ..proteinPoint = (meal.proteinPoint * ratio).round()
        ..carbPoint = (meal.carbPoint * ratio).round()
        ..fatPoint = (meal.fatPoint * ratio).round()
        ..userEditedKcal = true
        ..updatedAt = DateTime.now();
      await isar.meals.put(meal);
    });
    ref.invalidateSelf();
  }

  Future<void> deleteMeal(int mealId) async {
    final meal = await isar.meals.get(mealId);
    final photoPath = meal?.photoPath;
    await isar.writeTxn(() async {
      if (meal != null) {
        await meal.components.load();
        final componentIds = meal.components
            .map((component) => component.id)
            .toList();
        if (componentIds.isNotEmpty) {
          await isar.mealComponents.deleteAll(componentIds);
        }
      }
      await isar.meals.delete(mealId);
    });
    if (photoPath != null) {
      try {
        final photoFile = File(photoPath);
        if (await photoFile.exists()) {
          await photoFile.delete();
        }
      } catch (e) {
        debugPrint('Failed to delete photo file: $e');
      }
    }
    ref.invalidateSelf();
  }

  Future<int> duplicateMeal(int originalMealId) async {
    final original = await isar.meals.get(originalMealId);
    if (original == null) {
      throw ArgumentError('Meal $originalMealId not found');
    }
    await original.components.load();

    final now = DateTime.now();
    final duplicate = Meal()
      ..capturedAt = now
      ..userNote = original.userNote
      ..source = MealSource.quickAdd
      ..status = MealStatus.done
      ..kcalMin = original.kcalMin
      ..kcalMax = original.kcalMax
      ..kcalPoint = original.kcalPoint
      ..carbMin = original.carbMin
      ..carbMax = original.carbMax
      ..carbPoint = original.carbPoint
      ..proteinMin = original.proteinMin
      ..proteinMax = original.proteinMax
      ..proteinPoint = original.proteinPoint
      ..fatMin = original.fatMin
      ..fatMax = original.fatMax
      ..fatPoint = original.fatPoint
      ..aiConfidence = original.aiConfidence
      ..aiEmoji = original.aiEmoji
      ..retryCount = 0
      ..userEditedKcal = false
      ..createdAt = now
      ..updatedAt = now;

    final newComponents = original.components
        .map(
          (c) => MealComponent()
            ..name = c.name
            ..normalizedTag = c.normalizedTag
            ..kcalPoint = c.kcalPoint
            ..grupoAlimentar = c.grupoAlimentar
            ..metodoPreparo = c.metodoPreparo
            ..estimatedMassG = c.estimatedMassG,
        )
        .toList();

    await isar.writeTxn(() async {
      await isar.meals.put(duplicate);
      if (newComponents.isNotEmpty) {
        await isar.mealComponents.putAll(newComponents);
        await duplicate.components.load();
        duplicate.components.addAll(newComponents);
        await duplicate.components.save();
      }
    });
    ref.invalidateSelf();
    return duplicate.id;
  }
}
