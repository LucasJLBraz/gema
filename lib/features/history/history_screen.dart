import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../goals/providers/goal_provider.dart';
import '../home/widgets/calorie_ring.dart';
import '../home/widgets/macro_bars.dart';
import '../home/widgets/meal_list_tile.dart';
import '../meals/providers/meal_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealsAsync = ref.watch(todayMealsProvider);
    final goalAsync = ref.watch(activeGoalProvider);

    final meals = mealsAsync.valueOrNull ?? [];
    final goal = goalAsync.valueOrNull;

    final totalKcal = meals.fold(0, (s, m) => s + m.kcalPoint);
    final totalProtein = meals.fold(0, (s, m) => s + m.proteinPoint);
    final totalCarb = meals.fold(0, (s, m) => s + m.carbPoint);
    final totalFat = meals.fold(0, (s, m) => s + m.fatPoint);

    final kcalTarget = goal?.kcalTarget ?? 2000;
    final kcalPct = kcalTarget > 0 ? totalKcal / kcalTarget : 0.0;
    final deficit = kcalTarget - totalKcal;

    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final divider = isDark ? GemaColors.darkDivider : GemaColors.lightDivider;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('EEEE, d MMM', 'pt_BR').format(DateTime.now()),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Day summary card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CalorieRing(
                            consumed: totalKcal,
                            target: kcalTarget,
                            pct: kcalPct.clamp(0, 1.2),
                            isDark: isDark,
                            size: 120,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: MacroBars(
                              protein: totalProtein,
                              proteinTarget: goal?.proteinTargetG ?? 130,
                              carb: totalCarb,
                              carbTarget: goal?.carbTargetG ?? 210,
                              fat: totalFat,
                              fatTarget: goal?.fatTargetG ?? 68,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Deficit row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          deficit >= 0
                              ? 'Déficit estimado: −$deficit kcal'
                              : 'Excedente: +${deficit.abs()} kcal',
                          style: GemaTextStyles.body.copyWith(color: textSub),
                        ),
                        Text(
                          '${meals.length} refeições',
                          style: GemaTextStyles.body.copyWith(color: textSub),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: divider, height: 24),

                  if (meals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Nenhuma refeição registrada hoje.',
                        style: GemaTextStyles.body.copyWith(color: textSub),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
