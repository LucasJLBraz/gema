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
  });

  final int protein;
  final int proteinTarget;
  final int carb;
  final int carbTarget;
  final int fat;
  final int fatTarget;
  final bool isDark;

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
  });

  final String label;
  final int value;
  final int target;
  final Color color;
  final Color text;
  final Color textSub;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final pct = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
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
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: track,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
