import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decimal/decimal.dart';
import 'package:currency_converter_flutter/data/models/exchange_rate.dart';
import 'package:currency_converter_flutter/data/models/historical_rate_point.dart';
import 'package:currency_converter_flutter/data/models/rate_snapshot.dart';
import 'package:currency_converter_flutter/data/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cacheService = CacheService();
    });

    test('saves and retrieves latest rate snapshot', () async {
      final now = DateTime(2024, 11, 15);
      final snapshot = RateSnapshot(
        requestedDate: now,
        effectiveDate: now,
        fetchedAt: now,
        rates: {
          'MDL': ExchangeRate.mdl(),
          'EUR': ExchangeRate.create(
            charCode: 'EUR',
            numCode: 978,
            nominal: 1,
            name: 'Euro',
            value: Decimal.parse('19.0274'),
          ),
        },
      );

      final saveSuccess = await cacheService.saveLatestSnapshot(snapshot);
      expect(saveSuccess, isTrue);

      final cached = await cacheService.getLatestSnapshot();
      expect(cached, isNotNull);
      expect(cached!.isFromCache, isTrue);
      expect(cached.effectiveDate, now);
      expect(cached.rates.containsKey('EUR'), isTrue);
      expect(cached.getRate('EUR')!.ratePerUnit, Decimal.parse('19.0274'));
    });

    test('returns null when no cache is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final cached = await cacheService.getLatestSnapshot();
      expect(cached, isNull);
    });

    test('gracefully handles corrupted JSON in cache without crashing', () async {
      SharedPreferences.setMockInitialValues({
        'bnm_latest_rate_snapshot': '{"corrupted": true, broken json...}',
      });

      final cached = await cacheService.getLatestSnapshot();
      expect(cached, isNull);
    });

    test('saves and retrieves historical rate points', () async {
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
          ratePerUnit: Decimal.parse('18.05'),
        ),
      ];

      final saved = await cacheService.saveHistoricalPoints(
        charCode: 'USD',
        points: points,
      );
      expect(saved, isTrue);

      final retrieved = await cacheService.getHistoricalPoints('USD');
      expect(retrieved, isNotNull);
      expect(retrieved!.length, 2);
      expect(retrieved[0].ratePerUnit, Decimal.parse('18.00'));
      expect(retrieved[1].ratePerUnit, Decimal.parse('18.05'));
    });

    test('clears all cached snapshots and historical records', () async {
      final now = DateTime(2024, 11, 15);
      final snapshot = RateSnapshot(
        requestedDate: now,
        effectiveDate: now,
        fetchedAt: now,
        rates: {'MDL': ExchangeRate.mdl()},
      );
      await cacheService.saveLatestSnapshot(snapshot);
      await cacheService.saveHistoricalPoints(charCode: 'EUR', points: []);

      await cacheService.clearAll();

      expect(await cacheService.getLatestSnapshot(), isNull);
      expect(await cacheService.getHistoricalPoints('EUR'), isNull);
    });
  });
}
