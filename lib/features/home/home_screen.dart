import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../gamification/providers/xp_provider.dart';
import '../goals/providers/goal_provider.dart';
import '../meals/models/meal.dart';
import '../meals/providers/meal_provider.dart';
import '../water/providers/water_provider.dart';
import 'widgets/calorie_ring.dart';
import 'widgets/macro_bars.dart';
import 'widgets/meal_list_tile.dart';
import 'widgets/water_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final onPrimary = isDark ? const Color(0xFF2A1800) : Colors.white;
    final primaryCont = isDark
        ? GemaColors.darkPrimaryCont
        : GemaColors.lightPrimaryCont;
    final onPrimCont = isDark
        ? GemaColors.darkOnPrimCont
        : GemaColors.lightOnPrimCont;

    final goalAsync = ref.watch(activeGoalProvider);
    final mealsAsync = ref.watch(todayMealsProvider);
    final waterAsync = ref.watch(todayWaterMlProvider);
    final xpLevelAsync = ref.watch(xpLevelProvider);

    final goal = goalAsync.valueOrNull;
    final meals = mealsAsync.valueOrNull ?? [];
    final waterMl = waterAsync.valueOrNull ?? 0;
    final level = xpLevelAsync.valueOrNull ?? 0;

    final totalKcal = meals.fold(0, (s, m) => s + m.kcalPoint);
    final totalProtein = meals.fold(0, (s, m) => s + m.proteinPoint);
    final totalCarb = meals.fold(0, (s, m) => s + m.carbPoint);
    final totalFat = meals.fold(0, (s, m) => s + m.fatPoint);

    final kcalTarget = goal?.kcalTarget ?? 2000;
    final proteinTarget = goal?.proteinTargetG ?? 130;
    final carbTarget = goal?.carbTargetG ?? 210;
    final fatTarget = goal?.fatTargetG ?? 68;

    final kcalPct = kcalTarget > 0 ? totalKcal / kcalTarget : 0.0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'gema',
                          style: GemaTextStyles.display.copyWith(
                            color: primary,
                            fontSize: 28,
                            letterSpacing: -1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryCont,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '⭐ Nível $level',
                            style: GemaTextStyles.label.copyWith(
                              color: onPrimCont,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Progress card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CalorieRing(
                              consumed: totalKcal,
                              target: kcalTarget,
                              pct: kcalPct.clamp(0, 1.2),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: MacroBars(
                                protein: totalProtein,
                                proteinTarget: proteinTarget,
                                carb: totalCarb,
                                carbTarget: carbTarget,
                                fat: totalFat,
                                fatTarget: fatTarget,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Remaining + XP row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            'Restam ${(kcalTarget - totalKcal).clamp(0, 9999)} kcal',
                            style: GemaTextStyles.body.copyWith(
                              color: isDark
                                  ? GemaColors.darkTextSub
                                  : GemaColors.lightTextSub,
                            ),
                          ),
                          const Spacer(),
                          if (meals.any(
                            (m) =>
                                m.status == MealStatus.queued ||
                                m.status == MealStatus.processing,
                          ))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? GemaColors.darkSurfaceVar
                                    : GemaColors.lightSurfaceVar,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '⏳ Processando',
                                style: GemaTextStyles.caption.copyWith(
                                  color: isDark
                                      ? GemaColors.darkTextSub
                                      : GemaColors.lightTextSub,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Water strip
                    WaterStrip(
                      currentMl: waterMl,
                      goalMl: 2500,
                      isDark: isDark,
                      onAdd: (ml) =>
                          ref.read(todayWaterMlProvider.notifier).add(ml),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons
                    _ActionButtons(
                      primary: primary,
                      onPrimary: onPrimary,
                      primaryCont: primaryCont,
                      onPrimCont: onPrimCont,
                    ),
                    const SizedBox(height: 20),

                    // Today's meals
                    if (meals.isNotEmpty) ...[
                      Text(
                        'HOJE',
                        style: GemaTextStyles.caption.copyWith(
                          color: isDark
                              ? GemaColors.darkTextSub
                              : GemaColors.lightTextSub,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: MealListTile(meal: meals[i], isDark: isDark),
                ),
                childCount: meals.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.primary,
    required this.onPrimary,
    required this.primaryCont,
    required this.onPrimCont,
  });
  final Color primary;
  final Color onPrimary;
  final Color primaryCont;
  final Color onPrimCont;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/capture'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Registrar refeição'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: GemaTextStyles.label.copyWith(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () => _showQuickAdd(context),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryCont,
                  foregroundColor: onPrimCont,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('⚡ Quick Add'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonal(
                onPressed: () => context.push('/barcode'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryCont,
                  foregroundColor: onPrimCont,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('📦 Barcode'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _QuickAddSheet(),
    );
  }
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  final _kcalCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _kcalCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final kcal = int.tryParse(_kcalCtrl.text) ?? 0;
    if (kcal <= 0) return;
    setState(() => _saving = true);
    await ref
        .read(mealQueueNotifierProvider.notifier)
        .createMeal(
          source: MealSource.quickAdd,
          userNote: _noteCtrl.text,
          kcalPoint: kcal,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Add', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          TextField(
            controller: _kcalCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Calorias (kcal)',
              hintText: '500',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              hintText: 'Ex: arroz com frango',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: const Text('Adicionar'),
            ),
          ),
        ],
      ),
    );
  }
}
