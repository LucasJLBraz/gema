import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database.dart';
import '../../features/meals/models/meal.dart';
import '../../features/weight/models/weight_entry.dart';
import '../../features/summary/models/daily_summary.dart';

class DataExportService {
  Future<void> exportCsv(BuildContext context) async {
    final meals = await isar.meals
        .filter()
        .statusEqualTo(MealStatus.done)
        .or()
        .statusEqualTo(MealStatus.provisional)
        .sortByCapturedAt()
        .findAll();

    final weights = await isar.weightEntrys
        .where()
        .sortByMeasuredOn()
        .findAll();

    final mealscsv = StringBuffer(
      'data,hora,fonte,kcal,proteina_g,carb_g,gordura_g,nota\n',
    );
    for (final m in meals) {
      mealscsv.writeln(
        '${_date(m.capturedAt)},${_time(m.capturedAt)},${m.source.name},'
        '${m.kcalPoint},${m.proteinPoint},${m.carbPoint},${m.fatPoint},'
        '"${m.userNote.replaceAll('"', '""')}"',
      );
    }

    final weightcsv = StringBuffer('data,peso_kg,gordura_corporal_pct\n');
    for (final w in weights) {
      weightcsv.writeln(
        '${_date(w.measuredOn)},${w.weightKg},${w.bodyFatPct ?? ""}',
      );
    }

    final dir = await getTemporaryDirectory();
    final tag = _dateTag();
    final mealsFile = File('${dir.path}/gema_refeicoes_$tag.csv')
      ..writeAsStringSync(mealscsv.toString());
    final weightFile = File('${dir.path}/gema_peso_$tag.csv')
      ..writeAsStringSync(weightcsv.toString());

    await Share.shareXFiles([
      XFile(mealsFile.path),
      XFile(weightFile.path),
    ], subject: 'GEMA — Export $tag');
  }

  Future<void> exportJson(BuildContext context) async {
    final meals = await isar.meals.where().sortByCapturedAt().findAll();

    final weights = await isar.weightEntrys
        .where()
        .sortByMeasuredOn()
        .findAll();

    final summaries = await isar.dailySummarys.where().sortByDay().findAll();

    final payload = {
      'exported_at': DateTime.now().toIso8601String(),
      'version': 1,
      'meals': meals.map(_mealToMap).toList(),
      'weights': weights.map(_weightToMap).toList(),
      'daily_summaries': summaries.map(_summaryToMap).toList(),
    };

    final dir = await getTemporaryDirectory();
    final tag = _dateTag();
    final file = File('${dir.path}/gema_export_$tag.json')
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'GEMA — Export JSON $tag');
  }

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _dateTag() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _mealToMap(Meal m) => {
    'id': m.id,
    'captured_at': m.capturedAt.toIso8601String(),
    'source': m.source.name,
    'status': m.status.name,
    'kcal': m.kcalPoint,
    'protein_g': m.proteinPoint,
    'carb_g': m.carbPoint,
    'fat_g': m.fatPoint,
    'note': m.userNote,
  };

  Map<String, dynamic> _weightToMap(WeightEntry w) => {
    'measured_on': w.measuredOn.toIso8601String(),
    'weight_kg': w.weightKg,
    'body_fat_pct': w.bodyFatPct,
  };

  Map<String, dynamic> _summaryToMap(DailySummary s) => {
    'day': s.day.toIso8601String(),
    'kcal_consumed': s.totalKcal,
    'kcal_target': s.kcalTarget,
    'protein_g': s.totalProtein,
    'carb_g': s.totalCarb,
    'fat_g': s.totalFat,
    'xp_earned': s.xpEarned,
    'is_cheat': s.isCheat,
  };
}
