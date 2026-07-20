import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WaterStrip extends StatelessWidget {
  const WaterStrip({
    super.key,
    required this.currentMl,
    required this.goalMl,
    required this.isDark,
    required this.onAdd,
    this.onRemove,
  });

  final int currentMl;
  final int goalMl;
  final bool isDark;
  final void Function(int ml) onAdd;
  final void Function(int ml)? onRemove;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final primaryCont = isDark
        ? GemaColors.darkPrimaryCont
        : GemaColors.lightPrimaryCont;
    final onPrimCont = isDark
        ? GemaColors.darkOnPrimCont
        : GemaColors.lightOnPrimCont;
    final track = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final outlineVar = isDark
        ? GemaColors.darkOutlineVar
        : GemaColors.lightOutlineVar;
    final pct = goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0.0;
    final remaining = (goalMl - currentMl).clamp(0, goalMl);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: outlineVar) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '💧 ${(currentMl / 1000).toStringAsFixed(2).replaceAll('.', ',')} L',
                      style: GemaTextStyles.title.copyWith(color: text),
                    ),
                    TextSpan(
                      text: ' de ${(goalMl / 1000).toStringAsFixed(1)} L',
                      style: GemaTextStyles.body.copyWith(color: textSub),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (onRemove != null && currentMl > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () => onRemove!(250),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? GemaColors.darkSurfaceVar
                                : GemaColors.lightSurfaceVar,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '−250',
                            style: GemaTextStyles.label.copyWith(
                              color: isDark
                                  ? GemaColors.darkTextSub
                                  : GemaColors.lightTextSub,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ...[250, 500].map((ml) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () => onAdd(ml),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: primaryCont,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+$ml',
                            style: GemaTextStyles.label.copyWith(
                              color: onPrimCont,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: track,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF5AAAD0)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pct >= 1.0
                ? '✅ Meta atingida hoje'
                : 'Faltam ${(remaining / 1000).toStringAsFixed(2).replaceAll('.', ',')} L',
            style: GemaTextStyles.micro.copyWith(
              color: textSub,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
