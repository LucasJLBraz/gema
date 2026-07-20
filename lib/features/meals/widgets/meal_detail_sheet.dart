import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

/// Shows a bottom sheet with full meal details. Returns true if meal was deleted.
Future<bool?> showMealDetail(BuildContext context, Meal meal) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MealDetailSheet(meal: meal),
  );
}

class MealDetailSheet extends ConsumerWidget {
  const MealDetailSheet({super.key, required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final textDis = isDark ? GemaColors.darkTextDis : GemaColors.lightTextDis;
    final surfaceVar = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final errCont = isDark
        ? GemaColors.darkErrorCont
        : GemaColors.lightErrorCont;
    final onErrCont = isDark
        ? GemaColors.darkOnErrCont
        : GemaColors.lightOnErrCont;

    // Parse AI summary and components from stored JSON
    String? aiSummary;
    List<Map<String, dynamic>> components = [];
    if (meal.aiRawJson != null && meal.aiRawJson!.isNotEmpty) {
      try {
        final j = jsonDecode(meal.aiRawJson!) as Map<String, dynamic>;
        aiSummary = j['meal_summary'] as String?;
        components = List<Map<String, dynamic>>.from(
          (j['components'] as List? ?? []).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        );
      } catch (_) {}
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? GemaColors.darkOutlineVar
                  : GemaColors.lightOutlineVar,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                // Photo
                if (meal.photoPath != null &&
                    File(meal.photoPath!).existsSync())
                  GestureDetector(
                    onTap: () => _showFullPhoto(context, meal.photoPath!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(meal.photoPath!),
                        width: double.infinity,
                        fit: BoxFit.contain,
                        frameBuilder: (_, child, frame, _) => frame == null
                            ? const SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : child,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meal.userNote.isNotEmpty
                            ? meal.userNote
                            : (aiSummary ?? _sourceLabel(meal.source)),
                        style: GemaTextStyles.title.copyWith(color: text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(meal: meal, isDark: isDark),
                  ],
                ),

                // AI description (separate from user note)
                if (aiSummary != null &&
                    aiSummary.isNotEmpty &&
                    meal.userNote.isNotEmpty &&
                    aiSummary != meal.userNote) ...[
                  const SizedBox(height: 6),
                  Text(
                    '🤖 $aiSummary',
                    style: GemaTextStyles.body.copyWith(color: textSub),
                  ),
                ],

                const SizedBox(height: 16),

                // Macros row
                _MacroRow(meal: meal, isDark: isDark),

                const SizedBox(height: 16),

                // Components / tags
                if (components.isNotEmpty) ...[
                  Text(
                    'COMPONENTES IDENTIFICADOS',
                    style: GemaTextStyles.caption.copyWith(color: textSub),
                  ),
                  const SizedBox(height: 8),
                  ...components.map(
                    (c) => _ComponentTile(
                      c: c,
                      isDark: isDark,
                      surfaceVar: surfaceVar,
                      text: text,
                      textSub: textSub,
                      primary: primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (meal.status == MealStatus.done) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceVar,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Nenhum componente detalhado disponível.',
                      style: GemaTextStyles.body.copyWith(color: textDis),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Delete button
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: Icon(
                    Icons.delete_outline,
                    color: errCont == onErrCont
                        ? Colors.red
                        : (isDark
                              ? GemaColors.darkError
                              : GemaColors.lightError),
                  ),
                  label: Text(
                    'Excluir refeição',
                    style: TextStyle(
                      color: isDark
                          ? GemaColors.darkError
                          : GemaColors.lightError,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? GemaColors.darkError
                          : GemaColors.lightError,
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullPhoto(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: Center(child: InteractiveViewer(child: Image.file(File(path)))),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
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
    if (ok == true) {
      await ref.read(mealQueueNotifierProvider.notifier).deleteMeal(meal.id);
      if (context.mounted) Navigator.of(context).pop(true);
    }
  }

  String _sourceLabel(MealSource s) => switch (s) {
    MealSource.aiPhoto => 'Refeição',
    MealSource.barcode => 'Produto escaneado',
    MealSource.quickAdd => 'Quick Add',
    MealSource.manual => 'Manual',
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.meal, required this.isDark});
  final Meal meal;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (meal.status) {
      MealStatus.done => (
        meal.aiConfidence == 'high'
            ? '● Alta confiança'
            : meal.aiConfidence == 'medium'
            ? '● Confiança média'
            : '● Baixa confiança',
        Colors.transparent,
        meal.aiConfidence == 'high'
            ? (isDark ? GemaColors.darkSuccess : GemaColors.lightSuccess)
            : meal.aiConfidence == 'medium'
            ? (isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary)
            : (isDark ? GemaColors.darkError : GemaColors.lightError),
      ),
      MealStatus.queued || MealStatus.processing => (
        '⏳ Processando',
        isDark ? GemaColors.darkSurfaceVar : GemaColors.lightSurfaceVar,
        isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub,
      ),
      MealStatus.error => (
        'Falha',
        isDark ? GemaColors.darkErrorCont : GemaColors.lightErrorCont,
        isDark ? GemaColors.darkOnErrCont : GemaColors.lightOnErrCont,
      ),
      MealStatus.provisional => (
        'Estimativa manual',
        isDark ? GemaColors.darkSecondaryCont : GemaColors.lightSecondaryCont,
        isDark ? GemaColors.darkOnSecCont : GemaColors.lightOnSecCont,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GemaTextStyles.micro.copyWith(color: fg, letterSpacing: 0),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.meal, required this.isDark});
  final Meal meal;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surfaceVar = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final proteinColor = isDark
        ? GemaColors.chartProteinDark
        : GemaColors.chartProteinLight;
    final carbColor = isDark
        ? GemaColors.chartCarbsDark
        : GemaColors.chartCarbsLight;
    final fatColor = isDark
        ? GemaColors.chartFatDark
        : GemaColors.chartFatLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceVar,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _cell('${meal.kcalPoint}', 'kcal', primary, textSub),
          _cell('${meal.proteinPoint}g', 'prot', proteinColor, textSub),
          _cell('${meal.carbPoint}g', 'carb', carbColor, textSub),
          _cell('${meal.fatPoint}g', 'gord', fatColor, textSub),
          if (meal.kcalMin != meal.kcalMax)
            _cell(
              '${meal.kcalMin}–${meal.kcalMax}',
              'intervalo',
              text,
              textSub,
            ),
        ],
      ),
    );
  }

  Widget _cell(String value, String label, Color valueColor, Color labelColor) {
    return Column(
      children: [
        Text(value, style: GemaTextStyles.title.copyWith(color: valueColor)),
        Text(
          label,
          style: GemaTextStyles.micro.copyWith(
            color: labelColor,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ComponentTile extends StatelessWidget {
  const _ComponentTile({
    required this.c,
    required this.isDark,
    required this.surfaceVar,
    required this.text,
    required this.textSub,
    required this.primary,
  });
  final Map<String, dynamic> c;
  final bool isDark;
  final Color surfaceVar, text, textSub, primary;

  @override
  Widget build(BuildContext context) {
    final name = c['name'] as String? ?? '—';
    final massG = c['estimated_mass_g'] as int?;
    final kcal = c['kcal_point'] as int? ?? 0;
    final grupo = c['grupo_alimentar'] as String? ?? '';
    final preparo = c['metodo_preparo'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceVar,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(_groupEmoji(grupo), style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GemaTextStyles.label.copyWith(color: text)),
                const SizedBox(height: 2),
                Text(
                  [
                    if (massG != null) '~${massG}g',
                    if (grupo.isNotEmpty) _groupLabel(grupo),
                    if (preparo.isNotEmpty && preparo != 'desconhecido')
                      preparo,
                  ].join(' · '),
                  style: GemaTextStyles.micro.copyWith(
                    color: textSub,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '~$kcal kcal',
            style: GemaTextStyles.dataMono.copyWith(
              color: primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _groupEmoji(String g) => switch (g) {
    'proteina_animal' => '🥩',
    'proteina_vegetal' => '🌱',
    'laticinio' => '🥛',
    'graos_cereais' => '🌾',
    'tuberculo' => '🥔',
    'leguminosa' => '🫘',
    'vegetal' => '🥦',
    'fruta' => '🍎',
    'gordura_oleo' => '🫒',
    'doce_acucar' => '🍬',
    'bebida_calorica' => '🧃',
    'bebida_zero' => '💧',
    'molho_condimento' => '🧂',
    'ultraprocessado' => '📦',
    _ => '🍽️',
  };

  String _groupLabel(String g) => switch (g) {
    'proteina_animal' => 'proteína animal',
    'proteina_vegetal' => 'proteína vegetal',
    'laticinio' => 'laticínio',
    'graos_cereais' => 'grãos/cereais',
    'tuberculo' => 'tubérculo',
    'leguminosa' => 'leguminosa',
    'vegetal' => 'vegetal',
    'fruta' => 'fruta',
    'gordura_oleo' => 'gordura/óleo',
    'doce_acucar' => 'doce/açúcar',
    'bebida_calorica' => 'bebida calórica',
    'bebida_zero' => 'bebida zero',
    'molho_condimento' => 'molho/condimento',
    'ultraprocessado' => 'ultraprocessado',
    _ => 'outro',
  };
}
