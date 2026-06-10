import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../meals/models/meal.dart';

class MealListTile extends StatelessWidget {
  const MealListTile({super.key, required this.meal, required this.isDark});

  final Meal meal;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final surface = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;
    final outlineVar = isDark
        ? GemaColors.darkOutlineVar
        : GemaColors.lightOutlineVar;
    final time = DateFormat('HH:mm').format(meal.capturedAt);

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
        children: [
          Text(_icon(), style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meal.userNote.isNotEmpty ? meal.userNote : _sourceLabel(),
                      style: GemaTextStyles.label.copyWith(color: text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      meal.status == MealStatus.done ||
                              meal.status == MealStatus.provisional
                          ? '~${meal.kcalPoint} kcal'
                          : '---',
                      style: GemaTextStyles.label.copyWith(color: text),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: GemaTextStyles.dataMono.copyWith(
                        color: textSub,
                        fontSize: 11,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge,
                          style: GemaTextStyles.micro.copyWith(
                            color: badgeText,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                    if (meal.aiConfidence == 'high') ...[
                      const SizedBox(width: 8),
                      Text(
                        '● Alta confiança',
                        style: GemaTextStyles.micro.copyWith(
                          color: isDark
                              ? GemaColors.darkSuccess
                              : GemaColors.lightSuccess,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _icon() {
    return switch (meal.source) {
      MealSource.aiPhoto => '📷',
      MealSource.barcode => '📦',
      MealSource.quickAdd => '⚡',
      MealSource.manual => '✏️',
    };
  }

  String _sourceLabel() {
    return switch (meal.source) {
      MealSource.aiPhoto => 'Refeição',
      MealSource.barcode => 'Produto escaneado',
      MealSource.quickAdd => 'Quick Add',
      MealSource.manual => 'Manual',
    };
  }

  (String?, Color, Color) _badge(bool dark) {
    final primaryCont = dark
        ? GemaColors.darkPrimaryCont
        : GemaColors.lightPrimaryCont;
    final onPrimCont = dark
        ? GemaColors.darkOnPrimCont
        : GemaColors.lightOnPrimCont;
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
      MealStatus.done =>
        meal.source == MealSource.barcode
            ? ('Barcode', primaryCont, onPrimCont)
            : (null, Colors.transparent, Colors.transparent),
    };
  }
}
