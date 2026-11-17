import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:currency_converter_flutter/core/errors/app_exceptions.dart';
import 'package:currency_converter_flutter/data/models/historical_rate_point.dart';
import 'package:currency_converter_flutter/domain/services/statistics_service.dart';

void main() {
  group('StatisticsService', () {
    late StatisticsService service;

    setUp(() {
      service = StatisticsService();
    });

    test('calculates correct metrics for growth trend', () {
      final points = [
        HistoricalRatePoint(
          date: DateTime(2024, 11, 1),
          effectiveDate: DateTime(2024, 11, 1),
          charCode: 'EUR',
          ratePerUnit: Decimal.parse('19.00'),
        ),
        HistoricalRatePoint(
          date: DateTime(2024, 11, 2),
          effectiveDate: DateTime(2024, 11, 2),
          charCode: 'EUR',
          ratePerUnit: Decimal.parse('19.20'),
        ),
        HistoricalRatePoint(
          date: DateTime(2024, 11, 3),
          effectiveDate: DateTime(2024, 11, 3),
          charCode: 'EUR',
          ratePerUnit: Decimal.parse('19.50'),
        ),
      ];

      final stats = service.calculate(points);

      expect(stats.minimum, Decimal.parse('19.00'));
      expect(stats.maximum, Decimal.parse('19.50'));
      // Average: (19.00 + 19.20 + 19.50) / 3 = 57.70 / 3 = 19.233333
      expect(stats.average, Decimal.parse('19.233333'));
      // Absolute change: 19.50 - 19.00 = 0.50
      expect(stats.absoluteChange, Decimal.parse('0.50'));
      // Percentage change: (0.50 / 19.00) * 100 = 2.6315...
      expect(stats.percentageChange, Decimal.parse('2.6315'));
      expect(stats.trend, RateTrend.growth);
      expect(stats.observationCount, 3);
    });

    test('calculates correct metrics for decline trend', () {
      final points = [
        HistoricalRatePoint(
          date: DateTime(2024, 11, 1),
          effectiveDate: DateTime(2024, 11, 1),
          charCode: 'USD',
          ratePerUnit: Decimal.parse('18.50'),
        ),
        HistoricalRatePoint(
          date: DateTime(2024, 11, 2),
          effectiveDate: DateTime(2024, 11, 2),
          charCode: 'USD',
          ratePerUnit: Decimal.parse('18.20'),
        ),
        HistoricalRatePoint(
          date: DateTime(2024, 11, 3),
          effectiveDate: DateTime(2024, 11, 3),
          charCode: 'USD',
          ratePerUnit: Decimal.parse('18.00'),
        ),
      ];

      final stats = service.calculate(points);

      expect(stats.minimum, Decimal.parse('18.00'));
      expect(stats.maximum, Decimal.parse('18.50'));
      expect(stats.absoluteChange, Decimal.parse('-0.50'));
      // Percentage change: (-0.50 / 18.50) * 100 = -2.7027
      expect(stats.percentageChange, Decimal.parse('-2.7027'));
      expect(stats.trend, RateTrend.decline);
    });

    test('calculates correct metrics for noChange trend', () {
      final points = [
        HistoricalRatePoint(
          date: DateTime(2024, 11, 1),
          effectiveDate: DateTime(2024, 11, 1),
          charCode: 'USD',
          ratePerUnit: Decimal.parse('18.00'),
        ),
        HistoricalRatePoint(
          date: DateTime(2024, 11, 2),
          effectiveDate: DateTime(2024, 11, 2),
          charCode: 'USD',
          ratePerUnit: Decimal.parse('18.15'),
        ),
        HistoricalRatePoint(
          date: DateTime(2024, 11, 3),
          effectiveDate: DateTime(2024, 11, 3),
          charCode: 'USD',
          ratePerUnit: Decimal.parse('18.00'),
        ),
      ];

      final stats = service.calculate(points);

      expect(stats.minimum, Decimal.parse('18.00'));
      expect(stats.maximum, Decimal.parse('18.15'));
      expect(stats.absoluteChange, Decimal.zero);
      expect(stats.percentageChange, Decimal.zero);
      expect(stats.trend, RateTrend.noChange);
    });

    test('handles single observation point correctly', () {
      final points = [
        HistoricalRatePoint(
          date: DateTime(2024, 11, 1),
          effectiveDate: DateTime(2024, 11, 1),
          charCode: 'EUR',
          ratePerUnit: Decimal.parse('19.00'),
        ),
      ];

      final stats = service.calculate(points);

      expect(stats.minimum, Decimal.parse('19.00'));
      expect(stats.maximum, Decimal.parse('19.00'));
      expect(stats.average, Decimal.parse('19.00'));
      expect(stats.absoluteChange, Decimal.zero);
      expect(stats.percentageChange, Decimal.zero);
      expect(stats.trend, RateTrend.noChange);
      expect(stats.observationCount, 1);
    });

    test('throws EmptyDataException when input list is empty', () {
      expect(
        () => service.calculate([]),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('sorts points by date if passed unordered', () {
      // Pass points in reversed order
      final points = [
        HistoricalRatePoint(
          date: DateTime(2024, 11, 3),
          effectiveDate: DateTime(2024, 11, 3),
          charCode: 'EUR',
          ratePerUnit: Decimal.parse('20.00'),
        ),
        HistoricalRatePoint(
          date: DateTime(2024, 11, 1),
          effectiveDate: DateTime(2024, 11, 1),
          charCode: 'EUR',
          ratePerUnit: Decimal.parse('19.00'),
        ),
      ];

      final stats = service.calculate(points);

      // Should order 19.00 -> 20.00, meaning growth
      expect(stats.firstDate, DateTime(2024, 11, 1));
      expect(stats.lastDate, DateTime(2024, 11, 3));
      expect(stats.absoluteChange, Decimal.parse('1.00'));
      expect(stats.trend, RateTrend.growth);
    });
  });
}
