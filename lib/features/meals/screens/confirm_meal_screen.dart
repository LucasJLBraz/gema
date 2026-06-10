import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/gemini/gemini_service.dart' as gemini;
import '../../../core/theme/app_theme.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

class ConfirmMealScreen extends ConsumerStatefulWidget {
  const ConfirmMealScreen({super.key, required this.mealId});
  final int mealId;

  @override
  ConsumerState<ConfirmMealScreen> createState() => _ConfirmMealScreenState();
}

class _ConfirmMealScreenState extends ConsumerState<ConfirmMealScreen> {
  bool _analyzing = false;
  String? _clarifyingQuestion;
  String? _error;
  Meal? _meal;

  @override
  void initState() {
    super.initState();
    _loadAndAnalyze();
  }

  Future<void> _loadAndAnalyze() async {
    final meal = await ref.read(mealByIdProvider(widget.mealId).future);
    if (meal == null || !mounted) return;
    setState(() {
      _meal = meal;
      if (meal.source == MealSource.aiPhoto &&
          meal.status == MealStatus.queued) {
        _analyzing = true;
      }
    });
    if (meal.source == MealSource.aiPhoto && meal.status == MealStatus.queued) {
      await _runAnalysis(meal);
    }
  }

  Future<void> _runAnalysis(Meal meal) async {
    try {
      if (meal.photoPath == null) return;
      final result = await gemini.estimateMeal(
        photoPath: meal.photoPath!,
        userNote: meal.userNote,
        retryCount: meal.retryCount,
      );
      await ref
          .read(mealQueueNotifierProvider.notifier)
          .applyGeminiResult(
            meal.id,
            kcalMin: result.kcalMin,
            kcalMax: result.kcalMax,
            kcalPoint: result.kcalPoint,
            proteinMin: result.proteinMin,
            proteinMax: result.proteinMax,
            proteinPoint: result.proteinPoint,
            carbMin: result.carbMin,
            carbMax: result.carbMax,
            carbPoint: result.carbPoint,
            fatMin: result.fatMin,
            fatMax: result.fatMax,
            fatPoint: result.fatPoint,
            aiConfidence: result.aiConfidence,
            aiRawJson: result.rawJson,
            components: result.components,
          );
      final updated = await ref.read(mealByIdProvider(meal.id).future);
      if (mounted)
        setState(() {
          _meal = updated;
          _analyzing = false;
          _clarifyingQuestion = result.clarifyingQuestion;
        });
    } on gemini.GeminiRateLimitException catch (e) {
      if (mounted)
        setState(() {
          _analyzing = false;
          _error =
              'Limite de requisições atingido. Aguarde ${e.retryAfterSeconds}s e tente novamente.';
        });
    } on gemini.GeminiApiException catch (e) {
      if (mounted)
        setState(() {
          _analyzing = false;
          _error = e.message;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _analyzing = false;
          _error = 'Erro inesperado: $e';
        });
    }
  }

