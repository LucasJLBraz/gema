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
    this.pctMin,
    this.pctMax,
    this.rangeMin,
    this.rangeMax,
    this.size = 130,
    this.strokeWidth = 10,
  });

  final int consumed;
  final int target;
  final double pct;
  final bool isDark;

  final double? pctMin;
  final double? pctMax;
  final int? rangeMin;
  final int? rangeMax;

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
    // Surface color for tick "cuts" — must match the card background
    final cutColor = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;

    final hasRange =
        pctMin != null && pctMax != null && (pctMax! - pctMin!).abs() > 0.01;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              pct: pct.clamp(0.0, 1.2),
              pctMin: hasRange ? pctMin!.clamp(0.0, 1.5) : null,
              pctMax: hasRange ? pctMax!.clamp(0.0, 1.5) : null,
              trackColor: trackColor,
              primaryStart: isDark
                  ? const Color(0xFFFFD780)
                  : const Color(0xFFF5A820),
              primaryEnd: isDark
                  ? const Color(0xFFD4820A)
                  : const Color(0xFF7A4200),
              cutColor: cutColor,
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
                if (hasRange && rangeMin != null && rangeMax != null)
                  Text(
                    '±${(((rangeMax! - rangeMin!) / 2)).round()} kcal',
                    style: GemaTextStyles.micro.copyWith(
                      color: textSub,
                      fontSize: size * 0.072,
                      letterSpacing: 0,
                    ),
                  )
                else
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
    required this.cutColor,
    required this.strokeWidth,
    this.pctMin,
    this.pctMax,
  });

  final double pct;
  final double? pctMin;
  final double? pctMax;
  final Color trackColor;
  final Color primaryStart;
  final Color primaryEnd;
  final Color cutColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rInner = (size.width - strokeWidth) / 2;
    final rOuter = rInner + 6.0;

    final innerRect = Rect.fromCircle(center: Offset(cx, cy), radius: rInner);
    final outerRect = Rect.fromCircle(center: Offset(cx, cy), radius: rOuter);

    // 1. Track
    canvas.drawCircle(
      Offset(cx, cy),
      rInner,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // 2–4. Range arc (amber, same color as progress but low opacity)
    if (pctMin != null && pctMax != null && pctMax! > pctMin!) {
      final overflow = pctMax! > 1.0;
      final rangeStroke = strokeWidth - 2;

      final rangePaint = Paint()
        ..color = primaryStart.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rangeStroke
        ..strokeCap = StrokeCap.butt;

      if (!overflow) {
        // Single arc at R_inner from pctMin to pctMax
        canvas.drawArc(
          innerRect,
          -pi / 2 + 2 * pi * pctMin!,
          2 * pi * (pctMax! - pctMin!),
          false,
          rangePaint,
        );
      } else {
        // Segment A: R_inner, from pctMin → 1.0 (full wrap)
        canvas.drawArc(
          innerRect,
          -pi / 2 + 2 * pi * pctMin!,
          2 * pi * (1.0 - pctMin!),
          false,
          rangePaint,
        );

        // Segment B: R_outer, from 0 → (pctMax - 1.0)
        canvas.drawArc(
          outerRect,
          -pi / 2,
          2 * pi * (pctMax! - 1.0),
          false,
          rangePaint,
        );

        // Junction line at 12 o'clock (R_inner → R_outer)
        final junctionPaint = Paint()
          ..color = primaryStart.withValues(alpha: 0.25)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(cx, cy - rInner),
          Offset(cx, cy - rOuter),
          junctionPaint,
        );
      }
    }

    // 5. Solid progress arc — flat start at 12 o'clock, round cap at tip only
    if (pct > 0) {
      final clampedPct = pct.clamp(0.0, 1.0);
      final sweep = 2 * pi * clampedPct;

      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [primaryStart, primaryEnd],
          startAngle: -pi / 2,
          endAngle: -pi / 2 + 2 * pi,
          transform: const GradientRotation(-pi / 2),
        ).createShader(innerRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap =
            StrokeCap.butt; // flat at both ends; we draw the tip cap manually

      canvas.drawArc(innerRect, -pi / 2, sweep, false, progressPaint);

      // Draw a filled circle at the tip to produce a round cap only at the end
      final tipAngle = -pi / 2 + sweep;
      final tipX = cx + rInner * cos(tipAngle);
      final tipY = cy + rInner * sin(tipAngle);
      final tipPaint = Paint()
        ..color = primaryEnd
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2, tipPaint);
    }

    // 6–7. Tick cuts (rendered last, always on top)
    if (pctMin != null && pctMax != null) {
      final overflow = pctMax! > 1.0;

      final tickPaint = Paint()
        ..color = cutColor
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Tick at pctMin — always at R_inner
      _drawTick(canvas, cx, cy, rInner, pctMin!, tickPaint);

      // Tick at pctMax — R_outer if overflow, R_inner otherwise
      if (overflow) {
        _drawTick(canvas, cx, cy, rOuter, pctMax! - 1.0, tickPaint);
      } else {
        _drawTick(canvas, cx, cy, rInner, pctMax!, tickPaint);
      }
    }
  }

  void _drawTick(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    double pct,
    Paint paint,
  ) {
    final angle = -pi / 2 + 2 * pi * pct;
    final innerR = radius - 4.0;
    final outerR = radius + 4.0;
    canvas.drawLine(
      Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
      Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct ||
      old.pctMin != pctMin ||
      old.pctMax != pctMax ||
      old.trackColor != trackColor ||
      old.cutColor != cutColor;
}
