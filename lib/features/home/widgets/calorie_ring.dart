import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.consumed,
    required this.target,
    required this.pct,
    required this.isDark,
    this.size = 130,
    this.strokeWidth = 10,
  });

  final int consumed;
  final int target;
  final double pct;
  final bool isDark;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final trackColor = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final text = isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              pct: pct.clamp(0.0, 1.2),
              trackColor: trackColor,
              primaryStart: isDark
                  ? const Color(0xFFFFD780)
                  : const Color(0xFFF5A820),
              primaryEnd: isDark
                  ? const Color(0xFFD4820A)
                  : const Color(0xFF7A4200),
              strokeWidth: strokeWidth,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$consumed',
                  style: GemaTextStyles.display.copyWith(
                    color: text,
                    fontSize: size * 0.18,
                    letterSpacing: -0.04 * size * 0.18,
                  ),
                ),
                Text(
                  'de $target kcal',
                  style: GemaTextStyles.micro.copyWith(
                    color: textSub,
                    fontSize: size * 0.085,
                  ),
                ),
                Text(
                  '${(pct * 100).round()}%',
                  style: GemaTextStyles.caption.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.09,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.pct,
    required this.trackColor,
    required this.primaryStart,
    required this.primaryEnd,
    required this.strokeWidth,
  });

  final double pct;
  final Color trackColor;
  final Color primaryStart;
  final Color primaryEnd;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    if (pct <= 0) return;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [primaryStart, primaryEnd],
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        transform: const GradientRotation(-pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * pct.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.trackColor != trackColor;
}
