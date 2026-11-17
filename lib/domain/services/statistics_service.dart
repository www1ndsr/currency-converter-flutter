import 'package:decimal/decimal.dart';
import '../../core/errors/app_exceptions.dart';
import '../../data/models/historical_rate_point.dart';

enum RateTrend {
  growth,
  decline,
  noChange;

  String get displayName {
    switch (this) {
      case RateTrend.growth:
        return 'Рост (Увеличение курса)';
      case RateTrend.decline:
        return 'Падение (Снижение курса)';
      case RateTrend.noChange:
        return 'Без изменений (Стабильно)';
    }
  }

  String get shortName {
    switch (this) {
      case RateTrend.growth:
        return 'Рост';
      case RateTrend.decline:
        return 'Падение';
      case RateTrend.noChange:
        return 'Без изменений';
    }
  }
}

class RateStatistics {
  final Decimal minimum;
  final Decimal maximum;
  final Decimal average;
  final Decimal absoluteChange;
  final Decimal percentageChange;
  final RateTrend trend;
  final DateTime firstDate;
  final DateTime lastDate;
  final int observationCount;

  const RateStatistics({
    required this.minimum,
    required this.maximum,
    required this.average,
    required this.absoluteChange,
    required this.percentageChange,
    required this.trend,
    required this.firstDate,
    required this.lastDate,
    required this.observationCount,
  });

  @override
  String toString() =>
      'RateStatistics(min: $minimum, max: $maximum, avg: $average, abs: $absoluteChange, pct: $percentageChange%, trend: ${trend.shortName})';
}

class StatisticsService {
  /// Calculates descriptive statistics and mathematical trend for historical rate points.
  /// Points are automatically ordered chronologically before computation.
  RateStatistics calculate(List<HistoricalRatePoint> points) {
    if (points.isEmpty) {
      throw const EmptyDataException('Нет данных для расчёта статистических показателей');
    }

    final sorted = List<HistoricalRatePoint>.from(points)
      ..sort((a, b) => a.date.compareTo(b.date));

    final count = sorted.length;
    final firstPoint = sorted.first;
    final lastPoint = sorted.last;

    final firstVal = firstPoint.ratePerUnit;
    final lastVal = lastPoint.ratePerUnit;

    // Minimum and Maximum
    var minVal = sorted.first.ratePerUnit;
    var maxVal = sorted.first.ratePerUnit;
    var sum = Decimal.zero;

    for (final p in sorted) {
      final v = p.ratePerUnit;
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
      sum += v;
    }

    // Average
    final avgRatio = sum / Decimal.fromInt(count);
    final average = avgRatio.toDecimal(scaleOnInfinitePrecision: 6);

    // Absolute Change = last - first
    final absoluteChange = lastVal - firstVal;

    // Percentage Change = ((last - first) / first) * 100
    Decimal percentageChange;
    if (firstVal <= Decimal.zero) {
      percentageChange = Decimal.zero;
    } else {
      final changeRatio = absoluteChange / firstVal;
      final pctRatio = changeRatio * Decimal.fromInt(100).toRational();
      percentageChange = pctRatio.toDecimal(scaleOnInfinitePrecision: 4);
    }

    // Trend determined mathematically
    final RateTrend trend;
    if (lastVal > firstVal) {
      trend = RateTrend.growth;
    } else if (lastVal < firstVal) {
      trend = RateTrend.decline;
    } else {
      trend = RateTrend.noChange;
    }

    return RateStatistics(
      minimum: minVal,
      maximum: maxVal,
      average: average,
      absoluteChange: absoluteChange,
      percentageChange: percentageChange,
      trend: trend,
      firstDate: firstPoint.date,
      lastDate: lastPoint.date,
      observationCount: count,
    );
  }
}
