import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MacroBars extends StatelessWidget {
  const MacroBars({
    super.key,
    required this.protein,
    required this.proteinTarget,
    required this.carb,
    required this.carbTarget,
    required this.fat,
    required this.fatTarget,
    required this.isDark,
    this.proteinMax,
    this.carbMax,
    this.fatMax,
  });

  final int protein;
  final int proteinTarget;
  final int carb;
  final int carbTarget;
  final int fat;
  final int fatTarget;
  final bool isDark;

  /// When non-null and > point, a translucent extension is painted from point to max.
  final int? proteinMax;
  final int? carbMax;
  final int? fatMax;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final track = isDark
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Bar(
          label: 'Proteína',
          value: protein,
          valueMax: proteinMax,
          target: proteinTarget,
          color: proteinColor,
          text: text,
          textSub: textSub,
          track: track,
        ),
        const SizedBox(height: 11),
        _Bar(
          label: 'Carbos',
          value: carb,
          valueMax: carbMax,
          target: carbTarget,
          color: carbColor,
          text: text,
          textSub: textSub,
          track: track,
        ),
        const SizedBox(height: 11),
        _Bar(
          label: 'Gordura',
          value: fat,
          valueMax: fatMax,
          target: fatTarget,
          color: fatColor,
          text: text,
          textSub: textSub,
          track: track,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    required this.text,
    required this.textSub,
    required this.track,
    this.valueMax,
  });

  final String label;
  final int value;
  final int? valueMax;
  final int target;
  final Color color;
  final Color text;
  final Color textSub;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final pct = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    final hasRange =
        valueMax != null && valueMax! > value && (valueMax! - value) >= 2;
    final pctMax = hasRange ? (valueMax! / target).clamp(0.0, 1.0) : null;
    final halfSpread = hasRange ? ((valueMax! - value) / 2).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GemaTextStyles.caption.copyWith(
                color: textSub,
                letterSpacing: 0,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${value}g',
                    style: GemaTextStyles.label.copyWith(color: text),
                  ),
                  if (hasRange)
                    TextSpan(
                      text: ' ±${halfSpread}g',
                      style: GemaTextStyles.micro.copyWith(
                        color: textSub,
                        letterSpacing: 0,
                      ),
                    ),
                  TextSpan(
                    text: ' / ${target}g',
                    style: GemaTextStyles.micro.copyWith(
                      color: textSub,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              // Track
              Container(height: 5, color: track),
              // Uncertainty extension (point → max)
              if (hasRange && pctMax != null)
                FractionallySizedBox(
                  widthFactor: pctMax,
                  child: Container(
                    height: 5,
                    color: color.withValues(alpha: 0.25),
                  ),
                ),
              // Solid fill (0 → point)
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
