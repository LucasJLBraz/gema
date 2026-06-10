import 'dart:math';

/// Time-aware EMA (§2.1). τ=7 days filters glycogen/water noise.
double timeAwareEma({
  required double previous,
  required double observed,
  required double deltaDays,
  double tau = 7.0,
}) {
  final alphaEff = 1.0 - exp(-deltaDays / tau);
  return previous + alphaEff * (observed - previous);
}

class OlsResult {
  const OlsResult({
    required this.slope,
    required this.intercept,
    required this.seSslope,
    required this.n,
  });

  final double slope; // kg/day
  final double intercept;
  final double seSslope;
  final int n;
}

/// OLS on (dayIndex, smoothedWeight) pairs (§2.2). Returns null if n<3.
OlsResult? computeOls(List<(DateTime, double)> points) {
  if (points.length < 3) return null;

  final t0 = points.first.$1;
  final xs = points.map((p) => p.$1.difference(t0).inDays.toDouble()).toList();
  final ys = points.map((p) => p.$2).toList();
  final n = xs.length;

  final xMean = xs.reduce((a, b) => a + b) / n;
  final yMean = ys.reduce((a, b) => a + b) / n;

  var sxx = 0.0;
  var sxy = 0.0;
  for (var i = 0; i < n; i++) {
    sxx += (xs[i] - xMean) * (xs[i] - xMean);
    sxy += (xs[i] - xMean) * (ys[i] - yMean);
  }

  if (sxx == 0) return null;

  final slope = sxy / sxx;
  final intercept = yMean - slope * xMean;

  var sse = 0.0;
  for (var i = 0; i < n; i++) {
    final residual = ys[i] - (intercept + slope * xs[i]);
    sse += residual * residual;
  }

  final sigma2 = sse / (n - 2);
  final seSslope = sqrt(sigma2 / sxx);

  return OlsResult(
    slope: slope,
    intercept: intercept,
    seSslope: seSslope,
    n: n,
  );
}

class ProjectionResult {
  const ProjectionResult({
    required this.optimisticDate,
    required this.pessimisticDate,
    required this.centerDate,
  });

  final DateTime optimisticDate;
  final DateTime pessimisticDate;
  final DateTime centerDate;
}

/// Projects goal date with 95% confidence band. Returns null if trend is
/// non-significant or moves in the wrong direction relative to the goal.
ProjectionResult? projectGoalDate({
  required OlsResult ols,
  required double currentSmoothed,
  required double targetWeight,
  required DateTime today,
}) {
  if (ols.slope == 0) return null;

  // t(n-2, 0.975) — approximate with 1.96 for n>=30, else conservative 2.1
  final tCrit = ols.n >= 30 ? 1.96 : 2.1;

  final slopeLo = ols.slope - tCrit * ols.seSslope;
  final slopeHi = ols.slope + tCrit * ols.seSslope;

  final cutting = targetWeight < currentSmoothed;
  final fastSlope = cutting ? min(slopeLo, slopeHi) : max(slopeLo, slopeHi);
  final slowSlope = cutting ? max(slopeLo, slopeHi) : min(slopeLo, slopeHi);

  // Slope must consistently point toward goal
  if (cutting && ols.slope >= 0) return null;
  if (!cutting && ols.slope <= 0) return null;

  double daysFor(double slope) => (targetWeight - currentSmoothed) / slope;

  final centerDays = daysFor(ols.slope);
  final fastDays = daysFor(fastSlope);
  final slowDays = daysFor(slowSlope);

  if (centerDays <= 0 || fastDays <= 0 || slowDays <= 0) return null;

  return ProjectionResult(
    optimisticDate: today.add(Duration(days: fastDays.round())),
    pessimisticDate: today.add(Duration(days: slowDays.round())),
    centerDate: today.add(Duration(days: centerDays.round())),
  );
}
