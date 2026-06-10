import 'dart:math';

/// BMR via Mifflin-St Jeor or Katch-McArdle if body fat is available (§2.3).
double computeBmr({
  required double weightKg,
  required double heightCm,
  required int ageYears,
  required bool isMale,
  double? bodyFatPct,
}) {
  if (bodyFatPct != null && bodyFatPct > 0) {
    final lbm = weightKg * (1.0 - bodyFatPct / 100.0);
    return 370.0 + 21.6 * lbm;
  }
  if (isMale) {
    return 10.0 * weightKg + 6.25 * heightCm - 5.0 * ageYears + 5.0;
  }
  return 10.0 * weightKg + 6.25 * heightCm - 5.0 * ageYears - 161.0;
}

/// Blends prior TDEE with empirical estimate (§2.3).
/// w_empirical = clamp((daysWithData - 7) / 14, 0, 1)
double blendedTdee({
  required double tdeePrior,
  required double tdeeEmpirical,
  required int daysWithData,
}) {
  final w = ((daysWithData - 7) / 14.0).clamp(0.0, 1.0);
  return (1.0 - w) * tdeePrior + w * tdeeEmpirical;
}

/// Empirical TDEE from caloric balance over a window (§2.3).
/// Returns null when there isn't enough data.
double? empiricalTdee({
  required double avgDailyKcal,
  required double smoothedWeightStart,
  required double smoothedWeightEnd,
  required int windowDays,
}) {
  if (windowDays < 7) return null;
  const k = 7700.0;
  final deltaS = smoothedWeightEnd - smoothedWeightStart;
  return avgDailyKcal - (deltaS * k) / windowDays;
}

/// Macro split from kcal target. Protein 30%, Carb 40%, Fat 30%.
({int proteinG, int carbG, int fatG}) macrosFromKcal(int kcalTarget) {
  final proteinKcal = (kcalTarget * 0.30).round();
  final carbKcal = (kcalTarget * 0.40).round();
  final fatKcal = kcalTarget - proteinKcal - carbKcal;
  return (
    proteinG: (proteinKcal / 4).round(),
    carbG: (carbKcal / 4).round(),
    fatG: max(0, (fatKcal / 9).round()),
  );
}

/// XP level from cumulative XP (§2.7). Level = floor(sqrt(xpTotal / 100)).
int levelFromXp(int xpTotal) => sqrt(xpTotal / 100.0).floor();
