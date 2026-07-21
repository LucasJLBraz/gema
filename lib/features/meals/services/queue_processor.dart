import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../../core/db/database.dart';
import '../../../core/gemini/api_key_storage.dart' as gemini;
import '../../../core/gemini/gemini_service.dart' as gemini;
import '../../../core/utils/text_normalization.dart';
import '../models/meal.dart';

/// Singleton that watches Isar for queued meals and processes them
/// automatically in the foreground. Start once from main().
class QueueProcessor {
  QueueProcessor._();
  static final instance = QueueProcessor._();

  bool _running = false;
  StreamSubscription<List<Meal>>? _sub;

  /// Begin watching for queued meals. Safe to call multiple times.
  void start() {
    _sub ??= isar.meals
        .filter()
        .statusEqualTo(MealStatus.queued)
        .watch(fireImmediately: true)
        .listen((queued) {
          if (queued.isNotEmpty && !_running) {
            _processAll();
          }
        });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> _processAll() async {
    if (_running) return;
    _running = true;
    debugPrint('[QueueProcessor] starting run');

    try {
      while (true) {
        final queued = await isar.meals
            .filter()
            .statusEqualTo(MealStatus.queued)
            .sortByCreatedAt()
            .findAll();
        if (queued.isEmpty) break;

        final meal = queued.first;

        // Meals with neither photo nor note cannot be analysed → mark error
        if (meal.photoPath == null && meal.userNote.isEmpty) {
          await isar.writeTxn(() async {
            meal.status = MealStatus.error;
            await isar.meals.put(meal);
          });
          continue;
        }

        // Mark as processing so the UI reflects it immediately
        await isar.writeTxn(() async {
          meal.status = MealStatus.processing;
          await isar.meals.put(meal);
        });

        try {
          debugPrint('[QueueProcessor] analysing meal ${meal.id}');
          final apiKey = await gemini.loadApiKey();
          final result = await gemini.estimateMeal(
            apiKey: apiKey,
            photoPath: meal.photoPath,
            userNote: meal.userNote,
            retryCount: meal.retryCount,
          );

          await _applyResult(meal, result);

          // Spec: ≥ 4–6 s between Gemini calls
          await Future<void>.delayed(const Duration(seconds: 5));
        } on gemini.GeminiRateLimitException catch (e) {
          debugPrint(
            '[QueueProcessor] rate-limited, waiting ${e.retryAfterSeconds}s',
          );
          // Reset to queued with bumped retry count, then wait
          await isar.writeTxn(() async {
            meal
              ..status = MealStatus.queued
              ..retryCount = meal.retryCount + 1
              ..updatedAt = DateTime.now();
            await isar.meals.put(meal);
          });
          await Future<void>.delayed(Duration(seconds: e.retryAfterSeconds));
        } catch (e) {
          debugPrint('[QueueProcessor] error for meal ${meal.id}: $e');
          await isar.writeTxn(() async {
            meal
              ..status = MealStatus.error
              ..updatedAt = DateTime.now();
            await isar.meals.put(meal);
          });
        }
      }
    } finally {
      _running = false;
      debugPrint('[QueueProcessor] run complete');
    }
  }

  Future<void> _applyResult(Meal meal, gemini.GeminiResult result) async {
    await isar.writeTxn(() async {
      meal
        ..kcalMin = result.kcalMin
        ..kcalMax = result.kcalMax
        ..kcalPoint = result.kcalPoint
        ..proteinMin = result.proteinMin
        ..proteinMax = result.proteinMax
        ..proteinPoint = result.proteinPoint
        ..carbMin = result.carbMin
        ..carbMax = result.carbMax
        ..carbPoint = result.carbPoint
        ..fatMin = result.fatMin
        ..fatMax = result.fatMax
        ..fatPoint = result.fatPoint
        ..aiConfidence = result.aiConfidence
        ..aiRawJson = result.rawJson
        ..aiEmoji = result.mealEmoji
        ..userNote = result.mealName.isNotEmpty
            ? result.mealName
            : meal.userNote.isNotEmpty
            ? meal.userNote
            : result.mealSummary
        ..status = MealStatus.done
        ..updatedAt = DateTime.now();
      await isar.meals.put(meal);

      final compObjects = result.components.map((c) {
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
  }
}
