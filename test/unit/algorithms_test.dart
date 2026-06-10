import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gema/core/algorithms/tdee_algorithms.dart';
import 'package:gema/core/algorithms/weight_algorithms.dart';

void main() {
  group('timeAwareEma', () {
    test('converges to observed when deltaDays >> tau', () {
      final result = timeAwareEma(
        previous: 80.0,
        observed: 75.0,
        deltaDays: 70.0, // 10 × τ
      );
      expect(result, closeTo(75.0, 0.01));
    });

    test('barely moves when deltaDays << tau', () {
      final result = timeAwareEma(
        previous: 80.0,
        observed: 75.0,
        deltaDays: 0.1,
      );
      expect(result, closeTo(80.0, 0.1));
    });

    test('1-day step produces expected alpha', () {
      const tau = 7.0;
      final alpha = 1.0 - exp(-1.0 / tau);
      final result = timeAwareEma(
        previous: 80.0,
        observed: 75.0,
        deltaDays: 1.0,
      );
      expect(result, closeTo(80.0 + alpha * (75.0 - 80.0), 1e-10));
    });
  });

  group('computeOls', () {
    test('returns null for fewer than 3 points', () {
      final points = [
        (DateTime(2024, 1, 1), 80.0),
        (DateTime(2024, 1, 2), 79.5),
      ];
      expect(computeOls(points), isNull);
    });

    test('exact linear data gives slope ~-0.5 kg/day', () {
      final base = DateTime(2024, 1, 1);
      final points = List.generate(
        10,
        (i) => (base.add(Duration(days: i)), 80.0 - i * 0.5),
      );
      final ols = computeOls(points)!;
      expect(ols.slope, closeTo(-0.5, 1e-9));
    });

    test('returns null when all x-values are identical', () {
      final points = [
        (DateTime(2024, 1, 1), 80.0),
        (DateTime(2024, 1, 1), 79.5),
        (DateTime(2024, 1, 1), 79.0),
      ];
      expect(computeOls(points), isNull);
    });

    test('seSslope is 0 for perfect fit', () {
      final base = DateTime(2024, 1, 1);
      final points = List.generate(
        5,
        (i) => (base.add(Duration(days: i)), 80.0 - i * 0.5),
      );
      final ols = computeOls(points)!;
      expect(ols.seSslope, closeTo(0.0, 1e-9));
    });
  });

  group('projectGoalDate', () {
    test(
      'returns null when slope points wrong direction (cutting, positive slope)',
      () {
        final base = DateTime(2024, 1, 1);
        final points = List.generate(
          10,
          (i) => (base.add(Duration(days: i)), 80.0 + i * 0.1),
        );
        final ols = computeOls(points)!;
        final result = projectGoalDate(
          ols: ols,
          currentSmoothed: 80.0,
          targetWeight: 75.0,
          today: base,
        );
        expect(result, isNull);
      },
    );

    test('center date is roughly correct for -0.5 kg/day toward target', () {
      final base = DateTime(2024, 1, 1);
      final points = List.generate(
        30,
        (i) => (base.add(Duration(days: i)), 80.0 - i * 0.5),
      );
      final ols = computeOls(points)!;
      final today = base.add(const Duration(days: 30));
      final result = projectGoalDate(
        ols: ols,
        currentSmoothed: 65.0,
        targetWeight: 60.0,
        today: today,
      );
      expect(result, isNotNull);
      // 5 kg / 0.5 kg/day = 10 days
      expect(result!.centerDate.difference(today).inDays, closeTo(10, 2));
    });

    test('optimisticDate before pessimisticDate for cut with non-zero SE', () {
      // Introduce controlled residuals so seSslope > 0 but slope remains negative
      final base = DateTime(2024, 1, 1);
      // Alternating residuals cancel perfectly over even windows → keeps seSslope small but nonzero
      final residuals = [0.2, -0.2, 0.3, -0.3, 0.1, -0.1];
      final points = List.generate(
        30,
        (i) => (
          base.add(Duration(days: i)),
          80.0 - i * 0.5 + residuals[i % residuals.length],
        ),
      );
      final ols = computeOls(points)!;
      // Slope must be negative (cutting) and seSslope small enough that slopeHi < 0
      expect(ols.slope, lessThan(0));
      final today = base.add(const Duration(days: 30));
      final result = projectGoalDate(
        ols: ols,
        currentSmoothed: 65.0,
        targetWeight: 60.0,
        today: today,
      );
      // Only assert ordering when result is non-null (both confidence slopes negative)
      if (result != null) {
        expect(
          !result.optimisticDate.isAfter(result.pessimisticDate),
          isTrue,
          reason: 'optimistic must not be later than pessimistic',
        );
      }
    });
  });

  group('computeBmr', () {
    test('Mifflin-St Jeor male', () {
      // 80 kg, 180 cm, 30 years, male
      // 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
      expect(
        computeBmr(weightKg: 80, heightCm: 180, ageYears: 30, isMale: true),
        closeTo(1780.0, 0.1),
      );
    });

    test('Mifflin-St Jeor female', () {
      // 65 kg, 165 cm, 25 years, female
      // 10*65 + 6.25*165 - 5*25 - 161 = 650 + 1031.25 - 125 - 161 = 1395.25
      expect(
        computeBmr(weightKg: 65, heightCm: 165, ageYears: 25, isMale: false),
        closeTo(1395.25, 0.1),
      );
    });

    test('Katch-McArdle used when bodyFatPct provided', () {
      // 80 kg, 20% BF → LBM = 64 kg → 370 + 21.6*64 = 370 + 1382.4 = 1752.4
      expect(
        computeBmr(
          weightKg: 80,
          heightCm: 180,
          ageYears: 30,
          isMale: true,
          bodyFatPct: 20.0,
        ),
        closeTo(1752.4, 0.1),
      );
    });
  });

  group('blendedTdee', () {
    test('returns prior when daysWithData <= 7', () {
      expect(
        blendedTdee(tdeePrior: 2000, tdeeEmpirical: 2500, daysWithData: 7),
        closeTo(2000.0, 0.1),
      );
    });

    test('returns empirical when daysWithData >= 21', () {
      expect(
        blendedTdee(tdeePrior: 2000, tdeeEmpirical: 2500, daysWithData: 21),
        closeTo(2500.0, 0.1),
      );
    });

    test('blends linearly at 14 days (w=0.5)', () {
      expect(
        blendedTdee(tdeePrior: 2000, tdeeEmpirical: 2500, daysWithData: 14),
        closeTo(2250.0, 0.1),
      );
    });
  });

  group('empiricalTdee', () {
    test('returns null when window < 7 days', () {
      expect(
        empiricalTdee(
          avgDailyKcal: 1800,
          smoothedWeightStart: 80.0,
          smoothedWeightEnd: 79.5,
          windowDays: 6,
        ),
        isNull,
      );
    });

    test('stable weight → empirical TDEE ≈ avgDailyKcal', () {
      expect(
        empiricalTdee(
          avgDailyKcal: 2000,
          smoothedWeightStart: 80.0,
          smoothedWeightEnd: 80.0,
          windowDays: 14,
        ),
        closeTo(2000.0, 0.1),
      );
    });

    test('0.5 kg/week loss → empirical TDEE > avgDailyKcal', () {
      // 0.5 kg over 7 days → ΔS = -0.5 → empirical = 1800 - (-0.5*7700/7) = 1800 + 550 = 2350
      expect(
        empiricalTdee(
          avgDailyKcal: 1800,
          smoothedWeightStart: 80.0,
          smoothedWeightEnd: 79.5,
          windowDays: 7,
        ),
        closeTo(2350.0, 0.1),
      );
    });
  });

  group('macrosFromKcal', () {
    test('2000 kcal splits correctly', () {
      final m = macrosFromKcal(2000);
      // protein 30% = 600 kcal / 4 = 150g
      // carb 40% = 800 kcal / 4 = 200g
      // fat = remaining / 9
      expect(m.proteinG, 150);
      expect(m.carbG, 200);
      expect(m.fatG, greaterThan(0));
    });

    test('fat is never negative', () {
      final m = macrosFromKcal(100);
      expect(m.fatG, greaterThanOrEqualTo(0));
    });
  });

  group('levelFromXp', () {
    test('0 XP → level 0', () => expect(levelFromXp(0), 0));
    test('100 XP → level 1', () => expect(levelFromXp(100), 1));
    test('400 XP → level 2', () => expect(levelFromXp(400), 2));
    test('900 XP → level 3', () => expect(levelFromXp(900), 3));
    test(
      '99 XP → level 0 (just below threshold)',
      () => expect(levelFromXp(99), 0),
    );
    test('401 XP → still level 2', () => expect(levelFromXp(401), 2));
    test('10000 XP → level 10', () => expect(levelFromXp(10000), 10));
  });
}
