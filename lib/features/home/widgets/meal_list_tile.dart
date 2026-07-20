import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../meals/models/meal.dart';
import '../../meals/providers/meal_provider.dart';
import '../../meals/widgets/meal_detail_sheet.dart';

class MealListTile extends ConsumerWidget {
  const MealListTile({super.key, required this.meal, required this.isDark});

  final Meal meal;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errCont = isDark
        ? GemaColors.darkErrorCont
        : GemaColors.lightErrorCont;

    return Dismissible(
      key: ValueKey(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: errCont,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.delete_outline,
          color: isDark ? GemaColors.darkOnErrCont : GemaColors.lightOnErrCont,
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Excluir refeição?'),
            content: const Text('Esta ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          ref.read(mealQueueNotifierProvider.notifier).deleteMeal(meal.id),
      child: GestureDetector(
        onTap: () => showMealDetail(context, meal),
        child: _TileContent(meal: meal, isDark: isDark),
      ),
    );
  }
}

class _TileContent extends StatelessWidget {
  const _TileContent({required this.meal, required this.isDark});
  final Meal meal;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final textDis = isDark ? GemaColors.darkTextDis : GemaColors.lightTextDis;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final surface = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;
    final outlineVar = isDark
        ? GemaColors.darkOutlineVar
        : GemaColors.lightOutlineVar;
    final primaryCont = isDark
        ? GemaColors.darkPrimaryCont
        : GemaColors.lightPrimaryCont;
    final onPrimCont = isDark
        ? GemaColors.darkOnPrimCont
        : GemaColors.lightOnPrimCont;

    final isDone = meal.status == MealStatus.done;
    final isAiMeal = meal.source == MealSource.aiPhoto;
    final showRange = isDone && isAiMeal && meal.kcalMax > meal.kcalMin;

    // Parse component names from aiRawJson
    final componentNames = _parseComponentNames(meal.aiRawJson);
    final componentsLine = componentNames.isNotEmpty
        ? componentNames.take(3).join(' · ')
        : null;

    final (badge, badgeColor, badgeText) = _badge(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: outlineVar) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(_emoji(), style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: name (bold) + kcal (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meal.userNote.isNotEmpty
                            ? meal.userNote
                            : _sourceLabel(),
                        style: GemaTextStyles.label.copyWith(
                          color: text,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (meal.kcalPoint > 0)
                      Text(
                        '${meal.kcalPoint} kcal',
                        style: GemaTextStyles.label.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),

                // Line 2: component names or status badge
                if (componentsLine != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    componentsLine,
                    style: GemaTextStyles.caption.copyWith(color: textSub),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else if (badge != null) ...[
                  const SizedBox(height: 3),
                  _StatusBadge(
                    label: badge,
                    bgColor: badgeColor,
                    fgColor: badgeText,
                  ),
                ],

                // Line 3: range chip + macro pills (done AI meals only)
                if (isDone) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (showRange) ...[
                        _RangeChip(
                          min: meal.kcalMin,
                          max: meal.kcalMax,
                          bgColor: primaryCont,
                          fgColor: onPrimCont,
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (meal.proteinPoint > 0)
                        _MacroPill(
                          '${meal.proteinPoint}g P',
                          isDark
                              ? GemaColors.chartProteinDark
                              : GemaColors.chartProteinLight,
                          textDis,
                        ),
                      if (meal.carbPoint > 0) ...[
                        const SizedBox(width: 6),
                        _MacroPill(
                          '${meal.carbPoint}g C',
                          isDark
                              ? GemaColors.chartCarbsDark
                              : GemaColors.chartCarbsLight,
                          textDis,
                        ),
                      ],
                      if (meal.fatPoint > 0) ...[
                        const SizedBox(width: 6),
                        _MacroPill(
                          '${meal.fatPoint}g G',
                          isDark
                              ? GemaColors.chartFatDark
                              : GemaColors.chartFatLight,
                          textDis,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseComponentNames(String? rawJson) {
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final j = jsonDecode(rawJson) as Map<String, dynamic>;
      final components = j['components'] as List?;
      if (components == null) return [];
      return components
          .map((c) => (c as Map<String, dynamic>)['name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _emoji() {
    if (meal.aiEmoji != null && meal.aiEmoji!.isNotEmpty) return meal.aiEmoji!;
    return switch (meal.source) {
      MealSource.aiPhoto => '📷',
      MealSource.barcode => '📦',
      MealSource.quickAdd => '⚡',
      MealSource.manual => '✏️',
    };
  }

  String _sourceLabel() => switch (meal.source) {
    MealSource.aiPhoto => 'Refeição',
    MealSource.barcode => 'Produto escaneado',
    MealSource.quickAdd => 'Quick Add',
    MealSource.manual => 'Manual',
  };

  (String?, Color, Color) _badge(bool dark) {
    final secCont = dark
        ? GemaColors.darkSecondaryCont
        : GemaColors.lightSecondaryCont;
    final onSecCont = dark
        ? GemaColors.darkOnSecCont
        : GemaColors.lightOnSecCont;
    final surfVar = dark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final textSub = dark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final errCont = dark ? GemaColors.darkErrorCont : GemaColors.lightErrorCont;
    final onErrCont = dark
        ? GemaColors.darkOnErrCont
        : GemaColors.lightOnErrCont;

    return switch (meal.status) {
      MealStatus.provisional => ('Estimativa manual', secCont, onSecCont),
      MealStatus.queued => ('⏳ Na fila', surfVar, textSub),
      MealStatus.processing => ('⏳ Processando', surfVar, textSub),
      MealStatus.error => ('Falha ao processar', errCont, onErrCont),
      MealStatus.done => (null, Colors.transparent, Colors.transparent),
    };
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.min,
    required this.max,
    required this.bgColor,
    required this.fgColor,
  });
  final int min;
  final int max;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$min–$max kcal',
        style: GemaTextStyles.micro.copyWith(
          color: fgColor,
          letterSpacing: 0,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });
  final String label;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GemaTextStyles.micro.copyWith(color: fgColor, letterSpacing: 0),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill(this.label, this.color, this.bgColor);
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GemaTextStyles.micro.copyWith(color: color, letterSpacing: 0),
    );
  }
}
