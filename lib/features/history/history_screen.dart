import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../goals/providers/goal_provider.dart';
import '../home/widgets/calorie_ring.dart';
import '../home/widgets/macro_bars.dart';
import '../home/widgets/meal_list_tile.dart';
import '../meals/models/meal.dart';
import '../meals/providers/meal_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _dayCount = 30;

  late DateTime _selectedDay;
  late List<DateTime> _days;
  late ScrollController _calendarScroll;

  @override
  void initState() {
    super.initState();
    final today = _startOfDay(DateTime.now());
    _selectedDay = today;
    _days = List.generate(
      _dayCount,
      (i) => today.subtract(Duration(days: _dayCount - 1 - i)),
    );
    _calendarScroll = ScrollController();
    // Scroll to today after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _calendarScroll.dispose();
    super.dispose();
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  void _scrollToSelected() {
    final idx = _days.indexWhere((d) => d.isAtSameMomentAs(_selectedDay));
    if (idx < 0) return;
    const itemW = 56.0;
    final target =
        (idx * itemW) - (MediaQuery.of(context).size.width / 2) + itemW / 2;
    _calendarScroll.animateTo(
      target.clamp(0.0, _calendarScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealsAsync = ref.watch(mealsForDayProvider(_selectedDay));
    final goalAsync = ref.watch(activeGoalProvider);

    final meals = mealsAsync.valueOrNull ?? [];
    final goal = goalAsync.valueOrNull;

    final totalKcal = meals.fold(0, (s, m) => s + m.kcalPoint);
    final totalProtein = meals.fold(0, (s, m) => s + m.proteinPoint);
    final totalCarb = meals.fold(0, (s, m) => s + m.carbPoint);
    final totalFat = meals.fold(0, (s, m) => s + m.fatPoint);

    final totalKcalMin = meals.fold(
      0,
      (s, m) => s + (m.source == MealSource.aiPhoto ? m.kcalMin : m.kcalPoint),
    );
    final totalKcalMax = meals.fold(
      0,
      (s, m) => s + (m.source == MealSource.aiPhoto ? m.kcalMax : m.kcalPoint),
    );
    final totalProteinMax = meals.fold(
      0,
      (s, m) =>
          s + (m.source == MealSource.aiPhoto ? m.proteinMax : m.proteinPoint),
    );
    final totalCarbMax = meals.fold(
      0,
      (s, m) => s + (m.source == MealSource.aiPhoto ? m.carbMax : m.carbPoint),
    );
    final totalFatMax = meals.fold(
      0,
      (s, m) => s + (m.source == MealSource.aiPhoto ? m.fatMax : m.fatPoint),
    );
    final hasRange = totalKcalMax - totalKcalMin >= 20;

    final kcalTarget = goal?.kcalTarget ?? 2000;
    final kcalPct = kcalTarget > 0 ? totalKcal / kcalTarget : 0.0;
    final deficit = kcalTarget - totalKcal;

    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final divider = isDark ? GemaColors.darkDivider : GemaColors.lightDivider;
    final surface = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;
    final surfaceVar = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final onPrimary = isDark ? const Color(0xFF2A1800) : Colors.white;
    final outlineVar = isDark
        ? GemaColors.darkOutlineVar
        : GemaColors.lightOutlineVar;

    final today = _startOfDay(DateTime.now());
    final isToday = _selectedDay.isAtSameMomentAs(today);
    final titleLabel = isToday
        ? 'Hoje'
        : DateFormat('EEEE, d MMM', 'pt_BR').format(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(titleLabel, style: Theme.of(context).textTheme.titleMedium),
      ),
      body: CustomScrollView(
        slivers: [
          // Mini calendar strip
          SliverToBoxAdapter(
            child: Container(
              color: surface,
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: SizedBox(
                height: 64,
                child: ListView.builder(
                  controller: _calendarScroll,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _days.length,
                  itemBuilder: (_, i) {
                    final day = _days[i];
                    final selected = day.isAtSameMomentAs(_selectedDay);
                    final isT = day.isAtSameMomentAs(today);

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDay = day);
                        _scrollToSelected();
                      },
                      child: Container(
                        width: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected ? primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isT && !selected
                              ? Border.all(color: primary, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat(
                                'E',
                                'pt_BR',
                              ).format(day).substring(0, 3).toUpperCase(),
                              style: GemaTextStyles.micro.copyWith(
                                color: selected ? onPrimary : textSub,
                                letterSpacing: 0,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${day.day}',
                              style: GemaTextStyles.label.copyWith(
                                color: selected ? onPrimary : text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Day summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceVar,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: outlineVar) : null,
                    ),
                    child: Row(
                      children: [
                        CalorieRing(
                          consumed: totalKcal,
                          target: kcalTarget,
                          pct: kcalPct.clamp(0, 1.2),
                          isDark: isDark,
                          size: 110,
                          pctMin: hasRange
                              ? (totalKcalMin / kcalTarget).clamp(0.0, 1.2)
                              : null,
                          pctMax: hasRange
                              ? (totalKcalMax / kcalTarget).clamp(0.0, 1.2)
                              : null,
                          rangeMin: hasRange ? totalKcalMin : null,
                          rangeMax: hasRange ? totalKcalMax : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MacroBars(
                            protein: totalProtein,
                            proteinTarget: goal?.proteinTargetG ?? 130,
                            carb: totalCarb,
                            carbTarget: goal?.carbTargetG ?? 210,
                            fat: totalFat,
                            fatTarget: goal?.fatTargetG ?? 68,
                            isDark: isDark,
                            proteinMax: hasRange ? totalProteinMax : null,
                            carbMax: hasRange ? totalCarbMax : null,
                            fatMax: hasRange ? totalFatMax : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          deficit >= 0
                              ? 'Déficit: −$deficit kcal'
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
                        'Nenhuma refeição registrada.',
                        style: GemaTextStyles.body.copyWith(color: textSub),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Meal list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MealListTile(meal: meals[i], isDark: isDark),
              ),
              childCount: meals.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