  Future<void> _save() async {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final onPrimary = isDark ? const Color(0xFF2A1800) : Colors.white;
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final textDis = isDark ? GemaColors.darkTextDis : GemaColors.lightTextDis;
    final surfaceVar = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final proteinColor = isDark
        ? GemaColors.chartProteinDark
        : GemaColors.chartProteinLight;
    final carbColor = isDark
        ? GemaColors.chartCarbsDark
        : GemaColors.chartCarbsLight;
    final fatColor = isDark
        ? GemaColors.chartFatDark
        : GemaColors.chartFatLight;

    final meal = _meal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar refeição'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: meal == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo thumbnail
                    if (meal.photoPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(meal.photoPath!),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: surfaceVar,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '📷 Sem foto',
                            style: GemaTextStyles.body.copyWith(color: textDis),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Analyzing state
                    if (_analyzing) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Analisando com Gemini...',
                          style: GemaTextStyles.body.copyWith(color: textSub),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Error
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? GemaColors.darkErrorCont
                              : GemaColors.lightErrorCont,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: GemaTextStyles.body.copyWith(
                            color: isDark
                                ? GemaColors.darkOnErrCont
                                : GemaColors.lightOnErrCont,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Confidence badge
                    if (meal.aiConfidence != null) ...[
                      Row(
                        children: [
                          Text(
                            _confidenceText(meal.aiConfidence!),
                            style: GemaTextStyles.label.copyWith(
                              color: _confidenceColor(
                                meal.aiConfidence!,
                                isDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _confidenceHint(meal.aiConfidence!),
                              style: GemaTextStyles.micro.copyWith(
                                color: textDis,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Clarifying question
                    if (_clarifyingQuestion != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? GemaColors.darkPrimaryCont
                              : GemaColors.lightPrimaryCont,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⚠️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _clarifyingQuestion!,
                                style: GemaTextStyles.body.copyWith(
                                  color: isDark
                                      ? GemaColors.darkOnPrimCont
                                      : GemaColors.lightOnPrimCont,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Interval display
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surfaceVar,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _IntervalCell(
                            label: 'Mínimo',
                            value: '${meal.kcalMin}',
                            text: text,
                            textSub: textSub,
                          ),
                          Column(
                            children: [
                              Text(
                                '${meal.kcalPoint}',
                                style: GemaTextStyles.display.copyWith(
                                  color: primary,
                                  fontSize: 28,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                'kcal',
                                style: GemaTextStyles.micro.copyWith(
                                  color: textSub,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                          _IntervalCell(
                            label: 'Máximo',
                            value: '${meal.kcalMax}',
                            text: text,
                            textSub: textSub,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Kcal stepper
                    _KcalStepper(
                      value: meal.kcalPoint,
                      isDark: isDark,
                      onChanged: (v) async {
                        await ref
                            .read(mealQueueNotifierProvider.notifier)
                            .updateKcalPoint(meal.id, v);
                        final updated = await ref.read(
                          mealByIdProvider(meal.id).future,
                        );
                        if (mounted) setState(() => _meal = updated);
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Macros ajustados proporcionalmente',
                      style: GemaTextStyles.micro.copyWith(
                        color: textDis,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Macro chips
                    Row(
                      children: [
                        _MacroChip(
                          label: 'P',
                          value: '${meal.proteinPoint}g',
                          color: proteinColor,
                          surfaceVar: surfaceVar,
                          text: text,
                          textSub: textSub,
                        ),
                        const SizedBox(width: 8),
                        _MacroChip(
                          label: 'C',
                          value: '${meal.carbPoint}g',
                          color: carbColor,
                          surfaceVar: surfaceVar,
                          text: text,
                          textSub: textSub,
                        ),
                        const SizedBox(width: 8),
                        _MacroChip(
                          label: 'G',
                          value: '${meal.fatPoint}g',
                          color: fatColor,
                          surfaceVar: surfaceVar,
                          text: text,
                          textSub: textSub,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _analyzing ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                        ),
                        child: const Text('Salvar refeição'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _confidenceText(String c) => switch (c) {
    'high' => '● Alta confiança',
    'medium' => '● Confiança média',
    _ => '● Baixa confiança',
  };

  Color _confidenceColor(String c, bool isDark) => switch (c) {
    'high' => isDark ? GemaColors.darkSuccess : GemaColors.lightSuccess,
    'medium' => isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary,
    _ => isDark ? GemaColors.darkError : GemaColors.lightError,
  };

  String _confidenceHint(String c) => switch (c) {
    'high' => '— referência de escala identificada',
    'medium' => '— escala parcialmente identificada',
    _ => '— sem referência de escala clara',
  };
}

class _IntervalCell extends StatelessWidget {
  const _IntervalCell({
    required this.label,
    required this.value,
    required this.text,
    required this.textSub,
  });
  final String label;
  final String value;
  final Color text;
  final Color textSub;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GemaTextStyles.micro.copyWith(
            color: textSub,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: GemaTextStyles.title.copyWith(color: text)),
      ],
    );
  }
}

class _KcalStepper extends StatelessWidget {
  const _KcalStepper({
    required this.value,
    required this.isDark,
    required this.onChanged,
  });
  final int value;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final outline = isDark ? GemaColors.darkOutline : GemaColors.lightOutline;
    final surface = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;

    return Row(
      children: [
        _btn(
          Icons.remove,
          outline,
          surface,
          text,
          () => onChanged((value - 10).clamp(0, 9999)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
            ),
            child: Slider(
              value: value.clamp(0, 2000).toDouble(),
              min: 0,
              max: 2000,
              divisions: 400,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        _btn(
          Icons.add,
          outline,
          surface,
          text,
          () => onChanged((value + 10).clamp(0, 9999)),
        ),
      ],
    );
  }

  Widget _btn(
    IconData icon,
    Color outline,
    Color surface,
    Color text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: outline, width: 1.5),
        ),
        child: Icon(icon, color: text, size: 18),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
    required this.surfaceVar,
    required this.text,
    required this.textSub,
  });
  final String label;
  final String value;
  final Color color;
  final Color surfaceVar;
  final Color text;
  final Color textSub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: surfaceVar,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GemaTextStyles.micro.copyWith(
                color: textSub,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 3),
            Text(value, style: GemaTextStyles.title.copyWith(color: text)),
          ],
        ),
      ),
    );
  }
}
