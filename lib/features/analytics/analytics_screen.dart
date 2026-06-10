import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/algorithms/weight_algorithms.dart';
import '../../core/theme/app_theme.dart';
import '../gamification/providers/xp_provider.dart';
import '../goals/providers/goal_provider.dart';
import '../weight/providers/weight_provider.dart';
import '../weight/widgets/log_weight_dialog.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final smoothedAsync = ref.watch(smoothedWeightsProvider);
    final goalAsync = ref.watch(activeGoalProvider);
    final totalXpAsync = ref.watch(totalXpProvider);
    final xpLevelAsync = ref.watch(xpLevelProvider);

    final smoothed = smoothedAsync.valueOrNull ?? [];
    final goal = goalAsync.valueOrNull;
    final totalXp = totalXpAsync.valueOrNull ?? 0;
    final level = xpLevelAsync.valueOrNull ?? 0;

    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final primaryCont = isDark
        ? GemaColors.darkPrimaryCont
        : GemaColors.lightPrimaryCont;
    final onPrimCont = isDark
        ? GemaColors.darkOnPrimCont
        : GemaColors.lightOnPrimCont;

    // OLS projection
    OlsResult? ols;
    ProjectionResult? projection;
    if (smoothed.length >= 3) {
      ols = computeOls(
        smoothed.length > 28
            ? smoothed.sublist(smoothed.length - 28)
            : smoothed,
      );
      if (ols != null && goal?.targetWeight != null) {
        final current = smoothed.last.$2;
        projection = projectGoalDate(
          ols: ols,
          currentSmoothed: current,
          targetWeight: goal!.targetWeight!,
          today: DateTime.now(),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<bool>(
          context: context,
          builder: (_) => const LogWeightDialog(),
        ),
        icon: const Icon(Icons.monitor_weight_outlined),
        label: const Text('Registrar peso'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Weight chart
          _SectionLabel(text: 'PESO', textSub: textSub),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (smoothed.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Nenhuma pesagem registrada ainda.',
                          style: GemaTextStyles.body.copyWith(color: textSub),
                        ),
                      ),
                    )
                  else ...[
                    _WeightChart(
                      points: smoothed,
                      isDark: isDark,
                      projection: projection,
                    ),
                    const SizedBox(height: 12),
                    _WeightLegend(isDark: isDark),
                    if (projection != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryCont,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meta provável: ${_fmtDate(projection.optimisticDate)} – ${_fmtDate(projection.pessimisticDate)}',
                              style: GemaTextStyles.label.copyWith(
                                color: onPrimCont,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IC 95%  ·  ${ols!.slope.toStringAsFixed(3)} kg/dia  ·  n=${ols.n} pesagens',
                              style: GemaTextStyles.micro.copyWith(
                                color: onPrimCont.withValues(alpha: 0.75),
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (smoothed.length >= 3) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? GemaColors.darkSurfaceVar
                              : GemaColors.lightSurfaceVar,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tendência ainda inconclusiva — registre mais pesagens.',
                          style: GemaTextStyles.body.copyWith(color: textSub),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // XP / level
          _SectionLabel(text: 'PROGRESSÃO', textSub: textSub),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: primaryCont,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Nv $level',
                          style: GemaTextStyles.headline.copyWith(
                            color: onPrimCont,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${totalXp.toString()} XP',
                          style: GemaTextStyles.micro.copyWith(
                            color: onPrimCont.withValues(alpha: 0.7),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nível ${level + 1} em ${_xpForNextLevel(level) - totalXp} XP',
                          style: GemaTextStyles.label.copyWith(color: text),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _levelProgress(totalXp, level),
                            backgroundColor: isDark
                                ? GemaColors.darkSurfaceVar
                                : GemaColors.lightSurfaceVar,
                            valueColor: AlwaysStoppedAnimation(primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  int _xpForNextLevel(int level) => ((level + 1) * (level + 1) * 100);
  int _xpForLevel(int level) => (level * level * 100);

  double _levelProgress(int totalXp, int level) {
    final base = _xpForLevel(level);
    final next = _xpForNextLevel(level);
    if (next <= base) return 1.0;
    return ((totalXp - base) / (next - base)).clamp(0.0, 1.0);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.textSub});
  final String text;
  final Color textSub;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GemaTextStyles.caption.copyWith(color: textSub));
  }
}

class _WeightLegend extends StatelessWidget {
  const _WeightLegend({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final textDis = isDark ? GemaColors.darkTextDis : GemaColors.lightTextDis;

    return Row(
      children: [
        _dot(textDis),
        const SizedBox(width: 4),
        Text(
          'Peso cru',
          style: GemaTextStyles.micro.copyWith(
            color: textSub,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 16),
        Container(width: 16, height: 2, color: primary),
        const SizedBox(width: 4),
        Text(
          'Suavizado (EMA)',
          style: GemaTextStyles.micro.copyWith(
            color: textSub,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _dot(Color c) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({
    required this.points,
    required this.isDark,
    this.projection,
  });

  final List<(DateTime, double)> points;
  final bool isDark;
  final ProjectionResult? projection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        size: const Size(double.infinity, 100),
        painter: _WeightChartPainter(
          points: points,
          isDark: isDark,
          projection: projection,
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter({
    required this.points,
    required this.isDark,
    this.projection,
  });

  final List<(DateTime, double)> points;
  final bool isDark;
  final ProjectionResult? projection;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final weights = points.map((p) => p.$2).toList();
    final minW = weights.reduce(min) - 0.5;
    final maxW = weights.reduce(max) + 0.5;
    final range = maxW - minW;
    if (range == 0) return;

    final t0 = points.first.$1;
    final tLast = points.last.$1;
    final totalDays = tLast.difference(t0).inDays.toDouble();
    if (totalDays == 0) return;

    double tx(DateTime t) => (t.difference(t0).inDays / totalDays) * size.width;
    double ty(double w) =>
        size.height -
        ((w - minW) / range) * size.height * 0.85 -
        size.height * 0.075;

    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final dotColor = isDark ? GemaColors.darkTextDis : GemaColors.lightTextDis;

    // Raw dots
    final dotPaint = Paint()..color = dotColor;
    for (final p in points) {
      canvas.drawCircle(Offset(tx(p.$1), ty(p.$2)), 2.5, dotPaint);
    }

    // Smoothed line
    final linePaint = Paint()
      ..color = primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = tx(points[i].$1);
      final y = ty(points[i].$2);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => old.points != points;
}
